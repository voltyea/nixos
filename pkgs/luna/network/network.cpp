#include "network.h"

#include <QtDBus>
#include <QUuid>
#include <algorithm>

static constexpr uint WIFI_DEVICE_TYPE = 2;

static QString decodeSsid(const QVariant &v) {
  return QString::fromUtf8(v.toByteArray());
}

/* ================= AccessPoint ================= */

AccessPoint::AccessPoint(QObject *parent)
  : QObject(parent) {}

  QString AccessPoint::ssid() const { return m_ssid; }
  uint AccessPoint::strength() const { return m_strength; }
  bool AccessPoint::active() const { return m_active; }
  bool AccessPoint::open() const { return m_open; }
  bool AccessPoint::saved() const { return m_saved; }

void AccessPoint::setData(const QString &ssid,
    uint strength,
    bool active,
    bool open,
    bool saved,
    const QDBusObjectPath &apPath,
    const QDBusObjectPath &devicePath)
{
  m_ssid = ssid;
  m_strength = strength;
  m_active = active;
  m_open = open;
  m_saved = saved;
  m_apPath = apPath;
  m_devicePath = devicePath;
}

void AccessPoint::connect(const QString &password) {
  QDBusInterface nm(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.NetworkManager",
      QDBusConnection::systemBus()
      );

  QVariantMap settings;
  settings["connection"] = QVariantMap{
    {"type", "802-11-wireless"},
      {"id", m_ssid},
      {"uuid", QUuid::createUuid().toString()}
  };
  settings["802-11-wireless"] = QVariantMap{
    {"ssid", m_ssid.toUtf8()},
      {"mode", "infrastructure"}
  };
  settings["ipv4"] = QVariantMap{{"method", "auto"}};
  settings["ipv6"] = QVariantMap{{"method", "auto"}};

  if (!m_open) {
    settings["802-11-wireless-security"] = QVariantMap{
      {"key-mgmt", "wpa-psk"},
        {"psk", password}
    };
  }

  nm.asyncCall("AddAndActivateConnection",
      settings, m_devicePath, m_apPath);
}

void AccessPoint::disconnect() {
  QDBusInterface dev(
      "org.freedesktop.NetworkManager",
      m_devicePath.path(),
      "org.freedesktop.NetworkManager.Device",
      QDBusConnection::systemBus()
      );

  dev.asyncCall("Disconnect");
}

/* ================= Network ================= */

Network::Network(QObject *parent)
  : QObject(parent)
{
  QDBusConnection::systemBus().connect(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.DBus.Properties",
      "PropertiesChanged",
      this,
      SLOT(onPropertiesChanged(QString,QVariantMap,QStringList))
      );

  reloadAsync();
}

bool Network::wirelessEnabled() const {
  QDBusInterface props(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.DBus.Properties",
      QDBusConnection::systemBus()
      );

  QDBusReply<QVariant> reply =
    props.call("Get",
        "org.freedesktop.NetworkManager",
        "WirelessEnabled");

  return reply.isValid() && reply.value().toBool();
}

void Network::onPropertiesChanged(const QString &iface,
    const QVariantMap &changed,
    const QStringList &) {
  if (iface == "org.freedesktop.NetworkManager" &&
      changed.contains("WirelessEnabled")) {
    emit wirelessEnabledChanged();
  }
}

/* ================= QQmlListProperty ================= */

QQmlListProperty<QObject> Network::accessPoints() {
  return QQmlListProperty<QObject>(
      this,
      &m_accessPoints,
      &Network::apCount,
      &Network::apAt
      );
}

qsizetype Network::apCount(QQmlListProperty<QObject>* p) {
  return static_cast<QList<QObject*>*>(p->data)->size();
}

QObject* Network::apAt(QQmlListProperty<QObject>* p, qsizetype index) {
  return static_cast<QList<QObject*>*>(p->data)->at(index);
}

/* ================= Async loading ================= */

void Network::reloadAsync() {
  qDeleteAll(m_accessPoints);
  m_accessPoints.clear();
  m_savedSsids.clear();
  emit accessPointsChanged();

  fetchSavedConnections();
}

