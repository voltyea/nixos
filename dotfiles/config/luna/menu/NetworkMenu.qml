import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import qs.widgets
import qs.colors
import Luna.Network

Loader {
  id: root
  asynchronous: true
  active: width > 10
  clip: true
  Behavior on width {
    NumberAnimation {
      alwaysRunToEnd: false
      duration: 200
      easing.type: Easing.InOutQuart
    }
  }
  sourceComponent: Rectangle {
    id: network
    width: parent.width
    height: parent.height
    color: "transparent"
    clip: true
    property int index;
    Rectangle {
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.topMargin: 8
      anchors.leftMargin: 10
      height: 40
      width: height
      radius: width/2
      color: "#" + Color.colors.primary
      Text {
        anchors.centerIn: parent
        text: ""
        font.family: "Symbols Nerd Font"
        color: "#" + Color.colors.on_primary
        font.pointSize: 20
      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: parent.color="#1a" + Color.colors.on_secondary_fixed_variant
        onExited: parent.color="#" + Color.colors.primary
        onClicked: root.width=0
      }
    }
    ScrollView {
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.rightMargin: 20
      anchors.topMargin: 30
      width: childrenRect.implicitWidth
      height: parent.height-65
      ColumnLayout {
        spacing: 5
        Repeater {
          model: Network.accessPoints
          Rectangle {
            property bool beingHovered: false
            height: 50
            width: 350
            radius: height/2
            color: beingHovered ? "#1a" + Color.colors.on_secondary_fixed_variant : modelData.active ? "#" + Color.colors.inverse_primary : "#" + Color.colors.primary
            MouseArea {
              anchors.fill: parent
              hoverEnabled: modelData.active ? false : true
              enabled: modelData.active ? false : true
              onEntered: parent.beingHovered=true
              onExited: parent.beingHovered=false
              onClicked: {
                network.index = index
                auth.active = true
              }
            }
            AutoFitText {
              anchors.centerIn: parent
              anchors.horizontalCenterOffset: 4
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
              width: 100
              maxFontSize: 20
              minFontSize: 9
              text: modelData.ssid
              color: modelData.active ? "#" + Color.colors.primary : "#" + Color.colors.on_primary
              fontFamily: "SF Pro Rounded"
              bold: true
            }
            Rectangle {
              anchors.left: parent.left
              anchors.leftMargin: 10
              anchors.verticalCenter: parent.verticalCenter
              height: 35
              visible: modelData.active ? true : false
              width: height
              color: "transparent"
              radius: height/2
              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: parent.color="#1a" + Color.colors.inverse_surface
                onExited: parent.color="transparent"
                onClicked: modelData.disconnect()
              }
              Text {
                anchors.centerIn: parent
                text: ""
                font.family: "Symbols Nerd Font"
                color: "#" + Color.colors.primary
                font.pointSize: 16
              }
            }
            Text {
              anchors.left: parent.left
              anchors.leftMargin: 50
              anchors.verticalCenter: parent.verticalCenter
              text: ""
              font.family: "icomoon"
              color: "#" + Color.colors.outline
              font.pointSize: 20
              Text {
                anchors.centerIn: parent
                text: modelData.strength < 33.33 ? "" : modelData.strength >= 33.33 && modelData.strength < 66.66 ? "" : ""
                font.family: "icomoon"
                color: modelData.active ? "#" + Color.colors.primary : "#" + Color.colors.on_primary
                font.pointSize: 20
              }
            }
          }
        }
      }
    }
    Loader {
      id: auth
      active: false
      asynchronous: true
      anchors.horizontalCenter: parent.horizontalCenter
      y: active ? parent.height/2 - height/2 : -height
      width: 250
      height: 120
      sourceComponent: Rectangle {
        width: parent.width
        height: parent.height
        radius: 30
        color: "#" + Color.colors.inverse_primary
        TextField {
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 10
          anchors.horizontalCenter: parent.horizontalCenter
          height: 40
          width: parent.width - 40
          background: Rectangle {
            radius: height/2
            color: "#4d" + Color.colors.inverse_surface
          }
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          placeholderText: "password"
          font.pointSize: 12
          font.family: "SF Pro Rounded"
          color: "#" + Color.colors.on_primary
          echoMode: TextInput.Password
          font.bold: true
          onAccepted: {
            Network.networks[network.index].connect(this.text)
            clear()
          }
        }
      }
    }
  }
}
