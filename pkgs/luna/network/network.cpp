#include "network.h"

Network::Network(QObject *parent) : QObject(parent) {}

QList<AccessPoint> Network::accessPoints() {
QSet<QByteArray> savedSsids;
QSet<QString> activeApPaths;
QList<AccessPoint> result;

  QDBusInterface settingsIface(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager/Settings",
      "org.freedesktop.NetworkManager.Settings",
      QDBusConnection::systemBus()
      );
  auto *savedWatcher = new QDBusPendingCallWatcher(settingsIface.asyncCall("ListConnections"), this);
  connect(savedWatcher, &QDBusPendingCallWatcher::finished, this, [&, savedWatcher]() {
      QDBusPendingReply<QList<QDBusObjectPath>> savedReply = *savedWatcher;
      savedWatcher->deleteLater();
      for (const QDBusObjectPath &connPath : savedReply.value()) {
      QDBusInterface connIface(
          "org.freedesktop.NetworkManager",
          connPath.path(),
          "org.freedesktop.NetworkManager.Settings.Connection",
          QDBusConnection::systemBus()
          );
      auto *msgWatcher = new QDBusPendingCallWatcher(connIface.asyncCall("GetSettings"), this);
      connect(msgWatcher, &QDBusPendingCallWatcher::finished, this, [&, msgWatcher]() {
          QDBusPendingReply<QDBusMessage> msgReply = *msgWatcher;
          msgWatcher->deleteLater();
          QMap<QString, QVariantMap> settings = qdbus_cast<QMap<QString, QVariantMap>>(msgReply.value().arguments().at(0));
          if (settings.value("connection").value("type") == "802-11-wireless") {
          savedSsids.insert(settings.value("802-11-wireless").value("ssid").toByteArray());
          }
          });
      }
      });

  QDBusInterface nm(
      "org.freedesktop.NetworkManager",
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.NetworkManager",
      QDBusConnection::systemBus()
      );

  auto *activeWatcher = new QDBusPendingCallWatcher(nm.asyncCall("ActiveConnections"), this);
  connect(activeWatcher, &QDBusPendingCallWatcher::finished, this, [&, activeWatcher]() {
      QDBusPendingReply<QList<QDBusObjectPath>> activeReply = *activeWatcher;
      activeWatcher->deleteLater();
      for(const QDBusObjectPath &activePath : activeReply.value()) {
      QDBusInterface activeConn(
          "org.freedesktop.NetworkManager",
          activePath.path(),
          "org.freedesktop.DBus.Properties",
          QDBusConnection::systemBus()
          );
      auto *activeApWatcher = new QDBusPendingCallWatcher(activeConn.asyncCall("Get", "org.freedesktop.NetworkManager.Connection.Active", "SpecificObject"), this);
      connect(activeApWatcher, &QDBusPendingCallWatcher::finished, this, [&, activeApWatcher]() {
          QDBusPendingReply<QDBusObjectPath> activeApReply = *activeApWatcher;
          activeApWatcher->deleteLater();
          activeApPaths.insert(activeApReply.value().path());
          });
      }
      });

  auto *watcher = new QDBusPendingCallWatcher(nm.asyncCall("GetDevices"), this);
  connect(watcher, &QDBusPendingCallWatcher::finished, this, [&, watcher]() {
      QDBusPendingReply<QList<QDBusObjectPath>> reply = *watcher;
      watcher->deleteLater();
      for(const QDBusObjectPath &devicePath : reply.value()) {
      QDBusInterface props(
          "org.freedesktop.NetworkManager",
          devicePath.path(),
          "org.freedesktop.DBus.Properties",
          QDBusConnection::systemBus()
          );
      auto *deviceWatcher = new QDBusPendingCallWatcher(props.asyncCall("Get", "org.freedesktop.NetworkManager.Device", "DeviceType"), this);
      connect(deviceWatcher, &QDBusPendingCallWatcher::finished, this, [&, deviceWatcher]() {
          QDBusPendingReply<QVariant> deviceReply = *deviceWatcher;
          deviceWatcher->deleteLater();
          if(deviceReply.value().toUInt() == 2) {
          auto *apWatcher = new QDBusPendingCallWatcher(props.asyncCall("Get", "org.freedesktop.NetworkManager.Device.Wireless", "AccessPoints"), this);
          connect(apWatcher, &QDBusPendingCallWatcher::finished, this, [&, apWatcher]() {
              QDBusPendingReply<QList<QDBusObjectPath>> apReply = *apWatcher;
              apWatcher->deleteLater();
              for(const QDBusObjectPath &apPath : apReply.value()) {
              QDBusInterface apProps(
                  "org.freedesktop.NetworkManager",
                  apPath.path(),
                  "org.freedesktop.DBus.Properties",
                  QDBusConnection::systemBus()
                  );
              auto *ssidWatcher = new QDBusPendingCallWatcher(apProps.asyncCall("Get", "org.freedesktop.NetworkManager.AccessPoint", "Ssid"), this);
              connect(ssidWatcher, &QDBusPendingCallWatcher::finished, this, [&, ssidWatcher]() {
                  QDBusPendingReply<QVariant> ssidReply = *ssidWatcher;
                  ssidWatcher->deleteLater();
                  AccessPoint ap;
                  const QByteArray ssid = ssidReply.value().toByteArray();
                  if(!ssid.isEmpty()) {
                  ap.ssid = QString::fromUtf8(ssid);
                  auto *strengthWatcher = new QDBusPendingCallWatcher(apProps.asyncCall("Get", "org.freedesktop.NetworkManager.AccessPoint", "Strength"), this);
                  connect(strengthWatcher, &QDBusPendingCallWatcher::finished, this, [&, strengthWatcher]() {
                      QDBusPendingReply<QVariant> strengthReply = *strengthWatcher;
                      strengthWatcher->deleteLater();
                      ap.strength = strengthReply.value().toUInt();
                      });
                  ap.active = activeApPaths.contains(apPath.path());
                  ap.saved = savedSsids.contains(ssid);
                  uint flags;
                  uint wpaflags;
                  uint rsnflags;
                  auto *flagsWatcher = new QDBusPendingCallWatcher(apProps.asyncCall("Get", "org.freedesktop.NetworkManager.AccessPoint", "Flags"), this);
                  connect(flagsWatcher, &QDBusPendingCallWatcher::finished, this, [&, flagsWatcher]() {
                      QDBusPendingReply<QVariant> flagsReply = *flagsWatcher;
                      flagsWatcher->deleteLater();
                      flags = flagsReply.value().toUInt();
                      });
                  auto *wpaFlagsWatcher = new QDBusPendingCallWatcher(apProps.asyncCall("Get", "org.freedesktop.NetworkManager.AccessPoint", "WpaFlags"), this);
                  connect(wpaFlagsWatcher, &QDBusPendingCallWatcher::finished, this, [&, wpaFlagsWatcher]() {
                      QDBusPendingReply<QVariant> wpaFlagsReply = *wpaFlagsWatcher;
                      wpaFlagsWatcher->deleteLater();
                      wpaflags = wpaFlagsReply.value().toUInt();
                      });
                  auto *rsnFlagsWatcher = new QDBusPendingCallWatcher(apProps.asyncCall("Get", "org.freedesktop.NetworkManager.AccessPoint", "RsnFlags"), this);
                  connect(rsnFlagsWatcher, &QDBusPendingCallWatcher::finished, this, [&, rsnFlagsWatcher]() {
                      QDBusPendingReply<QVariant> rsnFlagsReply = *rsnFlagsWatcher;
                      rsnFlagsWatcher->deleteLater();
                      rsnflags = rsnFlagsReply.value().toUInt();
                      });
                  if(flags == 0 && wpaflags == 0 && rsnflags == 0 ) {
                    ap.open = true;
                  }
                  result.append(ap);
                  }
              });
              }
          });
          }
      });
      }
  });
  return result;
}