void Network::fetchSavedConnections() {
  QDBusInterface nm(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.NetworkManager",
      QDBusConnection::systemBus()
      );

  auto *w = new QDBusPendingCallWatcher(
      nm.asyncCall("ListConnections"), this);

  connect(w, &QDBusPendingCallWatcher::finished, this,
      [this, w]() {
      QDBusPendingReply<QList<QDBusObjectPath>> r = *w;
      w->deleteLater();

      if (r.isValid()) {
      for (const auto &path : r.value()) {
      QDBusInterface conn(
          "org.freedesktop.NetworkManager",
          path.path(),
          "org.freedesktop.NetworkManager.Settings.Connection",
          QDBusConnection::systemBus()
          );

      QDBusReply<QVariantMap> s = conn.call("GetSettings");
      if (!s.isValid())
      continue;

      QByteArray ssid =
      s.value()
      .value("802-11-wireless")
      .toMap()
      .value("ssid")
      .toByteArray();

      if (!ssid.isEmpty())
        m_savedSsids.insert(QString::fromUtf8(ssid));
      }
      }

      fetchDevices();
      });
}

void Network::fetchDevices() {
  QDBusInterface nm(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.NetworkManager",
      QDBusConnection::systemBus()
      );

  auto *w = new QDBusPendingCallWatcher(
      nm.asyncCall("GetDevices"), this);

  connect(w, &QDBusPendingCallWatcher::finished, this,
      [this, w]() {
      QDBusPendingReply<QList<QDBusObjectPath>> r = *w;
      w->deleteLater();

      if (!r.isValid())
      return;

      for (const auto &dev : r.value()) {
      QDBusInterface props(
          "org.freedesktop.NetworkManager",
          dev.path(),
          "org.freedesktop.DBus.Properties",
          QDBusConnection::systemBus()
          );

      QDBusReply<QVariant> type =
      props.call("Get",
          "org.freedesktop.NetworkManager.Device",
          "DeviceType");

      if (!type.isValid() ||
          type.value().toUInt() != WIFI_DEVICE_TYPE)
        continue;

      QDBusReply<QVariant> activeReply =
        props.call("Get",
            "org.freedesktop.NetworkManager.Device.Wireless",
            "ActiveAccessPoint");

      fetchAccessPoints(
          dev,
          activeReply.value().value<QDBusObjectPath>()
          );
      }
      });
}

void Network::fetchAccessPoints(const QDBusObjectPath &device,
    const QDBusObjectPath &activeAp)
{
  QDBusInterface wifi(
      "org.freedesktop.NetworkManager",
      device.path(),
      "org.freedesktop.NetworkManager.Device.Wireless",
      QDBusConnection::systemBus()
      );

  auto *w = new QDBusPendingCallWatcher(
      wifi.asyncCall("GetAccessPoints"), this);

  connect(w, &QDBusPendingCallWatcher::finished, this,
      [this, w, device, activeAp]() {
      QDBusPendingReply<QList<QDBusObjectPath>> r = *w;
      w->deleteLater();

      if (!r.isValid())
      return;

      QVector<AccessPoint*> aps;

      for (const auto &apPath : r.value()) {
      QDBusInterface ap(
          "org.freedesktop.NetworkManager",
          apPath.path(),
          "org.freedesktop.DBus.Properties",
          QDBusConnection::systemBus()
          );

      QDBusReply<QVariant> ssid =
      ap.call("Get",
          "org.freedesktop.NetworkManager.AccessPoint",
          "Ssid");
      QDBusReply<QVariant> strength =
        ap.call("Get",
            "org.freedesktop.NetworkManager.AccessPoint",
            "Strength");
      QDBusReply<QVariant> flags =
        ap.call("Get",
            "org.freedesktop.NetworkManager.AccessPoint",
            "Flags");
      QDBusReply<QVariant> wpa =
        ap.call("Get",
            "org.freedesktop.NetworkManager.AccessPoint",
            "WpaFlags");
      QDBusReply<QVariant> rsn =
        ap.call("Get",
            "org.freedesktop.NetworkManager.AccessPoint",
            "RsnFlags");

      if (!ssid.isValid() || !strength.isValid())
        continue;

      auto *obj = new AccessPoint(this);
      obj->setData(
          decodeSsid(ssid.value()),
          strength.value().toUInt(),
          apPath.path() == activeAp.path(),
          ((flags.value().toUInt()
            | wpa.value().toUInt()
            | rsn.value().toUInt()) == 0),
          m_savedSsids.contains(decodeSsid(ssid.value())),
          apPath,
          device
          );

      aps.append(obj);
      }

      std::sort(aps.begin(), aps.end(),
          [](AccessPoint *a, AccessPoint *b) {
          return a->strength() > b->strength();
          });

      for (auto *ap : aps)
        m_accessPoints.append(ap);

      emit accessPointsChanged();
      });
}
