import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import qs.widgets
import qs.colors
import Luna.Network

Rectangle {
  id: network
  clip: true
  color: "transparent"
  Behavior on width {
    NumberAnimation {
      alwaysRunToEnd: false
      duration: 200
      easing.type: Easing.InOutQuart
    }
  }
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
      onClicked: network.width=0
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
        model: console.log(Network.networks)
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
            onClicked: networkPopup.height=network.height, smtText2.text=modelData.ssid
          }
          AutoFitText {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 4
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            width: 100
            maxFontSize: 20
            minFontSize: 9
            text: console.log(Network.active)
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
              onClicked: Quickshell.execDetached(["nmcli", "connection", "delete", modelData.ssid ])
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
              text: modelData.signalStrength < 33.33 ? "" : modelData.signalStrength >= 33.33 && modelData.signalStrength < 66.66 ? "" : ""
              font.family: "icomoon"
              color: modelData.active ? "#" + Color.colors.primary : "#" + Color.colors.on_primary
              font.pointSize: 20
            }
          }
        }
      }
    }
  }
  Rectangle {
    id: networkPopup
    clip: true
    anchors.centerIn: parent
    width: parent.width
    height: 0
    color: "#33" + Color.colors.on_secondary_fixed_variant
    radius: 30
    Behavior on height {
      NumberAnimation {
        alwaysRunToEnd: false
        duration: 200
        easing.type: Easing.InOutQuart
      }
    }
    MouseArea {
      anchors.fill: parent
      onClicked: parent.height=0
      hoverEnabled: true
    }
    Rectangle {
      anchors.centerIn: parent
      height: parent.height-70
      width: parent.width-70
      radius: 30
      color: "#" + Color.colors.inverse_primary
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
      }
      Text {
        id: smtText
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Connecting to..."
        font.family: "SF Pro Rounded"
        color: "#" + Color.colors.primary
        font.pointSize: 15
        font.bold: true
      }
      Text {
        id: smtText2
        anchors.top: smtText.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: "SF Pro Rounded"
        color: "#" + Color.colors.primary
        font.pointSize: 20
        font.bold: true
      }
      Text {
        anchors.top: smtText2.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Please Enter Password"
        font.family: "SF Pro Rounded"
        color: "#" + Color.colors.primary
        font.pointSize: 15
        font.bold: true
      }
      TextField {
        id: networkPass
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        height: 50
        width: 300
        background: Rectangle {
          radius: height/2
          color: "#4d" + Color.colors.inverse_surface
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        placeholderText: "password"
        font.pointSize: 14
        font.family: "SF Pro Rounded"
        color: "#" + Color.colors.on_primary
        echoMode: TextInput.Password
        font.bold: true
        onAccepted: {
          networkProcess.running=true
          clear()
        }
      }
    }
    Text {
      id: errorText
      anchors.centerIn: parent
      anchors.verticalCenterOffset: 5
      text: "Wrong Password"
      visible: false
      font.family: "SF Pro Rounded"
      color: "#"+Color.colors.error
      font.pointSize: 15
      font.bold: true
      SequentialAnimation on anchors.horizontalCenterOffset {
        id: errorAnim
        running: false
        alwaysRunToEnd: false
        NumberAnimation {
          to: 30
          duration: 150
          easing.overshoot: 10
          loops: 2
          easing.type: Easing.InOutBack
        }
        NumberAnimation {
          to: 0
          duration: 0
        }
      }
    }
  }
  Process {
    id: networkProcess
    running: false
    command: [ "nmcli", "device", "wifi", "connect", smtText2.text, "password", networkPass.text ]
    onExited: (exitCode, exitStatus) => {
      if (exitCode===0) {
        networkPopup.height=0
        errorText.visible=false
      }
      else {
        errorText.visible=true
        errorAnim.start()
        Quickshell.execDetached(["nmcli", "connection", "delete", smtText2.text])
      }
    }
  }
}
