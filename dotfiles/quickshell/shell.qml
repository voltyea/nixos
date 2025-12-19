//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma IconTheme WhiteSur-dark

import Quickshell
import QtQuick
import QtQuick.Shapes
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.notification
import qs.decor
import qs.decor.lunar_clock
import qs.osd
import qs.workspace
import qs.colors
import qs.menu

ShellRoot {
  id: root

  Process {
    command: ["bash", "-c", "echo ~/.current_wallpaper | entr matugen image ~/.current_wallpaper -t scheme-fruit-salad"]
    running: true
  }
  PwObjectTracker {
    objects: [ Pipewire.defaultAudioSink ]
  }

  Variants {
    model: Quickshell.screens
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

        Image {
          id: wall
          asynchronous: true
          anchors.centerIn: parent
          anchors.fill: parent
          source: Quickshell.env("HOME") + "/.current_wallpaper"
          fillMode: Image.PreserveAspectCrop
          retainWhileLoading: true
          Connections {
            target: Color
            function onImageChanged() {
              wall.source=""
              wall.source=Quickshell.env("HOME") + "/.current_wallpaper"
            }
          }
        }
      }
    }
  }

  PanelWindow {
    aboveWindows: false
    exclusionMode: ExclusionMode.Ignore
    anchors.right: true
    anchors.left: true
    anchors.top: true
    anchors.bottom: true
    color: "transparent"

    Shangles {}

    LunarClock {
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.rightMargin: 50
      anchors.bottomMargin: 50
    }
  }

  PanelWindow {
    id: leftBar
    anchors.left: true
    anchors.top: true
    anchors.bottom: true
    implicitWidth: 40

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
        mainBarfoo.popUpMenu=false
      }
    }
    mask: Region {
      intersection: mainBarfoo.popUpMenu ? Intersection.Subtract : Intersection.Combine
      Region {
        height: -doraemon.relativeY+(-jotaro.radiusY)+(-jodio.radiusY)
        width: akuma.relativeX+jotaro.radiusX+jodio.radiusX
      }
    }
  }

  PanelWindow {
    id: barThingy
    focusable: mainBarfoo.popUpMenu ? true : false
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
        item: menu
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
        id: mainBarfoo
        property bool popUpMenu: false
        strokeColor: "#" + Color.colors.on_primary_fixed_variant
        fillColor: "#99" + Color.colors.primary
        strokeWidth: 3
        startX: leftBar.width; startY: 0
        PathLine { relativeX: 0; relativeY: -(leftBar.height-topBar.height)-3+30+(-jotaro.relativeY)+(-doraemon.relativeY)+(-jodio.relativeY) }
        PathArc {
          relativeX: 30
          relativeY: -relativeX
          radiusX: 30
          radiusY: radiusX
        }
        PathLine {
          id: akuma
          relativeX: mainBarfoo.popUpMenu ? 380:0
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
      y: 4.4
      x: 4.4
      text: ""
      font.family: "icomoon"
      color: beingHovered ? "#" + Color.colors.on_secondary_fixed_variant : "#" + Color.colors.on_primary
      font.pointSize: beingHovered ? 36 : 35.5
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
          onTriggered: mainBarfoo.popUpMenu=true
        }
      }
    }
    Workspaces {
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.topMargin: 5.7
      anchors.leftMargin: 75
    }
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: ""
      font.family: "icomoon"
      color: "#" + Color.colors.on_primary
      font.pointSize: 26
      Rectangle {
        anchors.centerIn: parent
        height: topBar.height
        width: 200
        radius: height/2
        color: "#" + Color.colors.on_secondary_fixed_variant
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
      id: menu
      active: -doraemon.relativeY+(-jotaro.radiusY)+(-jodio.radiusY) === 0 && akuma.relativeX+jotaro.radiusX+jodio.radiusX === 0 ? false : true
      asynchronous: true
      source: "menu/Menu.qml"
      x: leftBar.width
      y: topBar.height
      height: -doraemon.relativeY+(-jotaro.radiusY)+(-jodio.radiusY)
      width: akuma.relativeX+jotaro.radiusX+jodio.radiusX
    }
    Osd {}

    Notification {
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.topMargin: topBar.height
    }
  }

}
