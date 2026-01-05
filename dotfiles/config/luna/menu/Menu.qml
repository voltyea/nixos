import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell.Services.Pipewire
import Quickshell.Bluetooth
import qs.colors
import Luna.Network
import qs.widgets
import qs.utils

Rectangle {
  id: root
  readonly property string activeSsid: {
    let item = Network.networks.find(e => e.active)
    return item ? item.ssid : ""
  }
  readonly property int activeStrength: {
    let item = Network.networks.find(e => e.active)
    return item ? item.strength : 0
  }
  clip: true
  Component.onCompleted: brightnessSliderTip.x=Brightness.currentBrightness/Brightness.maxBrightness*brightnessSlider.width
  color: "transparent"

  BluetoothMenu {
    id: bluetoothMenu
    anchors.right: parent.right
    height: parent.height
    width: 0
  }

  NetworkMenu {
    id: networkMenu
    anchors.right: bluetoothMenu.left
    height: parent.height
    width: 0
  }
  Rectangle {
    anchors.right: networkMenu.left
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
        id: some_rand_id
        height: 55
        width: 190
        radius: height/2
        color: "#" + Color.colors.primary
        Shape {
          id: arrow_shape
          property bool hovered: false
          height: parent.height
          width: 27.5
          asynchronous: true
          antialiasing: true
          smooth: true
          preferredRendererType: Shape.CurveRenderer
          anchors.right: parent.right
          ShapePath {
            fillColor: arrow_shape.hovered ? "#33" + Color.colors.on_primary_fixed_variant : "#00" + Color.colors.on_primary_fixed_variant
            strokeWidth: 0
            startX: 0; startY: 0
            PathArc {
              relativeX: 0
              relativeY: arrow_shape.height
              radiusX: 27.5
              radiusY: radiusX
            }
          }
          Text {
            anchors.centerIn: parent
            text: "<b>⟩</b>"
            font.family: "SF Pro Rounded"
            color: "#" + Color.colors.on_primary
            font.pointSize: 19
          }
          Rectangle {
            anchors.right: parent.left
            height: 45
            width: 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: -width/2
            radius: width/2
            color: "#" + Color.colors.on_primary
          }
          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: arrow_shape.hovered=true
            onExited: arrow_shape.hovered=false
            onClicked: networkMenu.width=root.width
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
            onClicked: Network.active = !Network.active
          }
          Text {
            anchors.centerIn: parent
            text: ""
            font.family: "icomoon"
            color: "#" + Color.colors.outline
            font.pointSize: 19
            z: -1
            Text {
              anchors.centerIn: parent
              text: !Network.active ? "" : root.activeStrength < 33.33 ? "" : root.activeStrength >= 33.33 && root.activeStrength < 66.66 ? "" : ""
              font.family: "icomoon"
              color: "#" + Color.colors.on_primary
              font.pointSize: 19
            }
          }
        }
        AutoFitText {
          anchors.centerIn: parent
          anchors.horizontalCenterOffset: 4
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          width: 95
          maxFontSize: 18
          minFontSize: 8
          text: root.activeSsid === "" ? "Wifi" : root.activeSsid
          color: "#" + Color.colors.on_primary
          fontFamily: "SF Pro Rounded"
          bold: true
        }
      }
      Rectangle {
        height: 55
        width: 190
        radius: height/2
        color: "#" + Color.colors.primary
      }
      Rectangle {
        height: 55
        width: 190
        radius: height/2
        color: "#" + Color.colors.primary
        Shape {
          id: arrow_shape0
          property bool hovered: false
          height: parent.height
          width: 27.5
          asynchronous: true
          antialiasing: true
          smooth: true
          preferredRendererType: Shape.CurveRenderer
          anchors.right: parent.right
          ShapePath {
            fillColor: arrow_shape0.hovered ? "#33" + Color.colors.on_primary_fixed_variant : "#00" + Color.colors.on_primary_fixed_variant
            strokeWidth: 0
            startX: 0; startY: 0
            PathArc {
              relativeX: 0
              relativeY: arrow_shape0.height
              radiusX: 27.5
              radiusY: radiusX
            }
          }
          Text {
            anchors.centerIn: parent
            text: "<b>⟩</b>"
            font.family: "SF Pro Rounded"
            color: "#" + Color.colors.on_primary
            font.pointSize: 19
          }
          Rectangle {
            anchors.right: parent.left
            height: 45
            width: 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: -width/2
            radius: width/2
            color: "#" + Color.colors.on_primary
          }
          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: arrow_shape0.hovered=true
            onExited: arrow_shape0.hovered=false
            onClicked: {
              bluetoothMenu.width=root.width
              Bluetooth.defaultAdapter.discoverable=true
              Bluetooth.defaultAdapter.discoverableTimeout=10
              Bluetooth.defaultAdapter.discovering=true
            }
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
            font.pointSize: 19
          }
        }
        AutoFitText {
          anchors.centerIn: parent
          anchors.horizontalCenterOffset: 3
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          width: 95
          maxFontSize: 18
          minFontSize: 7
          text: Bluetooth.defaultAdapter.devices.values.length === 0 ? "Bluetooth" : Bluetooth.defaultAdapter.devices.values[0].connected ? Bluetooth.defaultAdapter.devices.values[0].name : "Bluetooth"
          color: "#" + Color.colors.on_primary
          fontFamily: "SF Pro Rounded"
          bold: true
        }
      }
      Rectangle {
        height: 55
        width: 190
        radius: height/2
        color: "#" + Color.colors.primary
      }
    }
    ColumnLayout {
      spacing: 10
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      z: -1
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
