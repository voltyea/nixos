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

void AccessPoint::connect(const QString &password) {
  QDBusInterface nm(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.NetworkManager",
      QDBusConnection::systemBus()
      );
  QMap<QString, QVariantMap> settings;
  nm.call("AddAndActivateConnection", QVariant::fromValue(settings), m_devicePath, m_apPath);
}

Network::Network(QObject *parent) : QObject(parent) {
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

QList<AccessPoint*> Network::accessPoints() {
  QList<AccessPoint*> result;
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
      QDBusReply<QVariant> apReply = props.call("Get", "org.freedesktop.NetworkManager.Device.Wireless", "AccessPoints");
      QList<QDBusObjectPath> apPaths;
      apReply.value().value<QDBusArgument>() >> apPaths;
      for(const QDBusObjectPath &apPath : apPaths) {
        auto *ap = new AccessPoint(this);
        ap->m_apPath = apPath;
        if(!ap->ssid().isEmpty()) {
          ap->m_devicePath = devicePath;
          result.append(ap);
        }
      }
    }
  }
  return result;
}
