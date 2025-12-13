import Quickshell
import QtQuick
import Quickshell.Services.Pipewire
import Quickshell.Wayland

Scope {
  Connections {
    target: Pipewire.defaultAudioSink?.audio
    function onVolumeChanged() {
      volumeLoader.active=true
      volumeLoader.item.volumeOpacity.restart()
    }
    function onMutedChanged() {
      volumeLoader.active=true
      volumeLoader.item.volumeOpacity.restart()
    }
  }
  Connections {
    target: Brightness
    function onCurrentBrightnessChanged() {
      brightnessLoader.active=true
      brightnessLoader.item.brightnessOpacity.restart()
    }
  }
  LazyLoader {
    id: brightnessLoader
    active: false
    PanelWindow {
      anchors.bottom: true
      margins.bottom: 100
      implicitHeight: 50
      implicitWidth: 250
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      color: "transparent"
      property alias brightnessOpacity: brightnessOpacity
      WlrLayershell.namespace: "brightnessLayer"
      Rectangle {
        id: brightness
        height: 50
        width: 250
        color: "#" + Color.colors.primary
        radius: height/2
        NumberAnimation on opacity {
          id: brightnessOpacity
          alwaysRunToEnd: true
          running: true
          from: 1
          to: 0
          duration: 1500
          easing.type: Easing.InQuint
          onFinished: brightnessLoader.active=false
        }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          anchors.left: parent.left
          anchors.leftMargin: 8
          text: "󰃠"
          color: "#" + Color.colors.on_primary
          font.pointSize: 20
          font.family: "Symbols Nerd Font"
          rotation: brightnessBar.width
        }
        Rectangle {
          anchors.centerIn: parent
          anchors.horizontalCenterOffset: 10
          height: 7
          width: 190
          radius: height/2
          color: "#" + Color.colors.inverse_primary
          Rectangle {
            id: brightnessBar
            height: parent.height
            width: Brightness.currentBrightness/Brightness.maxBrightness*parent.width
            radius: height/2
            color: "#" + Color.colors.on_primary
          }
        }
      }
    }
  }
  LazyLoader {
    id: volumeLoader
    active: false
    PanelWindow {
      anchors.bottom: true
      margins.bottom: 100
      implicitHeight: 50
      implicitWidth: 250
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      color: "transparent"
      property alias volumeOpacity: volumeOpacity
      WlrLayershell.namespace: "volumeLayer"
      Rectangle {
        id: volume
        height: 50
        width: 250
        color: "#" + Color.colors.primary
        radius: height/2
        NumberAnimation on opacity {
          id: volumeOpacity
          alwaysRunToEnd: false
          running: true
          from: 1
          to: 0
          duration: 1500
          easing.type: Easing.InQuint
          onFinished: volumeLoader.active=false
        }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          anchors.left: parent.left
          anchors.leftMargin: 8
          text: Pipewire.defaultAudioSink.audio.muted ? "" : ""
          color: "#" + Color.colors.on_primary
          font.pointSize: 17.5
          font.family: "Symbols Nerd Font"
        }
        Rectangle {
          anchors.centerIn: parent
          anchors.horizontalCenterOffset: 10
          height: 7
          width: 190
          radius: height/2
          color: "#" + Color.colors.inverse_primary
          Rectangle {
            id: volumeBar
            height: parent.height
            width: parent.width*(Pipewire.defaultAudioSink?.audio.volume ?? 0)
            radius: height/2
            color: "#" + Color.colors.on_primary
          }
        }
      }
    }
  }
}
