//@ pragma Env QS_NO_RELOAD_POPUP=1

import Quickshell
import QtQuick
import QtQuick.Shapes
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Pipewire

Variants {
  model: Quickshell.screens;
  delegate: Component {
    PanelWindow {
      required property var modelData
      screen: modelData
      aboveWindows: false
      exclusionMode: ExclusionMode.Ignore
      anchors.right: true
      anchors.left: true
      anchors.top: true
      anchors.bottom: true
      color: "transparent"

      PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
      }

      Image {
        asynchronous: true
        anchors.centerIn: parent
        anchors.fill: parent
        source: Quickshell.env("HOME") + "/.current_wallpaper"
        fillMode: Image.PreserveAspectCrop
        cache: false
      }
      LunarClock {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 50
        anchors.rightMargin: 50
      }
      PanelWindow {
        id: leftBar
        anchors.left: true
        anchors.top: true
        anchors.bottom: true
        implicitWidth: 45

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
        id: outsideRegion
        exclusionMode: ExclusionMode.Ignore
        anchors.right: true
        anchors.left: true
        anchors.top: true
        anchors.bottom: true
        margins.top: topBar.height
        margins.left: leftBar.width
        color: "transparent"
        MouseArea {
          hoverEnabled: true
          anchors.fill: parent
          onEntered: {
            mainBarfoo.popUpControl=false
          }
        }
        mask: Region {
          intersection: mainBarfoo.popUpControl ? Intersection.Subtract : Intersection.Combine
          Region {
            height: -doraemon.relativeY+(-jotaro.radiusY)+(-jodio.radiusY)
            width: akuma.relativeX+jotaro.radiusX+jodio.radiusX
          }
        }
      }
      PanelWindow {
        id: barThingy
        focusable: mainBarfoo.popUpControl ? true : false
        WlrLayershell.namespace: "qsBar"
        mask: Region {
          Region {
            height: topBar.height
            width: barThingy.width
          }
          Region {
            height: barThingy.height
            width: leftBar.width
          }
          Region {
            item: control
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
            startX: 45; startY: 0;
            PathLine { relativeX: 0; relativeY: -(leftBar.height-topBar.height)-3+30+(-jotaro.relativeY)+(-doraemon.relativeY)+(-jodio.relativeY) }
            PathArc {
              relativeX: 30
              relativeY: -relativeX
              radiusX: 30
              radiusY: radiusX
            }
            PathLine {
              id: akuma
              relativeX: mainBarfoo.popUpControl ? 380:0
              relativeY: 0
              Behavior on relativeX {
                NumberAnimation {
                  alwaysRunToEnd: false
                  duration: akuma.relativeX > 0 ? 300 : 400
                  easing.type: akuma.relativeX > 0 ? Easing.InOutCubic : Easing.OutBack
                }
              }
            }
            PathArc {
              id: jotaro
              direction: PathArc.Counterclockwise
              relativeX: Math.min(akuma.relativeX, 30)
              relativeY: -relativeX
              radiusX: -relativeY
              radiusY: -radiusX
            }
            PathLine {
              id: doraemon
              relativeX: 0
              relativeY: Math.min(akuma.relativeX, 220)*(-1)
            }
            PathArc {
              id: jodio
              relativeX: jotaro.relativeX
              relativeY: -relativeX
              radiusX: -relativeY
              radiusY: -radiusX
            }
            PathLine { relativeX: barThingy.width-30-jotaro.relativeX-jodio.relativeX-akuma.relativeX+20; relativeY: 0 }
            PathLine { relativeX: 0; relativeY: -topBar.height-3 }
            PathLine { relativeX: -barThingy.width*2; relativeY: 0 }
            PathLine { relativeX: 0; relativeY: barThingy.height+3 }
          }
        }
        Text {
          id: logoText
          property bool beingHovered: false
          property bool beingHovered2: false
          y: 5
          x: 5
          text: ""
          font.family: "icomoon"
          color: beingHovered ? "#" + Colors.on_secondary_fixed_variant : "#" + Colors.on_primary
          font.pointSize: beingHovered ? 40.3 : 40
          MouseArea {
            hoverEnabled: true
            anchors.fill: parent
            onExited: parent.beingHovered=false
            onEntered: {
              parent.beingHovered=true
              showTimer.start()
            }
            Timer {
              id: showTimer
              interval: 300
              running: false
              onTriggered: mainBarfoo.popUpControl=true
            }
          }
        }
        Workspaces {
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.topMargin: 8
          anchors.leftMargin: 85
        }
        Text {
          y: 2
          anchors.horizontalCenter: parent.horizontalCenter
          text: ""
          font.family: "icomoon"
          color: "#" + Colors.on_primary
          font.pointSize: 28
          Rectangle {
            anchors.centerIn: parent
            height: 42
            width: 200
            radius: height/2
            color: "#" + Colors.on_secondary_fixed_variant
            opacity: 0.0
            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              onEntered: parent.opacity = 0.1
              onExited: parent.opacity = 0.0
            }
          }
        }
        Loader {
          id: control
          active: -doraemon.relativeY+(-jotaro.radiusY)+(-jodio.radiusY) === 0 && akuma.relativeX+jotaro.radiusX+jodio.radiusX === 0 ? false : true
          asynchronous: true
          source: "Control.qml"
          x: leftBar.width
          y: topBar.height
          height: -doraemon.relativeY+(-jotaro.radiusY)+(-jodio.radiusY)
          width: akuma.relativeX+jotaro.radiusX+jodio.radiusX
        }
        Osd {}
      }
    }
  }
}
