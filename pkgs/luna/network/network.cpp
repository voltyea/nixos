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

  QDBusReply<QVariant> reply =
    props.call("Get",
        "org.freedesktop.NetworkManager",
        "NetworkingEnabled");

  if (!reply.isValid()) {
    qWarning() << "D-Bus call failed:" << reply.error().message();
    return;
  }

  m_enabled = reply.value().toBool();
}

bool Network::enabled() const {
  return m_enabled;
}
