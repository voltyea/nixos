import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Shapes
import Quickshell.Hyprland
import Quickshell.Wayland

Variants {
  model: Quickshell.screens;
  delegate: Component {
    PanelWindow {
      id: parentWindow
      required property var modelData
      screen: modelData

      aboveWindows: false
      exclusionMode: ExclusionMode.Ignore

      anchors.right: true
      anchors.left: true
      anchors.top: true
      anchors.bottom: true

      color: "transparent"

      Image {
        asynchronous: true
        anchors.centerIn: parent
        height: parent.height
        width: parent.width
        source: Quickshell.env("HOME") + "/.current_wallpaper"
        fillMode: Image.PreserveAspectCrop
      }
      PanelWindow {
        id: leftBar
        anchors.left: true
        anchors.top: true
        anchors.bottom: true
        implicitWidth: 50

        color: "transparent"
      }
      PanelWindow {
        anchors.left: true
        anchors.top: true
        anchors.right: true
        implicitHeight: leftBar.width

        color: "transparent"
      }

      PanelWindow {
        id: barThingy
        WlrLayershell.namespace: "qsBar"
        mask: Region {
          height: parentWindow.implicitHeight
          width: parentWindow.implicitWidth
        }
        exclusionMode: ExclusionMode.Ignore
        anchors.left: true
        anchors.top: true
        anchors.right: true
        anchors.bottom: true
        color: "transparent"
        Shape {
          id: mainBar
          asynchronous: true
          antialiasing: true
          smooth: true
          preferredRendererType: Shape.CurveRenderer
          anchors.left: parent.left
          anchors.bottom: parent.bottom
          anchors.bottomMargin: -15
          ShapePath {
            strokeColor: "#" + Colors.inverse_primary
            fillColor: "#b2" + Colors.surface_tint
            strokeWidth: 3
            startX: 50; startY: 0;
            PathLine { relativeX: 0; relativeY: -barThingy.height+65 }
            PathArc {
              relativeX: 22
              relativeY: -27
              radiusX: 26
              radiusY: 26
            }
            PathLine { relativeX: barThingy.width; relativeY: 0 }
            PathLine { relativeX: 0; relativeY: -55 }
            PathLine { relativeX: -barThingy.width-75; relativeY: 0 }
            PathLine { relativeX: 0; relativeY: barThingy.height+5 }
          }
        }
        Text {
          anchors.left: leftBar.left
          anchors.top: leftBar.top
          y: 5.8
          x: 5.8
          text: ""
          font.family: "icomoon"
          color: "#" + Colors.on_primary_fixed
          font.pointSize: 43
          MouseArea {
            hoverEnabled: true
            anchors.fill: parent
            onEntered: parent.color = "#" + Colors.on_secondary_fixed_variant
            onExited: parent.color = "#" + Colors.on_primary_fixed
          }
        }
      }
    }
  }
}
