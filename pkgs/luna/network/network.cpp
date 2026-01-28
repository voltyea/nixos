#include "network.h"

AccessPoint::AccessPoint(QObject *parent) : QObject(parent) {
  QDBusConnection::systemBus().connect(
      "org.freedesktop.NetworkManager",
      m_apPath.path(),
      "org.freedesktop.DBus.Properties",
      "PropertiesChanged",
      this,
      SLOT(onPropertiesChanged(QString,QVariantMap,QStringList))
      );
  QDBusConnection::systemBus().connect(
      "org.freedesktop.NetworkManager",
      m_devicePath.path(),
      "org.freedesktop.DBus.Properties",
      "PropertiesChanged",
      this,
      SLOT(onPropertiesChanged(QString,QVariantMap,QStringList))
      );
  QDBusConnection::systemBus().connect(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager/Settings",
      "org.freedesktop.DBus.Properties",
      "PropertiesChanged",
      this,
      SLOT(onPropertiesChanged(QString,QVariantMap,QStringList))
      );
}

QString AccessPoint::ssid() const {
  QDBusInterface apSsid(
      "org.freedesktop.NetworkManager",
      m_apPath.path(),
      "org.freedesktop.NetworkManager.AccessPoint",
      QDBusConnection::systemBus()
      );
  return QString::fromUtf8(apSsid.property("Ssid").value<QByteArray>());
}

int AccessPoint::strength() const {
  QDBusInterface apStrength(
      "org.freedesktop.NetworkManager",
      m_apPath.path(),
      "org.freedesktop.NetworkManager.AccessPoint",
      QDBusConnection::systemBus()
      );
  return apStrength.property("Strength").value<uint>();
}

bool AccessPoint::active() const {
  QDBusInterface activeAp(
      "org.freedesktop.NetworkManager",
      m_devicePath.path(),
      "org.freedesktop.NetworkManager.Device.Wireless",
      QDBusConnection::systemBus()
      );
  if(activeAp.property("ActiveAccessPoint").value<QDBusObjectPath>() == m_apPath) {
    return true;
  }
  return false;
}

bool AccessPoint::saved() const {
  QDBusInterface savedAp(
      "org.freedesktop.NetworkManager",
      m_apPath.path(),
      "org.freedesktop.NetworkManager.AccessPoint",
      QDBusConnection::systemBus()
      );
  QDBusInterface settingsIface(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager/Settings",
      "org.freedesktop.NetworkManager.Settings",
      QDBusConnection::systemBus()
      );
  for(const QDBusObjectPath &savedPath : settingsIface.property("Connections").value<QList<QDBusObjectPath>>()) {
    QDBusInterface connIface(
        "org.freedesktop.NetworkManager",
        savedPath.path(),
        "org.freedesktop.NetworkManager.Settings.Connection",
        QDBusConnection::systemBus()
        );
    QDBusReply<QMap<QString, QVariantMap>> savedSetting = connIface.call("GetSettings");
    if (savedSetting.value().value("connection").value("type") == "802-11-wireless") {
      if(savedSetting.value().value("802-11-wireless").value("ssid").toByteArray() == savedAp.property("Ssid").value<QByteArray>()) {
        return true;
      }
    }
  }
  return false;
}

int AccessPoint::flags() const {
  QDBusInterface apflags(
      "org.freedesktop.NetworkManager",
      m_apPath.path(),
      "org.freedesktop.NetworkManager.AccessPoint",
      QDBusConnection::systemBus()
      );
  return apflags.property("Flags").toUInt();
}

int AccessPoint::wpaFlags() const {
  QDBusInterface apwpaflags(
      "org.freedesktop.NetworkManager",
      m_apPath.path(),
      "org.freedesktop.NetworkManager.AccessPoint",
      QDBusConnection::systemBus()
      );
  return apwpaflags.property("WpaFlags").toUInt();
}

int AccessPoint::rsnFlags() const {
  QDBusInterface aprsnflags(
      "org.freedesktop.NetworkManager",
      m_apPath.path(),
      "org.freedesktop.NetworkManager.AccessPoint",
      QDBusConnection::systemBus()
      );
  return aprsnflags.property("RsnFlags").toUInt();
}

ConnectionResult::Enum AccessPoint::connect(const QString &password) {
  QDBusInterface nm(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.NetworkManager",
      QDBusConnection::systemBus()
      );
  QDBusInterface deviceState(
      "org.freedesktop.NetworkManager",
      m_devicePath.path(),
      "org.freedesktop.DBus.Properties",
      QDBusConnection::systemBus()
      );
  if(saved() || (flags() == 0 && wpaFlags() == 0 && rsnFlags() == 0)) {
    nm.call("ActivateConnection", QDBusObjectPath("/"), m_devicePath, m_apPath);
  }
  else {
    QVariantMap wifiSecurity;
    wifiSecurity["key-mgmt"] = "wpa-psk";
    wifiSecurity["psk"] = password;
    QMap<QString, QVariantMap> settings;
    settings.insert("802-11-wireless-security", wifiSecurity);
    nm.call("AddAndActivateConnection", QVariant::fromValue(settings), m_devicePath, m_apPath);
  }
  QDBusReply<QVariant> reply = deviceState.call("Get", "org.freedesktop.NetworkManager.Device", "StateReason");
  const QDBusArgument arg = reply.value().value<QDBusArgument>();
  uint state = 0;
  uint reason = 0;
  arg.beginStructure();
  arg >> state >> reason;
  arg.endStructure();
  switch(reason) {
    case 0:
      return ConnectionResult::Enum::None;
    case 1:
      return ConnectionResult::Enum::Unknown;
    case 7:
      return ConnectionResult::Enum::WrongPassword;
    default:
      return ConnectionResult::Enum::Unknown;
  }
}

