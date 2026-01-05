#include "network.h"
#include <QMetaObject>

static NMClient *g_client = nullptr;
static bool g_initializing = false;

static void wireless_enabled_notify(
    GObject*,
    GParamSpec*,
    gpointer user_data
    ) {
  auto *network = static_cast<Network*>(user_data);
  QMetaObject::invokeMethod(
      network,
      "activeChanged",
      Qt::QueuedConnection
      );
}

static void networks_changed_notify(
    GObject*,
    GParamSpec*,
    gpointer user_data
    ) {
  auto *network = static_cast<Network*>(user_data);
  QMetaObject::invokeMethod(
      network,
      "networksChanged",
      Qt::QueuedConnection
      );
}

static void connect_ap_signals(
    NMAccessPoint *ap,
    Network *network
    ) {
  if (g_object_get_data(G_OBJECT(ap), "qt-connected"))
    return;
  g_signal_connect(
      ap,
      "notify::strength",
      G_CALLBACK(networks_changed_notify),
      network
      );
  g_object_set_data(G_OBJECT(ap), "qt-connected", GINT_TO_POINTER(1));
}

static void connect_wifi_signals(
    NMDeviceWifi *wifi,
    Network *network
    ) {
  if (g_object_get_data(G_OBJECT(wifi), "qt-connected"))
    return;
  g_signal_connect(
      wifi,
      "access-point-added",
      G_CALLBACK(networks_changed_notify),
      network
      );
  g_signal_connect(
      wifi,
      "access-point-removed",
      G_CALLBACK(networks_changed_notify),
      network
      );
  g_object_set_data(G_OBJECT(wifi), "qt-connected", GINT_TO_POINTER(1));
}

static void nm_client_ready(
    GObject*,
    GAsyncResult *result,
    gpointer user_data
    ) {
  GError *error = nullptr;
  g_client = nm_client_new_finish(result, &error);

  if (!g_client) {
    if (error)
      g_error_free(error);
    g_initializing = false;
    return;
  }

  auto *network = static_cast<Network*>(user_data);

  g_signal_connect(
      g_client,
      "notify::wireless-enabled",
      G_CALLBACK(wireless_enabled_notify),
      network
      );

  g_signal_connect(
      g_client,
      "notify::active-connection",
      G_CALLBACK(networks_changed_notify),
      network
      );

  g_initializing = false;

  QMetaObject::invokeMethod(
      network,
      "activeChanged",
      Qt::QueuedConnection
      );

  QMetaObject::invokeMethod(
      network,
      "networksChanged",
      Qt::QueuedConnection
      );
}

static void init_nm_client_async(Network *self) {
  if (g_client || g_initializing)
    return;

  g_initializing = true;
  nm_client_new_async(nullptr, nm_client_ready, self);
}

QString gbyteToString(NMAccessPoint *ap) {
  GBytes *ssid = nm_access_point_get_ssid(ap);
  if (!ssid) return {};
  gsize len = 0;
  const guint8 *data = static_cast<const guint8*>(g_bytes_get_data(ssid, &len));
  return QString::fromUtf8(reinterpret_cast<const char*>(data), len);
}

Network::Network(QObject *parent)
  : QObject(parent)
{
  init_nm_client_async(this);
}

bool Network::active() const {
  if (!g_client)
    return false;
  return nm_client_wireless_get_enabled(g_client);
}

QVariantList Network::networks() const {
  QVariantList result;
  if (!g_client)
    return result;
  const GPtrArray *devices = nm_client_get_devices(g_client);
  for (guint i = 0; i < devices->len; ++i) {
    NMDevice *device = NM_DEVICE(devices->pdata[i]);
    if (!NM_IS_DEVICE_WIFI(device))
      continue;
    NMDeviceWifi *wifi = NM_DEVICE_WIFI(device);
    connect_wifi_signals(wifi, const_cast<Network*>(this));
    NMAccessPoint *active_ap = nm_device_wifi_get_active_access_point(wifi);
    const GPtrArray *aps = nm_device_wifi_get_access_points(wifi);
    for (guint j = 0; j < aps->len; ++j) {
      NMAccessPoint *ap = NM_ACCESS_POINT(aps->pdata[j]);
      connect_ap_signals(ap, const_cast<Network*>(this));
      QVariantMap entry;
      entry["ssid"] = gbyteToString(ap);
      entry["strength"] =
        static_cast<int>(nm_access_point_get_strength(ap));
      entry["active"] = (ap == active_ap);
      result.append(entry);
    }
  }
  return result;
}

void Network::setEnable(bool enabled) {
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
      nullptr
      );
}
