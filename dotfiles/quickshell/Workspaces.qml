//Workspaces.qml
import Quickshell
import QtQuick
import Quickshell.Hyprland
import QtQuick.Shapes

Rectangle {
  property int previousWorkspaceId: 0
  property real previousWorkspacePosition: 0
  height: childrenRect.height
  width: Math.min(childrenRect.width, 275.09375)
  color: "transparent"
  clip: true
  Row {
    spacing: 1
    Repeater {
      id: wsRepeater
      model: Hyprland.workspaces.values[Hyprland.workspaces.values.length-1].id
      Text {
        property bool beingHovered: false
        text: "󰫢"
        font.pointSize: 22
        font.family: "Symbols Nerd Font"
        color: beingHovered ? "#" + Colors.on_secondary_fixed_variant : "#" + Colors.on_primary
        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onEntered: beingHovered = true
          onExited: beingHovered = false
          onClicked: Hyprland.dispatch(`workspace ${index+1}`)
        }
      }
    }
  }
  Text {
    id: activeWS
    text: "󰫢"
    font.pointSize: 22
    font.family: "Symbols Nerd Font"
    color: "#" + Colors.primary_fixed_dim
    x: wsRepeater.itemAt(Hyprland.focusedWorkspace.id-1).x
    property real currentX: 0
    Behavior on x {
      NumberAnimation {
        alwaysRunToEnd: false
        duration: 90
        easing.type: Easing.OutCubic
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
        to: wsRepeater.itemAt(Hyprland.focusedWorkspace.id-1).x-previousWorkspacePosition
        duration: 60
        easing.type: Easing.Linear
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
        to: previousWorkspacePosition-wsRepeater.itemAt(Hyprland.focusedWorkspace.id-1).x
        duration: 60
        easing.type: Easing.Linear
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
