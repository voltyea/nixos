//Workspaces.qml
import Quickshell
import QtQuick
import Quickshell.Hyprland
import QtQuick.Shapes
import QtQuick.Layouts
import qs.colors

Rectangle {
  property int previousWorkspaceId: 0
  property real previousWorkspacePosition: 0
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
        font.bold: Hyprland.focusedWorkspace?.id !== index+1 && beingHovered ? true : false
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
    property real currentX: 0
    Behavior on x {
      NumberAnimation {
        alwaysRunToEnd: false
        duration: 190
        easing.type: Easing.OutQuart
      }
    }
    onXChanged: {
      if (Hyprland.focusedWorkspace.id > previousWorkspaceId) {
        leftTrailAnim.start()
      }
      else if (Hyprland.focusedWorkspace.id < previousWorkspaceId) {
        rightTrailAnim.start()
      }
      previousWorkspaceId=Hyprland.focusedWorkspace.id
      previousWorkspacePosition=wsRepeater.itemAt(Hyprland.focusedWorkspace.id-1).x
      leftTrail.width=0
      rightTrail.width=0
    }
    Rectangle {
      id: leftTrail
      height: parent.height
      width: 0
      z: -1
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.rightMargin: 13
      color: "transparent"
      NumberAnimation on width {
        id: leftTrailAnim
        running: false
        alwaysRunToEnd: false
        from: 0
        to: wsRepeater.itemAt(Hyprland.focusedWorkspace?.id-1 ?? 0)?.x-previousWorkspacePosition ?? 0
        duration: 90
        easing.type: Easing.OutBack
      }
      Image {
        asynchronous: true
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        height: parent.height
        width: parent.width
        source: "sparkle.png"
      }
    }
    Rectangle {
      id: rightTrail
      height: parent.height
      width: 0
      z: -1
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.leftMargin: 13
      color: "transparent"
      NumberAnimation on width {
        id: rightTrailAnim
        running: false
        alwaysRunToEnd: false
        from: 0
        to: previousWorkspacePosition-wsRepeater.itemAt(Hyprland.focusedWorkspace?.id-1 ?? 0)?.x ?? 0
        duration: 90
        easing.type: Easing.OutBack
      }
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
