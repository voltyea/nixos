#include "network.h"
#include <QDBusInterface>
#include <QDBusConnection>
#include <QDBus>

Network::Network(QObject *parent) : QObject(parent) {
  QDBusInterface nm(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.NetworkManager",
      QDBusConnection::systemBus()
      );

  if (!nm.isValid()) {
    qWarning() << "Failed to connect to NetworkManager";
  }

  QDBusInterface props(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.DBus.Properties",
      QDBusConnection::systemBus()
      );

  QDBusReply<QVariant> reply = props.call("Get", "org.freedesktop.NetworkManager", "NetworkingEnabled");
}

bool Network::enabled() const {
  return reply.value().toBool();
}
