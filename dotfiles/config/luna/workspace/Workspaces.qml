import Quickshell
import QtQuick
import Quickshell.Hyprland
import QtQuick.Shapes
import QtQuick.Layouts
import qs.colors

Rectangle {
  id: root
  property real prevWS: 0
  height: childrenRect.height
  width: Math.min(childrenRect.width, 294)
  color: "transparent"
  clip: true
  RowLayout {
    spacing: 6
    Repeater {
      id: wsRepeater
      model: Hyprland.workspaces.values[Hyprland.workspaces.values.length-1]?.id ?? 0
      Text {
        property bool beingHovered: false
        text: ""
        font.pointSize: 18
        font.family: "icomoon"
        opacity: x === activeWS.x ? 0 : 1
        font.bold: Hyprland.focusedWorkspace?.id !== index+1 && beingHovered
        color: Hyprland.focusedWorkspace?.id !== index+1 && beingHovered ? "#" + Color.colors.on_secondary_fixed_variant : "#" + Color.colors.on_primary
        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onEntered: beingHovered = true
          onExited: beingHovered = false
          onClicked: if (Hyprland.focusedWorkspace?.id !== index+1) Hyprland.dispatch(`workspace ${index+1}`)
        }
      }
    }
  }
  Text {
    id: activeWS
    text: ""
    font.pointSize: 18
    font.family: "icomoon"
    color: "#" + Color.colors.primary_fixed_dim
    x: wsRepeater.itemAt(Hyprland.focusedWorkspace?.id-1 ?? 0)?.x ?? 0
    Behavior on x {
      NumberAnimation {
        alwaysRunToEnd: false
        duration: 180
        easing.type: Easing.OutQuart
      }
    }
    onXChanged: root.prevWS = wsRepeater.itemAt(Hyprland.focusedWorkspace.id-1).x
    Loader {
      active: wsRepeater.itemAt(Hyprland.focusedWorkspace.id-1).x > activeWS.x
      asynchronous: true
      height: parent.height
      width: activeWS.x + Math.min(activeWS.x, activeWS.width/2)
      z: -1
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.rightMargin: 13
      sourceComponent: Rectangle {
        height: parent.height
        width: parent.width
        color: "transparent"
        Image {
          asynchronous: true
          anchors.bottom: parent.bottom
          anchors.right: parent.right
          height: parent.height
          width: parent.width
          source: "sparkle.png"
        }
      }
    }
    Loader {
      active: wsRepeater.itemAt(Hyprland.focusedWorkspace.id-1).x < activeWS.x
      asynchronous: true
      height: parent.height
      width: root.width - activeWS.x - Math.min(activeWS.x, activeWS.width/2)
      z: -1
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.leftMargin: 13
      sourceComponent: Rectangle {
        height: parent.height
        width: parent.width
        color: "transparent"
        Image {
          mirror: true
          asynchronous: true
          anchors.bottom: parent.bottom
          anchors.left: parent.left
          height: parent.height
          width: parent.width
          source: "sparkle.png"
        }
      }
    }
  }
}
