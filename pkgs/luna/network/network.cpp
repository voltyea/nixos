#include "network.h"
#include <iostream>
#include <NetworkManager.h>
#include <QList>

Network::Network(QObject *parent) : QObject(parent) {
}

static NMClient* get_nm_client() {
  static NMClient* client = nullptr;
  static bool initialized = false;
  if (!initialized) {
    initialized = true;
    GError* error = nullptr;
    client = nm_client_new(nullptr, &error);
    if (!client) {
      if (error) g_error_free(error);
    }
  }
  return client;
}

bool Network::active() const {
  NMClient* client = get_nm_client();
  if (!client) return false;
  return nm_client_wireless_get_enabled(client);
}

QList<AccessPointInfo> Network::networks() const {
  QList<AccessPointInfo> result;
  NMClient* client = get_nm_client();
  if (!client) return result;
  const GPtrArray* devices = nm_client_get_devices(client);
  for (int i = 0; i < devices->len; ++i) {
    NMDevice* device = NM_DEVICE(devices->pdata[i]);
    if (!NM_IS_DEVICE_WIFI(device))
      continue;
    NMDeviceWifi* wifi = NM_DEVICE_WIFI(device);
    NMAccessPoint* active_ap =
      nm_device_wifi_get_active_access_point(wifi);
    const GPtrArray* aps =
      nm_device_wifi_get_access_points(wifi);
    for (int j = 0; j < aps->len; ++j) {
      NMAccessPoint* ap = NM_ACCESS_POINT(aps->pdata[j]);
      result.push_back({
          static_cast<int>(nm_access_point_get_strength(ap)),
          ap == active_ap
          });
    }
  }
  return result;
}
