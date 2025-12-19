import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Bluetooth
import Quickshell.Widgets
import QtQuick.Effects
import qs.widgets
import qs.colors

Rectangle {
  id: bluetooth
  clip: true
  color: "transparent"
  Behavior on width {
    NumberAnimation {
      alwaysRunToEnd: false
      duration: 200
      easing.type: Easing.InOutQuart
    }
  }
  Rectangle {
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.topMargin: 8
    anchors.leftMargin: 10
    height: 40
    width: height
    radius: width/2
    color: "#" + Color.colors.primary
    Text {
      anchors.centerIn: parent
      text: ""
      font.family: "Symbols Nerd Font"
      color: "#" + Color.colors.on_primary
      font.pointSize: 20
    }
    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onEntered: parent.color="#1a" + Color.colors.on_secondary_fixed_variant
      onExited: parent.color="#" + Color.colors.primary
      onClicked: bluetoothInfo.width > 0 ? bluetoothInfo.width=0 : bluetooth.width=0
    }
  }
  Rectangle {
    id: bluetoothInfo
    property bool paired: false
    property bool connected: false
    property bool trusted: false
    property string deviceName: ""
    signal attemptedToConnect()
    signal attemptedToDisconnect()
    signal attemptedToPair()
    signal attemptedToForget()
    signal attemptedToTrust()
    signal attemptedToMistrust()
    anchors.right: parent.right
    height: parent.height
    width: 0
    clip: true
    color: "transparent"
    Behavior on width {
      NumberAnimation {
        alwaysRunToEnd: false
        duration: 200
        easing.type: Easing.InOutQuart
      }
    }
    IconImage {
      id: bluetoothInfoIcon
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      anchors.topMargin: 55
      asynchronous: true
      implicitSize: 40
      MultiEffect {
        source: parent
        anchors.fill: parent
        colorization: 1.0
        colorizationColor: "#" + Color.colors.on_primary
      }
    }
    AutoFitText {
      id: bluetoothInfoText
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.horizontalCenterOffset: 6
      anchors.top: parent.top
      anchors.topMargin: 30
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      width: 200
      maxFontSize: 30
      minFontSize: 9
      color: "#" + Color.colors.on_primary
      fontFamily: "SF Pro Rounded"
      bold: true
    }
    ColumnLayout {
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 10
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.horizontalCenterOffset: 13
      spacing: 5
      Repeater {
        model: 3
        Rectangle {
          property bool beingHovered: false
          height: 50
          width: 350
          radius: height/2
          color: beingHovered ? "#1a" + Color.colors.on_secondary_fixed_variant : "#" + Color.colors.primary
          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.beingHovered=true
            onExited: parent.beingHovered=false
            onClicked: [
              bluetoothInfo.connected ? bluetoothInfo.attemptedToDisconnect() : bluetoothInfo.attemptedToConnect(),
              bluetoothInfo.paired ? bluetoothInfo.attemptedToForget() : bluetoothInfo.attemptedToPair(),
              bluetoothInfo.trusted ? bluetoothInfo.attemptedToMistrust() : bluetoothInfo.attemptedToTrust()
            ][index]
          }
          Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 20
            text: [
              bluetoothInfo.connected ? "Disconnect" : "Connect",
              bluetoothInfo.paired ? "Forget" : "Pair",
              bluetoothInfo.trusted ? "Mistrust" : "Trust"
            ][index]
            font.pointSize: 17
            font.family: "SF Pro Rounded"
            color: "#" + Color.colors.on_primary
            font.bold: true
          }
        }
      }
    }
  }
  Rectangle {
    anchors.right: bluetoothInfo.left
    height: parent.height
    width: parent.width
    color: "transparent"
    ScrollView {
      anchors.centerIn: parent
      anchors.horizontalCenterOffset: 20
      width: childrenRect.implicitWidth
      height: parent.height-65
      ColumnLayout {
        spacing: 5
        Repeater {
          model: Bluetooth.defaultAdapter.devices
          Rectangle {
            property bool beingHovered: false
            property bool isConnected: modelData.connected
            property bool isPaired: modelData.paired
            property bool isTrusted: modelData.trusted
            onIsConnectedChanged: bluetoothInfo.connected=modelData.connected
            onIsPairedChanged: bluetoothInfo.paired=modelData.paired
            onIsTrustedChanged: bluetoothInfo.trusted=modelData.trusted
            height: 50
            width: 350
            radius: height/2
            color: beingHovered ? "#1a" + Color.colors.on_secondary_fixed_variant : modelData.connected ? "#" + Color.colors.inverse_primary : "#" + Color.colors.primary
            Connections {
              target: bluetoothInfo
              function handle(action) {
                if (modelData.deviceName === bluetoothInfo.deviceName)
                action()
              }
              function onAttemptedToConnect()    { handle(() => modelData.connect()) }
              function onAttemptedToDisconnect() { handle(() => modelData.disconnect()) }
              function onAttemptedToPair()       { handle(() => modelData.pair()) }
              function onAttemptedToForget()     { handle(() => modelData.forget()) }
              function onAttemptedToTrust()      { handle(() => modelData.trusted = true) }
              function onAttemptedToMistrust()   { handle(() => modelData.trusted = false) }
            }
            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              onEntered: parent.beingHovered=true
              onExited: parent.beingHovered=false
              onClicked: {
                bluetoothInfo.width=bluetooth.width
                bluetoothInfoText.text=modelData.name
                bluetoothInfo.deviceName=modelData.deviceName
                bluetoothInfoIcon.source=Quickshell.iconPath(modelData.icon, true)
                bluetoothInfo.connected=modelData.connected
                bluetoothInfo.paired=modelData.paired
                bluetoothInfo.trusted=modelData.trusted
              }
            }
            AutoFitText {
              anchors.centerIn: parent
              anchors.horizontalCenterOffset: 4
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
              width: 100
              maxFontSize: 20
              minFontSize: 9
              text: modelData.name
              color: modelData.connected ? "#" + Color.colors.primary : "#" + Color.colors.on_primary
              fontFamily: "SF Pro Rounded"
              bold: true
            }
            IconImage {
              anchors.left: parent.left
              anchors.leftMargin: 20
              anchors.verticalCenter: parent.verticalCenter
              asynchronous: true
              source: Quickshell.iconPath(modelData.icon, true)
              implicitSize: 25
              MultiEffect {
                source: parent
                anchors.fill: parent
                colorization: 1.0
                colorizationColor: "#" + Color.colors.on_primary
              }
            }
          }
        }
      }
    }
  }
}
