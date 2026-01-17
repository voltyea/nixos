#include "network.h"
#include <QtDBus>
#include <QUuid>

static constexpr uint WIFI_DEVICE_TYPE = 2;
static QString toString(const QVariant &value) {
  return QString::fromUtf8(value.toByteArray());
}

Network::Network(QObject *parent) : QObject(parent) {
  QDBusConnection::systemBus().connect(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.DBus.Properties",
      "PropertiesChanged",
      this,
      SLOT(onPropertiesChanged(QString,QVariantMap,QStringList))
      );
}

bool Network::wirelessEnabled() const {
  QDBusInterface properties(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.DBus.Properties",
      QDBusConnection::systemBus()
      );
  QDBusReply<QVariant> reply = properties.call("Get", "org.freedesktop.NetworkManager", "WirelessEnabled");
  return reply.isValid() && reply.value().toBool();
}

void Network::onPropertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &) {
  if (interface == "org.freedesktop.NetworkManager" && changed.contains("WirelessEnabled")) {
    emit wirelessEnabledChanged();
  }
}

QList<AccessPoints> Network::accessPoints() const {
  QDBusInterface nm(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.NetworkManager",
      QDBusConnection::systemBus()
      );
  QDBusInterface wifi(
      "org.freedesktop.NetworkManager",
      device.path(),
      "org.freedesktop.NetworkManager.Device.Wireless",
      QDBusConnection::systemBus()
      );

  auto *wireless = new QDBusPendingCallWatcher(nm.asyncCall("GetDevices"), this);
  connect(wireless, &QDBusPendingCallWatcher::finished, this, [this, wireless]() {
      QDBusPendingReply<QList<QDBusObjectPath>> reply = *wireless;
      for (const auto &device : reply.value()) {
      QDBusInterface props(
          "org.freedesktop.NetworkManager",
          device.path(),
          "org.freedesktop.DBus.Properties",
          QDBusConnection::systemBus()
          );

      QDBusReply<QVariant> device_type = props.call("Get", "org.freedesktop.NetworkManager.Device", "DeviceType");
      if (!device_type.isValid() || device_type.value().toUInt() != WIFI_DEVICE_TYPE) continue;
      QDBusConnection::systemBus().connect(
          "org.freedesktop.NetworkManager",
          device.path(),
          "org.freedesktop.NetworkManager.Device.Wireless",
          "AccessPointAdded",
          this,
          SLOT(onApChanged(QDBusObjectPath))
          );
      QDBusConnection::systemBus().connect(
          "org.freedesktop.NetworkManager",
          device.path(),
          "org.freedesktop.NetworkManager.Device.Wireless",
          "AccessPointRemoved",
          this,
          SLOT(onApChanged(QDBusObjectPath))
          );
      QDBusConnection::systemBus().connect(
          "org.freedesktop.NetworkManager",
          device.path(),
          "org.freedesktop.DBus.Properties",
          "PropertiesChanged",
          this,
          SLOT(onPropertiesChanged(QString,QVariantMap,QStringList))
          );
      QDBusReply<QVariant> activeReply = props.call("Get", "org.freedesktop.NetworkManager.Device.Wireless", "ActiveAccessPoint");
      }
  });
  auto *wireless2 = new QDBusPendingCallWatcher(wifi.asyncCall("GetAccessPoints"), this);
  connect(wireless2, &QDBusPendingCallWatcher::finished, this, [this, wireless2, device, activeAp]() {
      QDBusPendingReply<QList<QDBusObjectPath>> reply2 = *wireless2;
      for (const auto &apPath : reply2.value()) {
      QDBusInterface ap("org.freedesktop.NetworkManager", apPath.path(), "org.freedesktop.DBus.Properties", QDBusConnection::systemBus());
      QDBusReply<QVariant> ssid = ap.call("Get", "org.freedesktop.NetworkManager.AccessPoint", "Ssid");
      QDBusReply<QVariant> strength = ap.call("Get", "org.freedesktop.NetworkManager.AccessPoint", "Strength");
      QDBusReply<QVariant> flags = ap.call("Get", "org.freedesktop.NetworkManager.AccessPoint", "Flags");
      QDBusReply<QVariant> wpa = ap.call("Get", "org.freedesktop.NetworkManager.AccessPoint", "WpaFlags");
      QDBusReply<QVariant> rsn = ap.call("Get", "org.freedesktop.NetworkManager.AccessPoint", "RsnFlags");
      if (!ssid.isValid() || !strength.isValid()) continue;
      auto *obj = new AccessPoint(this);
      obj -> m_ssid = decodeSsid(ssid.value());
      obj -> m_strength = strength.value().toUInt();
      obj -> m_active = (apPath.path() == activeAp.path());
      obj -> m_open = ((flags.value().toUInt() | wpa.value().toUInt() | rsn.value().toUInt()) == 0);
      obj -> m_saved = m_savedSsids.contains(obj -> m_ssid);
      obj -> m_apPath = apPath;
      obj -> m_devicePath = device;
      QDBusConnection::systemBus().connect(
          "org.freedesktop.NetworkManager",
          apPath.path(),
          "org.freedesktop.DBus.Properties",
          "PropertiesChanged",
          this,
          SLOT(onDbusPropertiesChanged(QString,QVariantMap,QStringList))
          );
      m_accessPoints.append(obj);
      }
      emit accessPointsChanged();
  });
}
