import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import QtQuick.Controls
import Quickshell.Io
import Quickshell.Bluetooth

Rectangle {
  id: parentRectangle
  clip: true
  Component.onCompleted: brightnessSliderTip.x=Brightness.currentBrightness/Brightness.maxBrightness*brightnessSlider.width
  color: "transparent"

  BluetoothControl {
    id: bluetoothControl
    anchors.right: parent.right
    height: parent.height
    width: 0
  }

  NetworkControl {
    id: networkControl
    anchors.right: bluetoothControl.left
    height: parent.height
    width: 0
  }

  Rectangle {
    anchors.right: networkControl.left
    height: parent.height
    width: parent.width
    color: "transparent"
    Rectangle {
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.topMargin: 8
      anchors.rightMargin: 10
      height: 40
      width: height
      radius: width/2
      color: "#" + Color.colors.primary
    }
    GridLayout {
      anchors.top: parent.top
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.topMargin: 55
      columnSpacing: 10
      rowSpacing: 10
      columns: 2
      Rectangle {
        height: 60
        width: 200
        radius: height/2
        color: "#" + Color.colors.primary
        Rectangle {
          anchors.right: parent.right
          height: parent.height
          width: 30
          topRightRadius: parent.radius
          bottomRightRadius: parent.radius
          color: "transparent"
          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: arrow.color="#" + Color.colors.on_secondary_fixed_variant
            onExited: arrow.color="#" + Color.colors.on_primary
            onClicked: networkControl.width=parentRectangle.width
          }
          Text {
            id: arrow
            anchors.centerIn: parent
            text: "<b>⟩</b>"
            font.family: "SF Pro Rounded"
            color: "#" + Color.colors.on_primary
            font.pointSize: 20
            z: -1
          }
          Rectangle {
            anchors.right: parent.left
            height: 50
            width: 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: -width/2
            radius: width/2
            color: "#" + Color.colors.on_primary
          }
        }
        Rectangle {
          height: 35
          width: height
          radius: height/2
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          anchors.leftMargin: 4
          color: "transparent"
          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.color="#1a" + Color.colors.on_secondary_fixed_variant
            onExited: parent.color="transparent"
            onClicked: Network.wifiEnabled ? Quickshell.execDetached(["nmcli", "radio", "wifi", "off"]) : Quickshell.execDetached(["nmcli", "radio", "wifi", "on"])
          }
          Text {
            anchors.centerIn: parent
            text: ""
            font.family: "icomoon"
            color: "#" + Color.colors.outline
            font.pointSize: 20
            z: -1
            Text {
              anchors.centerIn: parent
              text: !Network.wifiEnabled ? "" : Network.activeSignalStrength < 33.33 ? "" : Network.activeSignalStrength >= 33.33 && Network.activeSignalStrength < 66.66 ? "" : ""
              font.family: "icomoon"
              color: "#" + Color.colors.on_primary
              font.pointSize: 20
            }
          }
        }
        AutoFitText {
          anchors.centerIn: parent
          anchors.horizontalCenterOffset: 4
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          width: 100
          maxFontSize: 19
          minFontSize: 9
          text: Network.activeSsid === "" ? "Wifi" : Network.activeSsid
          color: "#" + Color.colors.on_primary
          fontFamily: "SF Pro Rounded"
          bold: true
        }
      }
      Rectangle {
        height: 60
        width: 200
        radius: height/2
        color: "#" + Color.colors.primary
      }
      Rectangle {
        height: 60
        width: 200
        radius: height/2
        color: "#" + Color.colors.primary
        Rectangle {
          anchors.right: parent.right
          height: parent.height
          width: 30
          topRightRadius: parent.radius
          bottomRightRadius: parent.radius
          color: "transparent"
          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: arrow0.color="#" + Color.colors.on_secondary_fixed_variant
            onExited: arrow0.color="#" + Color.colors.on_primary
            onClicked: {
              bluetoothControl.width=parentRectangle.width
              Bluetooth.defaultAdapter.discoverable=true
              Bluetooth.defaultAdapter.discoverableTimeout=10
              Bluetooth.defaultAdapter.discovering=true
            }
          }
          Text {
            id: arrow0
            anchors.centerIn: parent
            text: "<b>⟩</b>"
            font.family: "SF Pro Rounded"
            color: "#" + Color.colors.on_primary
            font.pointSize: 20
            z: -1
          }
          Rectangle {
            anchors.right: parent.left
            height: 50
            width: 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: -width/2
            radius: width/2
            color: "#" + Color.colors.on_primary
          }
        }
        Rectangle {
          height: 35
          width: height
          radius: height/2
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          anchors.leftMargin: 4
          color: "transparent"
          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.color="#1a" + Color.colors.on_secondary_fixed_variant
            onExited: parent.color="transparent"
            onClicked: Bluetooth.defaultAdapter.enabled=!Bluetooth.defaultAdapter.enabled
          }
          Text {
            anchors.centerIn: parent
            text: Bluetooth.defaultAdapter.enabled ? "󰂯" : "󰂲"
            font.family: "Symbols Nerd Font"
            color: "#" + Color.colors.on_primary
            font.pointSize: 20
          }
        }
        AutoFitText {
          anchors.centerIn: parent
          anchors.horizontalCenterOffset: 3
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          width: 100
          maxFontSize: 19
          minFontSize: 8
          text: Bluetooth.defaultAdapter.devices.values.length === 0 ? "Bluetooth" : Bluetooth.defaultAdapter.devices.values[0].connected ? Bluetooth.defaultAdapter.devices.values[0].name : "Bluetooth"
          color: "#" + Color.colors.on_primary
          fontFamily: "SF Pro Rounded"
          bold: true
        }
      }
      Rectangle {
        height: 60
        width: 200
        radius: height/2
        color: "#" + Color.colors.primary
      }
    }
    ColumnLayout {
      spacing: 10
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      RowLayout {
        spacing: 30
        Text {
          text: "󰃠"
          color: "#" + Color.colors.on_primary
          font.pointSize: 20
          font.family: "Symbols Nerd Font"
          rotation: brightnessSliderTip.x
        }
        Rectangle {
          id: brightnessSlider
          width: 280
          height: 8
          color: "#" + Color.colors.primary
          radius: height/2
          Rectangle {
            radius: height/2
            anchors.left: parent.left
            anchors.right: brightnessSliderTip.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: "#" + Color.colors.on_primary
          }
          Rectangle {
            id: brightnessSliderTip
            property bool isPressed: false
            readonly property real xPosition: x/brightnessSlider.width*100
            height: 20
            width: height
            radius: height/2
            anchors.verticalCenter: parent.verticalCenter
            onXChanged: if (brightnessSliderTip.isPressed) {
              Quickshell.execDetached(["brightnessctl", "set", brightnessSliderTip.xPosition+"%"])
            }
            MouseArea {
              anchors.fill: parent
              drag.target: parent
              drag.minimumX: 0
              drag.maximumX: brightnessSlider.width
              onPressed: brightnessSliderTip.isPressed=true
              onReleased: brightnessSliderTip.isPressed=false
            }
          }
        }
      }
      RowLayout {
        spacing: 30
        Text {
          text: Pipewire.defaultAudioSink.audio.muted ? "" : ""
          color: "#" + Color.colors.on_primary
          font.pointSize: 17.5
          font.family: "Symbols Nerd Font"
          MouseArea {
            anchors.fill: parent
            onClicked: Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted
          }
        }
        Rectangle {
          id: volumeSlider
          width: 280
          height: 8
          color: "#" + Color.colors.primary
          radius: height/2
          Rectangle {
            radius: height/2
            anchors.left: parent.left
            anchors.right: volumeSliderTip.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: "#" + Color.colors.on_primary
          }
          Rectangle {
            id: volumeSliderTip
            height: 20
            width: height
            radius: height/2
            anchors.verticalCenter: parent.verticalCenter
            x: Pipewire.defaultAudioSink.audio.volume*volumeSlider.width
            onXChanged: Pipewire.defaultAudioSink.audio.volume=x/volumeSlider.width
            MouseArea {
              anchors.fill: parent
              drag.target: parent
              drag.minimumX: 0
              drag.maximumX: volumeSlider.width
            }
          }
        }
      }
    }
  }
}
