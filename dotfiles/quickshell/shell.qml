import Quickshell
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
        anchors.fill: parent
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
        id: topBar
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
          Region {
            height: topBar.height
            width: barThingy.width
          }
          Region {
            height: barThingy.height
            width: leftBar.width
          }
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
          anchors.bottomMargin: -3
          ShapePath {
            property bool popUpControl: false
            id: mainBarfoo
            strokeColor: "#" + Colors.on_primary_fixed_variant
            fillColor: "#99" + Colors.primary
            strokeWidth: 3
            startX: 50; startY: 0;
            PathLine { relativeX: 0; relativeY: -(leftBar.height-topBar.height)-3+30+(-jotaro.relativeY)+(-doraemon.relativeY)+(-jodio.relativeY) }
            PathArc {
              relativeX: 30
              relativeY: -relativeX
              radiusX: 30
              radiusY: radiusX
            }
            PathLine {
              id: akuma
              relativeX: mainBarfoo.popUpControl ? 350:0
              relativeY: 0
              Behavior on relativeX {
                NumberAnimation {
                  alwaysRunToEnd: false
                  duration: 350
                  easing.type: Easing.InOutCubic
                }
              }
            }
            PathArc {
              id: jotaro
              direction: PathArc.Counterclockwise
              relativeX: 30
              relativeY: jodio.relativeY
              radiusX: jodio.radiusX
              radiusY: radiusX
            }
            PathLine {
              id: doraemon
              relativeX: 0
              relativeY: Math.min(akuma.relativeX, 200)*(-1)
            }
            PathArc {
              id: jodio
              relativeX: 30
              relativeY: Math.min(akuma.relativeX, 30)*(-1)
              radiusX: akuma.relativeX > 20 ? Math.min(akuma.relativeX, 30) : 0
              radiusY: radiusX
            }
            PathLine { relativeX: topBar.width-30-30-30-akuma.relativeX+3; relativeY: 0 }
            PathLine { relativeX: 0; relativeY: -topBar.height-3 }
            PathLine { relativeX: -barThingy.width*2; relativeY: 0 }
            PathLine { relativeX: 0; relativeY: barThingy.height+3 }
          }
        }
        Text {
          anchors.left: leftBar.left
          anchors.top: leftBar.top
          y: 5.8
          x: 5.8
          text: ""
          font.family: "icomoon"
          color: "#" + Colors.on_primary
          font.pointSize: 43
          MouseArea {
            hoverEnabled: true
            anchors.fill: parent
            onEntered: parent.color = "#" + Colors.on_secondary_fixed_variant
            onExited: parent.color = "#" + Colors.on_primary
            onClicked: mainBarfoo.popUpControl = !mainBarfoo.popUpControl
          }
        }
        Workspaces {
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.topMargin: 10
          anchors.leftMargin: 85
        }
      }
    }
  }
}
