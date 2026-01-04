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

    Frills {}

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
    color: "transparent"
    MouseArea {
      hoverEnabled: true
      anchors.fill: parent
      onEntered: {
        logoText.opened=false
        menuOpenAnim.stop()
        menuCloseAnim.start()
      }
    }
    mask: Region {
      intersection: logoText.opened ? Intersection.Subtract : Intersection.Combine
      Region {
        item: menu
      }
    }
  }

  PanelWindow {
    id: barThingy
    focusable: logoText.opened ? true : false
    WlrLayershell.namespace: "luna"
    mask: Region {
      Region {
        height: topBar.height
        width: barThingy.width
      }
      Region {
        height: barThingy.height
        width: topBar.height
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
      id: barShape
      asynchronous: true
      antialiasing: true
      smooth: true
      height: barThingy.height
      containsMode: Shape.FillContains
      clip: true
      width: barThingy.width
      preferredRendererType: Shape.CurveRenderer
      ShapePath {
        id: barShapePath
        property int extra: topBar.height
        strokeColor: "#" + Color.colors.on_primary_fixed_variant
        fillColor: "#99" + Color.colors.primary
        capStyle: ShapePath.FlatCap
        strokeWidth: 3
        startX: -extra
        startY: startX
        PathLine {
          x: barThingy.width+barShapePath.extra
          y: 0
        }
        PathLine {
          relativeX: 0
          y: topBar.height
        }
        PathLine {
          relativeY: 0
          relativeX: -(barThingy.width-topBar.height-menu.width)
        }
        PathArc {
          direction: PathArc.Counterclockwise
          relativeY: Math.min(animLine.relativeY, topBar.height)
          relativeX: -relativeY
          radiusX: relativeY
          radiusY: radiusX
        }
        PathLine {
          id: animLine
          relativeY: 0
          NumberAnimation on relativeY {
            id: menuOpenAnim
            alwaysRunToEnd: false
            running: false
            duration: 350
            to: 192
            easing.type: Easing.OutBack
          }
          NumberAnimation on relativeY {
            id: menuCloseAnim
            alwaysRunToEnd: false
            running: false
            duration: 400
            to: 0
            easing.type: Easing.InBack
          }
          relativeX: 0
        }
        PathArc {
          relativeY: Math.min(animLine.relativeY, topBar.height)
          relativeX: -relativeY
          radiusX: relativeY
          radiusY: radiusX
        }
        PathLine {
          x: topBar.height*2
          relativeY: 0
        }
        PathArc {
          direction: PathArc.Counterclockwise
          relativeY: topBar.height
          relativeX: -relativeY
          radiusX: relativeY
          radiusY: radiusX
        }
        PathLine {
          relativeX: 0
          y: barThingy.height+barShapePath.extra
        }
        PathLine {
          relativeY: 0
          x: -barShapePath.extra
        }
      }
      Text {
        id: logoText
        property bool hovered: false
        property bool opened: false
        y: 6.5
        x: y
        text: ""
        font.family: "icomoon"
        color: hovered ? "#" + Color.colors.on_secondary_fixed_variant : "#" + Color.colors.on_primary
        font.pointSize: hovered ? 36 : 35.5
        MouseArea {
          hoverEnabled: true
          anchors.fill: parent
          onExited: parent.hovered=false
          onEntered: {
            parent.hovered=true
            logoText.opened=true
            menuCloseAnim.stop()
            menuOpenAnim.start()
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
        active: logoText.hovered || logoText.opened || height > 0
        asynchronous: true
        source: "menu/Menu.qml"
        x: topBar.height
        y: topBar.height
        width: 440
        height: animLine.relativeY+Math.min(animLine.relativeY, 80)
      }

      Osd {}

      Notification {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: topBar.height
      }
    }
  }
}
