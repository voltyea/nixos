import Quickshell
import QtQuick
import Quickshell.Services.Notifications
import QtQuick.Layouts

Rectangle {
  id: parentRect
  height: childrenRect.height
  width: 300
  color: "transparent"
  NotificationServer {
    id: notificationServer
    onNotification: (notification) => {
      notification.tracked = true
    }
    bodyMarkupSupported: true
    bodyImagesSupported: true
    bodySupported: true
    bodyHyperlinksSupported: true
    keepOnReload: false
    actionIconsSupported: true
    inlineReplySupported: true
    actionsSupported: true
    persistenceSupported: true
    imageSupported: true
  }
  ListView {
    model: ScriptModel {
      values: [...notificationServer.trackedNotifications.values].reverse()
    }
    spacing: 0
    width: parentRect.width
    height: contentHeight
    add: Transition {
      NumberAnimation {
        property: "x"
        duration: 350
        from: parentRect.width
        easing.type: Easing.OutBack
      }
    }
    displaced: Transition {
      NumberAnimation {
        property: "y"
        duration: 350
        alwaysRunToEnd: false
        easing.type: Easing.OutBack
      }
    }
    delegate: Rectangle {
      height: 90+5+5
      width: parentRect.width-10
      color: "transparent"
      clip: true
      NumberAnimation on x {
        id: removeAnim
        duration: 350
        to: parentRect.width
        running: false
        easing.type: Easing.InBack
        onFinished: modelData.resident ? height=0 : modelData.expire()
      }
      Timer {
        interval: 5000
        running: true
        onTriggered: removeAnim.start()
      }
      Rectangle {
        height: parent.height-5-5
        width: parent.width
        anchors.centerIn: parent
        color: "#99" + Color.colors.primary
        border.width: 3
        border.color: "#" + Color.colors.on_primary_fixed_variant
        radius: 15
        clip: true
        Text {
          anchors.centerIn: parent
          text: modelData.summary
          color: "white"
          font.pointSize: 20
          font.family: "SF Pro Rounded"
        }
      }
    }
  }
}
