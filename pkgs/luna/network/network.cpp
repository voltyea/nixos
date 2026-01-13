#include "network.h"
#include <QtDBus>

Network::Network(QObject *parent) : QObject(parent) {
  QDBusInterface props(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.DBus.Properties",
      QDBusConnection::systemBus()
      );

  if (!props.isValid()) {
    qWarning() << "Failed to connect to NetworkManager properties interface";
    return;
  }

  QDBusReply<QVariant> reply = props.call("Get", "org.freedesktop.NetworkManager", "WirelessEnabled");

  if (!reply.isValid()) {
    qWarning() << "D-Bus call failed:" << reply.error().message();
    return;
  }

  m_wirelessEnabled = reply.value().toBool();
}

bool Network::wirelessEnabled() const {
  return m_wirelessEnabled;
}
