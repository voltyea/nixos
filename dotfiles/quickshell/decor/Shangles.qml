import Quickshell
import QtQuick
import qs.colors

Rectangle {
  id: root
  color: "transparent"
  width: parent.width
  height: parent.height/2
  function rand(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min
  }
  function randChar(options) {
    return options[Math.floor(Math.random() * options.length)]
  }
  Repeater {
    model: root.rand(30, 60)
    Rectangle {
      height: root.rand(70, root.height-40)
      width: 1
      color: "#e6" + Color.colors.primary
      bottomLeftRadius: width/2
      bottomRightRadius: width/2
      x: root.rand(0, root.width)

      Text {
        text: root.randChar(["󰽧", "", "󰽥"])
        font.family: "Symbols Nerd Font"
        color: "#b3" + Color.colors.primary
        font.pointSize: (text === "󰽧" || text === "󰽥") ? 28 : 25
        anchors.top: parent.bottom
        anchors.topMargin: (text === "󰽧" || text === "󰽥") ? -4.6 : -2.1
        anchors.horizontalCenter: parent.horizontalCenter
      }
    }
  }
}
