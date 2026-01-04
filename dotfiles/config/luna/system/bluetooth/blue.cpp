#include <dbus/dbus.h>
#include <libnotify/notify.h>
#include <glib.h>
#include <iostream>
#include <string>
#include <thread>
#include <atomic>

static DBusConnection* conn = nullptr;
static DBusMessage* pending_msg = nullptr;
static std::atomic<bool> response_sent(false);

void send_dbus_reply(bool accept) {
  if (!pending_msg || response_sent)
    return;

  DBusMessage* reply;
  if (accept) {
    reply = dbus_message_new_method_return(pending_msg);
  } else {
    reply = dbus_message_new_error(
        pending_msg,
        "org.bluez.Error.Rejected",
        "User rejected passkey"
        );
  }

  dbus_connection_send(conn, reply, nullptr);
  dbus_connection_flush(conn);

  dbus_message_unref(reply);
  dbus_message_unref(pending_msg);
  pending_msg = nullptr;
  response_sent = true;
}

void on_yes(NotifyNotification*, char*, gpointer) {
  send_dbus_reply(true);
}

void on_no(NotifyNotification*, char*, gpointer) {
  send_dbus_reply(false);
}

void show_notification(const std::string& device, uint32_t passkey) {
  NotifyNotification* n = notify_notification_new(
      "Bluetooth Pairing Request",
      ("Device:\n" + device +
       "\n\nPasskey: " + std::to_string(passkey)).c_str(),
      "bluetooth"
      );

  notify_notification_add_action(
      n, "yes", "Yes",
      NOTIFY_ACTION_CALLBACK(on_yes),
      nullptr, nullptr
      );

  notify_notification_add_action(
      n, "no", "No",
      NOTIFY_ACTION_CALLBACK(on_no),
      nullptr, nullptr
      );

  notify_notification_set_timeout(n, 30000);
  notify_notification_show(n, nullptr);
}

DBusHandlerResult agent_handler(
    DBusConnection*,
    DBusMessage* msg,
    void*) {

  if (dbus_message_is_method_call(
        msg, "org.bluez.Agent1", "RequestConfirmation")) {

    const char* device;
    uint32_t passkey;

    DBusError err;
    dbus_error_init(&err);

    dbus_message_get_args(
        msg, &err,
        DBUS_TYPE_OBJECT_PATH, &device,
        DBUS_TYPE_UINT32, &passkey,
        DBUS_TYPE_INVALID
        );

    pending_msg = dbus_message_ref(msg);
    response_sent = false;

    show_notification(device, passkey);
    return DBUS_HANDLER_RESULT_HANDLED;
  }

  return DBUS_HANDLER_RESULT_NOT_YET_HANDLED;
}

int main() {
  DBusError err;
  dbus_error_init(&err);

  conn = dbus_bus_get(DBUS_BUS_SYSTEM, &err);
  if (!conn) {
    std::cerr << "Failed to connect to system bus\n";
    return 1;
  }

  notify_init("Bluetooth Agent");

  static DBusObjectPathVTable vtable = {
    nullptr, agent_handler, nullptr, nullptr, nullptr, nullptr
  };

  dbus_connection_register_object_path(
      conn,
      "/test/agent",
      &vtable,
      nullptr
      );

  DBusMessage* msg = dbus_message_new_method_call(
      "org.bluez",
      "/org/bluez",
      "org.bluez.AgentManager1",
      "RegisterAgent"
      );

  const char* path = "/test/agent";
  const char* cap = "KeyboardDisplay";

  dbus_message_append_args(
      msg,
      DBUS_TYPE_OBJECT_PATH, &path,
      DBUS_TYPE_STRING, &cap,
      DBUS_TYPE_INVALID
      );

  dbus_connection_send(conn, msg, nullptr);
  dbus_message_unref(msg);

  msg = dbus_message_new_method_call(
      "org.bluez",
      "/org/bluez",
      "org.bluez.AgentManager1",
      "RequestDefaultAgent"
      );
  dbus_message_append_args(
      msg,
      DBUS_TYPE_OBJECT_PATH, &path,
      DBUS_TYPE_INVALID
      );
  dbus_connection_send(conn, msg, nullptr);
  dbus_message_unref(msg);

  while (dbus_connection_read_write_dispatch(conn, -1)) {}

  notify_uninit();
  return 0;
}
