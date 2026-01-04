#include "network.h"

Network::Network(QObject* parent) : QObject(parent) {
    init_nm_client_async();
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
  const GPtrArray* devices = nm_client_get_devices(g_client);
  for (guint i = 0; i < devices->len; ++i) {
    NMDevice* device = NM_DEVICE(devices->pdata[i]);
    if (!NM_IS_DEVICE_WIFI(device))
      continue;
    NMDeviceWifi* wifi = NM_DEVICE_WIFI(device);
    NMAccessPoint* active_ap = nm_device_wifi_get_active_access_point(wifi);
    const GPtrArray* aps = nm_device_wifi_get_access_points(wifi);
    for (guint j = 0; j < aps->len; ++j) {
      NMAccessPoint* ap = NM_ACCESS_POINT(aps->pdata[j]);
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
      nullptr);
}
