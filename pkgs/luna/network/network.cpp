#include "network.h"
#include <QtDBus>

Network::Network(QObject *parent) : QObject(parent) {

  QDBusInterface m_properties(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.DBus.Properties",
      QDBusConnection::systemBus()
      );

  QDBusConnection::systemBus().connect(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.DBus.Properties",
      "PropertiesChanged",
      this,
      SLOT(onPropertiesChanged(QString, QVariantMap, QStringList))
      );
}

void Network::onPropertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &) {
  if (interface == "org.freedesktop.NetworkManager") {
    if (changed.contains("WirelessEnabled"))
      emit wirelessEnabledChanged();

    if (changed.contains("Devices"))
      emit accessPointsChanged();
  }
}

bool Network::wirelessEnabled() const {
  QDBusReply<QVariant> reply = m_properties.call("Get", "org.freedesktop.NetworkManager", "WirelessEnabled");
  return reply.value().toBool();
}

QVector<QDBusObjectPath> Network::accessPoints() const {
  QVector<QDBusObjectPath> result;
  QDBusInterface nm(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.NetworkManager",
      QDBusConnection::systemBus()
      );

  QDBusReply<QList<QDBusObjectPath>> devicesReply =
    nm.call("GetDevices");

  if (!devicesReply.isValid())
    return result;

  // 2. Iterate devices
  for (const QDBusObjectPath &devicePath : devicesReply.value()) {

    QDBusInterface deviceProps(
        "org.freedesktop.NetworkManager",
        devicePath.path(),
        "org.freedesktop.DBus.Properties",
        QDBusConnection::systemBus()
        );

    QDBusReply<QVariant> typeReply =
      deviceProps.call(
          "Get",
          "org.freedesktop.NetworkManager.Device",
          "DeviceType"
          );

    if (!typeReply.isValid() ||
        typeReply.value().toUInt() != WIFI_DEVICE_TYPE)
      continue;

    // 3. Wireless device → get access points
    QDBusInterface wifiDevice(
        "org.freedesktop.NetworkManager",
        devicePath.path(),
        "org.freedesktop.NetworkManager.Device.Wireless",
        QDBusConnection::systemBus()
        );

    QDBusReply<QList<QDBusObjectPath>> apReply =
      wifiDevice.call("GetAccessPoints");

    if (!apReply.isValid())
      continue;

    for (const QDBusObjectPath &ap : apReply.value())
      result.append(ap);
  }
  return result;
}
