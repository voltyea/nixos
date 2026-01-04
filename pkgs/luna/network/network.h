#pragma once

#include <QObject>
#include <QtQml/qqml.h>
#include <QVariant>
#include <QString>
#include <NetworkManager.h>

struct AccessPointInfo {
  Q_GADGET
    Q_PROPERTY(QString ssid MEMBER ssid)
    Q_PROPERTY(int strength MEMBER strength)
    Q_PROPERTY(bool active MEMBER active)

  public:
    QString ssid;
    int strength;
    bool active;
};
Q_DECLARE_METATYPE(AccessPointInfo)

  static NMClient* g_client = nullptr;
  static bool g_initializing = false;

  static void nm_client_ready(GObject*, GAsyncResult* result, gpointer) {
    GError* error = nullptr;
    g_client = nm_client_new_finish(result, &error);
    if (!g_client && error)
      g_error_free(error);
    g_initializing = false;
  }

inline void init_nm_client_async() {
  if (g_client || g_initializing)
    return;
  g_initializing = true;
  nm_client_new_async(nullptr, nm_client_ready, nullptr);
}

inline QString gbyteToString(NMAccessPoint* ap) {
  GBytes* ssid = nm_access_point_get_ssid(ap);
  if (!ssid) return {};
  gsize len = 0;
  const guint8* data =
    static_cast<const guint8*>(g_bytes_get_data(ssid, &len));
  return QString::fromUtf8(reinterpret_cast<const char*>(data), len);
}

class Network : public QObject {
  Q_OBJECT
    Q_PROPERTY(bool active READ active WRITE setEnable NOTIFY activeChanged)
    Q_PROPERTY(QVariantList networks READ networks NOTIFY networksChanged)
    QML_ELEMENT
    QML_SINGLETON

  public:
    explicit Network(QObject* parent = nullptr);
    bool active() const;
    QVariantList networks() const;
    void setEnable(bool enabled) {
  if (!g_client)
    return;
  nm_client_dbus_set_property(
      g_client,
      "/org/freedesktop/NetworkManager",
      "org.freedesktop.NetworkManager",
      "WirelessEnabled",
      g_variant_new_boolean(enabled),
      -1,
      nullptr,
      nullptr,
      nullptr);
    }

Q_SIGNALS:
    void activeChanged();
    void networksChanged();
};
