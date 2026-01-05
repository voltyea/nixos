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
  if (!ssid) return "hidden";
  gsize len = 0;
  const guint8 *data = static_cast<const guint8*>(g_bytes_get_data(ssid, &len));
  return QString::fromUtf8(reinterpret_cast<const char*>(data), len);
}

QString AccessPoint::ssid() const {
  return gbyteToString(m_ap);
}

int AccessPoint::strength() const {
  return nm_access_point_get_strength(m_ap);
}

bool AccessPoint::active() const {
  return m_active;
}

void AccessPoint::connect(const QString &password) {
  if (!g_client)
    return;

  NMConnection *connection = nm_simple_connection_new();

  NMSettingWireless *wifi =
    NM_SETTING_WIRELESS(nm_setting_wireless_new());
  nm_connection_add_setting(connection, NM_SETTING(wifi));

  QByteArray ssidUtf8 = ssid().toUtf8();
  GBytes *ssidBytes =
    g_bytes_new(ssidUtf8.constData(), ssidUtf8.size());
  g_object_set(wifi, NM_SETTING_WIRELESS_SSID, ssidBytes, nullptr);
  g_bytes_unref(ssidBytes);

  NMSettingWirelessSecurity *sec =
    NM_SETTING_WIRELESS_SECURITY(nm_setting_wireless_security_new());
  g_object_set(
      sec,
      NM_SETTING_WIRELESS_SECURITY_KEY_MGMT,
      "wpa-psk",
      NM_SETTING_WIRELESS_SECURITY_PSK,
      password.toUtf8().constData(),
      nullptr
      );
  nm_connection_add_setting(connection, NM_SETTING(sec));

  nm_client_add_and_activate_connection_async(
      g_client,
      connection,
      NM_DEVICE(m_wifi),
      nullptr,
      nullptr,
      nullptr,
      nullptr
      );
}

void AccessPoint::disconnect() {
  if (!g_client || !m_wifi)
    return;
  NMActiveConnection *active =
    nm_device_get_active_connection(NM_DEVICE(m_wifi));

  if (!active)
    return;
  nm_client_deactivate_connection_async(
      g_client,
      active,
      nullptr,
      nullptr,
      nullptr
      );
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

AccessPoint::AccessPoint(
    NMDeviceWifi *wifi,
    NMAccessPoint *ap,
    bool isActive,
    QObject *parent
    )
  : QObject(parent),
  m_wifi(wifi),
  m_ap(ap),
  m_active(isActive) {}

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

      NMAccessPoint *active_ap =
        nm_device_wifi_get_active_access_point(wifi);
      const GPtrArray *aps = nm_device_wifi_get_access_points(wifi);

      for (guint j = 0; j < aps->len; ++j) {
        NMAccessPoint *ap = NM_ACCESS_POINT(aps->pdata[j]);
        connect_ap_signals(ap, const_cast<Network*>(this));

        auto *obj = new AccessPoint(
            wifi,
            ap,
            ap == active_ap,
            const_cast<Network*>(this)
            );

        result.append(QVariant::fromValue(obj));
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
