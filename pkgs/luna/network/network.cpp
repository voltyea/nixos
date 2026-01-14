#include "network.h"
#include <QtDBus>

Network::Network(QObject *parent) : QObject(parent) {
  QDBusConnection::systemBus().connect(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.DBus.Properties",
      "PropertiesChanged",
      this,
      SLOT(onPropertiesChanged(QString, QVariantMap, QStringList))
      );
}

bool Network::wirelessEnabled() const {
  QDBusInterface props(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.DBus.Properties",
      QDBusConnection::systemBus()
      );

  QDBusReply<QVariant> reply = props.call("Get", "org.freedesktop.NetworkManager", "WirelessEnabled");

  return reply.value().toBool();
}
