import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import QtQuick.Controls
import Quickshell.Io

Rectangle {
  id: parentRectangle
  clip: true
  Component.onCompleted: brightnessSliderTip.x=Brightness.currentBrightness/Brightness.maxBrightness*brightnessSlider.width
  color: "transparent"
  Rectangle {
    id: network
    clip: true
    anchors.right: parent.right
    height: parent.height
    width: 0
    color: "transparent"
    Behavior on width {
      NumberAnimation {
        alwaysRunToEnd: false
        duration: 200
        easing.type: Easing.InOutQuart
      }
    }
    onWidthChanged: if(width > 100) Network.process.running=true
    Rectangle {
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.topMargin: 8
      anchors.leftMargin: 10
      height: 40
      width: height
      radius: width/2
      color: "#" + Colors.primary
      Text {
        anchors.centerIn: parent
        text: ""
        font.family: "Symbols Nerd Font"
        color: "#" + Colors.on_primary
        font.pointSize: 20
      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: parent.color="#1a" + Colors.on_secondary_fixed_variant
        onExited: parent.color="#" + Colors.primary
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
          model: Network.network
          Rectangle {
            property bool beingHovered: false
            height: 50
            width: network.width-90
            radius: height/2
            color: beingHovered ? "#1a" + Colors.on_secondary_fixed_variant : active ? "#" + Colors.inverse_primary : "#" + Colors.primary
            MouseArea {
              anchors.fill: parent
              hoverEnabled: active ? false : true
              enabled: active ? false : true
              onEntered: parent.beingHovered=true
              onExited: parent.beingHovered=false
              onClicked: networkPopup.height=network.height, smtText2.text=ssid
            }
            Text {
              anchors.right: parent.right
              anchors.rightMargin: 20
              anchors.top: parent.top
              anchors.topMargin: 15
              text: ssid
              font.family: "SF Pro Rounded"
              color: active ? "#" + Colors.primary : "#" + Colors.on_primary
              font.pointSize: 30
              width: 100
              fontSizeMode: Text.HorizontalFit
              horizontalAlignment: Text.AlignRight
              font.bold: true
            }
            Rectangle {
              anchors.left: parent.left
              anchors.leftMargin: 10
              anchors.verticalCenter: parent.verticalCenter
              height: 35
              visible: active ? true : false
              width: height
              color: "transparent"
              radius: height/2
              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: parent.color="#1a" + Colors.inverse_surface
                onExited: parent.color="transparent"
                onClicked: Quickshell.execDetached(["nmcli", "connection", "delete", ssid ])
              }
              Text {
                anchors.centerIn: parent
                text: ""
                font.family: "Symbols Nerd Font"
                color: "#" + Colors.primary
                font.pointSize: 16
              }
            }
            Text {
              anchors.left: parent.left
              anchors.leftMargin: 50
              anchors.verticalCenter: parent.verticalCenter
              text: ""
              font.family: "icomoon"
              color: "#" + Colors.outline
              font.pointSize: 20
              Text {
                anchors.centerIn: parent
                text: signalStrength < 33.33 ? "" : signalStrength >= 33.33 && signalStrength < 66.66 ? "" : ""
                font.family: "icomoon"
                color: active ? "#" + Colors.primary : "#" + Colors.on_primary
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
      color: "#33" + Colors.on_secondary_fixed_variant
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
        color: "#" + Colors.inverse_primary
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
          color: "#" + Colors.primary
          font.pointSize: 15
          font.bold: true
        }
        Text {
          id: smtText2
          anchors.top: smtText.bottom
          anchors.horizontalCenter: parent.horizontalCenter
          font.family: "SF Pro Rounded"
          color: "#" + Colors.primary
          font.pointSize: 20
          font.bold: true
        }
        Text {
          anchors.top: smtText2.bottom
          anchors.horizontalCenter: parent.horizontalCenter
          text: "Please Enter Password"
          font.family: "SF Pro Rounded"
          color: "#" + Colors.primary
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
            color: "#4d" + Colors.inverse_surface
          }
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          placeholderText: "password"
          font.pointSize: 14
          font.family: "SF Pro Rounded"
          color: "#" + Colors.on_primary
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
        color: "#"+Colors.error
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
  Rectangle {
    anchors.right: network.left
    height: parent.height
    width: parent.width
    color: "transparent"
    Rectangle {
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.topMargin: 8
      anchors.rightMargin: 10
      height: 40
      width: height
      radius: width/2
      color: "#" + Colors.primary
    }
    GridLayout {
      anchors.top: parent.top
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.topMargin: 55
      columnSpacing: 10
      rowSpacing: 10
      columns: 2
      Rectangle {
        height: 60
        width: 200
        radius: height/2
        color: "#" + Colors.primary
        Rectangle {
          id: gold
          anchors.right: parent.right
          height: parent.height
          width: 30
          topRightRadius: parent.radius
          bottomRightRadius: parent.radius
          color: "transparent"
          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: arrow.color="#" + Colors.on_secondary_fixed_variant
            onExited: arrow.color="#" + Colors.on_primary
            onClicked: network.width=parentRectangle.width
          }
          Text {
            id: arrow
            anchors.centerIn: parent
            text: "<b>⟩</b>"
            font.family: "SF Pro Rounded"
            color: "#" + Colors.on_primary
            font.pointSize: 20
            z: -1
          }
          Rectangle {
            anchors.right: parent.left
            height: 50
            width: 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: -width/2
            radius: width/2
            color: "#" + Colors.on_primary
          }
        }
        Rectangle {
          height: 35
          width: height
          radius: height/2
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          anchors.leftMargin: 4
          color: "transparent"
          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.color="#1a" + Colors.on_secondary_fixed_variant
            onExited: parent.color="transparent"
            onClicked: Network.wifiEnabled ? Quickshell.execDetached(["nmcli", "radio", "wifi", "off"]) : Quickshell.execDetached(["nmcli", "radio", "wifi", "on"])
          }
          Text {
            anchors.centerIn: parent
            text: ""
            font.family: "icomoon"
            color: "#" + Colors.outline
            font.pointSize: 20
            z: -1
            Text {
              anchors.centerIn: parent
              text: !Network.wifiEnabled ? "" : Network.activeSignalStrength < 33.33 ? "" : Network.activeSignalStrength >= 33.33 && Network.activeSignalStrength < 66.66 ? "" : ""
              font.family: "icomoon"
              color: "#" + Colors.on_primary
              font.pointSize: 20
            }
          }
        }
        Text {
          anchors.centerIn: parent
          anchors.horizontalCenterOffset: 3
          anchors.verticalCenterOffset: 6
          text: Network.activeSsid === "" ? "Not Connected" : Network.activeSsid
          font.family: "SF Pro Rounded"
          font.pointSize: 20
          color: "#" + Colors.on_primary
          width: 100
          fontSizeMode: Text.HorizontalFit
          horizontalAlignment: Text.AlignHCenter
          font.bold: true
        }
      }
      Rectangle {
        height: 60
        width: 200
        radius: height/2
        color: "#" + Colors.primary
      }
      Rectangle {
        height: 60
        width: 200
        radius: height/2
        color: "#" + Colors.primary
      }
      Rectangle {
        height: 60
        width: 200
        radius: height/2
        color: "#" + Colors.primary
      }
    }
    ColumnLayout {
      spacing: 10
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      RowLayout {
        spacing: 30
        Text {
          text: "󰃠"
          color: "#" + Colors.on_primary
          font.pointSize: 20
          font.family: "Symbols Nerd Font"
          rotation: brightnessSliderTip.x
        }
        Rectangle {
          id: brightnessSlider
          width: 280
          height: 8
          color: "#" + Colors.primary
          radius: height/2
          Rectangle {
            radius: height/2
            anchors.left: parent.left
            anchors.right: brightnessSliderTip.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: "#" + Colors.on_primary
          }
          Rectangle {
            id: brightnessSliderTip
            property bool isPressed: false
            readonly property real xPosition: x/brightnessSlider.width*100
            height: 20
            width: height
            radius: height/2
            anchors.verticalCenter: parent.verticalCenter
            onXChanged: if (brightnessSliderTip.isPressed) {
              Quickshell.execDetached(["brightnessctl", "set", brightnessSliderTip.xPosition+"%"])
            }
            MouseArea {
              anchors.fill: parent
              drag.target: parent
              drag.minimumX: 0
              drag.maximumX: brightnessSlider.width
              onPressed: brightnessSliderTip.isPressed=true
              onReleased: brightnessSliderTip.isPressed=false
            }
          }
        }
      }
      RowLayout {
        spacing: 30
        Text {
          text: Pipewire.defaultAudioSink.audio.muted ? "" : ""
          color: "#" + Colors.on_primary
          font.pointSize: 17.5
          font.family: "Symbols Nerd Font"
          MouseArea {
            anchors.fill: parent
            onClicked: Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted
          }
        }
        Rectangle {
          id: volumeSlider
          width: 280
          height: 8
          color: "#" + Colors.primary
          radius: height/2
          Rectangle {
            radius: height/2
            anchors.left: parent.left
            anchors.right: volumeSliderTip.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: "#" + Colors.on_primary
          }
          Rectangle {
            id: volumeSliderTip
            height: 20
            width: height
            radius: height/2
            anchors.verticalCenter: parent.verticalCenter
            x: Pipewire.defaultAudioSink.audio.volume*volumeSlider.width
            onXChanged: Pipewire.defaultAudioSink.audio.volume=x/volumeSlider.width
            MouseArea {
              anchors.fill: parent
              drag.target: parent
              drag.minimumX: 0
              drag.maximumX: volumeSlider.width
            }
          }
        }
      }
    }
  }
}