ConnectionResult::Enum AccessPoint::connect() {
  QDBusInterface nm(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.NetworkManager",
      QDBusConnection::systemBus()
      );
  QDBusInterface deviceState(
      "org.freedesktop.NetworkManager",
      m_devicePath.path(),
      "org.freedesktop.DBus.Properties",
      QDBusConnection::systemBus()
      );
  nm.call("ActivateConnection", QDBusObjectPath("/"), m_devicePath, m_apPath);
  QDBusReply<QVariant> reply = deviceState.call("Get", "org.freedesktop.NetworkManager.Device", "StateReason");
  const QDBusArgument arg = reply.value().value<QDBusArgument>();
  uint state = 0;
  uint reason = 0;
  arg.beginStructure();
  arg >> state >> reason;
  arg.endStructure();
  switch(reason) {
    case 0:
      return ConnectionResult::Enum::None;
    case 1:
      return ConnectionResult::Enum::Unknown;
    case 7:
      return ConnectionResult::Enum::WrongPassword;
    default:
      return ConnectionResult::Enum::Unknown;
  }
}

Network::Network(QObject *parent) : QObject(parent) {
  getAp();
  QDBusInterface nm(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.NetworkManager",
      QDBusConnection::systemBus()
      );
  for(const QDBusObjectPath &devicePath : nm.property("Devices").value<QList<QDBusObjectPath>>()) {
    QDBusInterface props(
        "org.freedesktop.NetworkManager",
        devicePath.path(),
        "org.freedesktop.DBus.Properties",
        QDBusConnection::systemBus()
        );
    QDBusReply<QVariant> deviceType = props.call("Get", "org.freedesktop.NetworkManager.Device", "DeviceType");
    if(deviceType.value().toUInt() == 2) {
      QDBusConnection::systemBus().connect(
          "org.freedesktop.NetworkManager",
          devicePath.path(),
          "org.freedesktop.NetworkManager.Device.Wireless",
          "AccessPointAdded",
          this,
          SLOT(onApChanged(QDBusObjectPath))
          );
      QDBusConnection::systemBus().connect(
          "org.freedesktop.NetworkManager",
          devicePath.path(),
          "org.freedesktop.NetworkManager.Device.Wireless",
          "AccessPointRemoved",
          this,
          SLOT(onApChanged(QDBusObjectPath))
          );
    }
  }
}

void Network::getAp() {
  QDBusInterface nm(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.NetworkManager",
      QDBusConnection::systemBus()
      );
  for(const QDBusObjectPath &devicePath : nm.property("Devices").value<QList<QDBusObjectPath>>()) {
    QDBusInterface props(
        "org.freedesktop.NetworkManager",
        devicePath.path(),
        "org.freedesktop.DBus.Properties",
        QDBusConnection::systemBus()
        );
    QDBusReply<QVariant> deviceType = props.call("Get", "org.freedesktop.NetworkManager.Device", "DeviceType");
    if(deviceType.value().toUInt() == 2) {
      auto *watcher = new QDBusPendingCallWatcher(props.asyncCall("Get", "org.freedesktop.NetworkManager.Device.Wireless", "AccessPoints"), this);
      connect(watcher, &QDBusPendingCallWatcher::finished, this, [&, watcher, devicePath]() {
          QDBusPendingReply<QVariant> apReply = *watcher;
          watcher->deleteLater();
          QList<QDBusObjectPath> apPaths;
          apReply.value().value<QDBusArgument>() >> apPaths;
          m_result.clear();
          for(const QDBusObjectPath &apPath : apPaths) {
          auto *ap = new AccessPoint(this);
          ap->m_apPath = apPath;
          if(!ap->ssid().isEmpty()) {
          ap->m_devicePath = devicePath;
          m_result.append(ap);
          }
          }
          QHash<QString, AccessPoint*> bestBySsid;
          for(AccessPoint* net : m_result) {
          auto it = bestBySsid.find(net->ssid());
          if(it == bestBySsid.end()) {
          bestBySsid.insert(net->ssid(), net);
          continue;
          }
          AccessPoint* current = it.value();
          if(net->active() && !current->active()) {
            it.value() = net;
          }
          else if(net->active() == current->active() && net->strength() > current->strength()) {
            it.value() = net;
          }
          }
          QList<AccessPoint*> result;
          result.reserve(bestBySsid.size());
          for(auto it = bestBySsid.begin(); it != bestBySsid.end(); ++it) {
            result.append(it.value());
          }
          std::sort(result.begin(), result.end(), [](const AccessPoint* a, const AccessPoint* b) {
              return a->strength() > b->strength();
              });
          m_result = std::move(result);
          emit accessPointsChanged();
      });
    }
  }
}

QList<AccessPoint*> Network::accessPoints() {
  return m_result;
}
