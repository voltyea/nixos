#include <iostream>
#include <glib.h>
#include <gio/gio.h>
#include <NetworkManager.h>

static NMClient *client = nullptr;

static void print_state() {
  bool enabled = nm_client_wireless_get_enabled(client);
  std::cout << (enabled ? "true\n" : "false\n") << std::flush;
}

extern "C" void on_wireless_changed(GObject *, GParamSpec *, gpointer) {
  print_state();
}

int main() {
  GError *err = nullptr;

  client = nm_client_new(nullptr, &err);
  if (!client) {
    std::cerr << (err ? err->message : "NMClient error") << "\n";
    return 1;
  }

  print_state();

  g_signal_connect(
      client,
      "notify::wireless-enabled",
      G_CALLBACK(on_wireless_changed),
      nullptr
      );

  GMainLoop *loop = g_main_loop_new(nullptr, FALSE);
  g_main_loop_run(loop);
}
