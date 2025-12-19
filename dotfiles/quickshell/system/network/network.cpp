#include <iostream>
#include <map>
#include <vector>
#include <string>
#include <algorithm>
#include <cstdio>
#include <glib-2.0/glib.h>
#include <glib-2.0/gio/gio.h>
#include <NetworkManager.h>

struct WifiEntry {
  bool active = false;
  int signal = 0;
};

static std::map<std::string, WifiEntry> entries;
static std::vector<std::string> order;
static NMClient *client = nullptr;

static std::string json_escape(const std::string &s) {
  std::string out;
  for (unsigned char c : s) {
    switch (c) {
      case '\"': out += "\\\""; break;
      case '\\': out += "\\\\"; break;
      case '\n': out += "\\n"; break;
      case '\r': out += "\\r"; break;
      case '\t': out += "\\t"; break;
      default:
                 if (c < 0x20) continue;
                 out += c;
    }
  }
  return out;
}

static std::string ssid_from_ap(NMAccessPoint *ap) {
  GBytes *bytes = nm_access_point_get_ssid(ap);
  if (!bytes) return "";

  gsize len = 0;
  const guint8 *data =
    static_cast<const guint8*>(g_bytes_get_data(bytes, &len));

  if (!data || len == 0) return "";
  return std::string(reinterpret_cast<const char*>(data), len);
}

static void sort_by_signal() {
  std::sort(order.begin(), order.end(),
      [](const std::string &a, const std::string &b) {
      return entries[a].signal > entries[b].signal;
      });
}

static void redraw() {
  std::cout << "[";

  for (size_t i = 0; i < order.size(); i++) {
    const auto &ssid = order[i];
    const auto &e = entries[ssid];

    std::cout
      << "{"
      << "\"ssid\":\"" << json_escape(ssid) << "\","
      << "\"signalStrength\":" << e.signal << ","
      << "\"active\":" << (e.active ? "true" : "false")
      << "}";

    if (i + 1 < order.size())
      std::cout << ",";
  }

  std::cout << "]\n" << std::flush;
}

static void refresh_active() {
  for (auto &p : entries) p.second.active = false;

  NMActiveConnection *ac = nm_client_get_primary_connection(client);
  if (!ac) return;

  const GPtrArray *devs = nm_active_connection_get_devices(ac);
  if (!devs || devs->len == 0) return;

  NMDevice *dev = NM_DEVICE(devs->pdata[0]);
  if (!NM_IS_DEVICE_WIFI(dev)) return;

  NMAccessPoint *ap =
    nm_device_wifi_get_active_access_point(NM_DEVICE_WIFI(dev));
  if (!ap) return;

  std::string ssid = ssid_from_ap(ap);
  if (entries.count(ssid))
    entries[ssid].active = true;
}

static void update_ap(NMAccessPoint *ap) {
  std::string ssid = ssid_from_ap(ap);
  if (ssid.empty()) return;

  if (!entries.count(ssid))
    order.push_back(ssid);

  entries[ssid].signal = nm_access_point_get_strength(ap);
  sort_by_signal();
}

static void remove_ap(NMAccessPoint *ap) {
  std::string ssid = ssid_from_ap(ap);
  if (ssid.empty()) return;

  entries.erase(ssid);
  order.erase(std::remove(order.begin(), order.end(), ssid), order.end());
}

extern "C" void on_strength(GObject *obj, GParamSpec *, gpointer) {
  update_ap(NM_ACCESS_POINT(obj));
  redraw();
}

extern "C" void on_ap_added(NMDeviceWifi *, NMAccessPoint *ap, gpointer) {
  g_signal_connect(ap, "notify::strength", G_CALLBACK(on_strength), nullptr);
  update_ap(ap);
  refresh_active();
  redraw();
}

extern "C" void on_ap_removed(NMDeviceWifi *, NMAccessPoint *ap, gpointer) {
  remove_ap(ap);
  refresh_active();
  redraw();
}

extern "C" void on_active_changed(GObject *, GParamSpec *, gpointer) {
  refresh_active();
  redraw();
}

static void init() {
  const GPtrArray *devices = nm_client_get_devices(client);
  for (guint i = 0; i < devices->len; ++i) {
    NMDevice *dev = NM_DEVICE(devices->pdata[i]);
    if (!NM_IS_DEVICE_WIFI(dev)) continue;

    NMDeviceWifi *w = NM_DEVICE_WIFI(dev);
    g_signal_connect(w, "access-point-added", G_CALLBACK(on_ap_added), nullptr);
    g_signal_connect(w, "access-point-removed", G_CALLBACK(on_ap_removed), nullptr);
    g_signal_connect(w, "notify::active-access-point",
        G_CALLBACK(on_active_changed), nullptr);

    const GPtrArray *aps = nm_device_wifi_get_access_points(w);
    for (guint j = 0; j < aps->len; ++j) {
      NMAccessPoint *ap = NM_ACCESS_POINT(aps->pdata[j]);
      update_ap(ap);
      g_signal_connect(ap, "notify::strength", G_CALLBACK(on_strength), nullptr);
    }
  }

  g_signal_connect(client, "notify::primary-connection",
      G_CALLBACK(on_active_changed), nullptr);

  refresh_active();
  redraw();
}

int main() {
  GError *err = nullptr;
  client = nm_client_new(nullptr, &err);
  if (!client) {
    std::cerr << (err ? err->message : "NMClient error") << "\n";
    return 1;
  }

  init();

  GMainLoop *loop = g_main_loop_new(nullptr, FALSE);
  g_main_loop_run(loop);
}
