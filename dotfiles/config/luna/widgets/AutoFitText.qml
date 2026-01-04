import Quickshell
import QtQuick

Item {
  id: root
  property alias text: displayText.text
  property alias color: displayText.color
  property alias fontFamily: displayText.font.family
  property alias bold: displayText.font.bold
  property alias horizontalAlignment: displayText.horizontalAlignment
  property alias verticalAlignment: displayText.verticalAlignment
  property int maxFontSize: 20
  property int minFontSize: 6
  property int fittedFontSize: calculateFontSize()
  Text {
    id: displayText
    anchors.fill: parent
    font.pointSize: root.fittedFontSize
  }
  Text {
    id: measureText
    visible: false
    text: displayText.text
    font.family: displayText.font.family
    font.bold: displayText.font.bold
    font.pointSize: root.maxFontSize
  }
  FontMetrics {
    id: metrics
    font: measureText.font
  }
  function calculateFontSize() {
    var size = maxFontSize
    while (size > minFontSize) {
      measureText.font.pointSize = size
      if (metrics.advanceWidth(displayText.text) <= root.width)
      break
      size--
    }
    return size
  }
  onWidthChanged: fittedFontSize = calculateFontSize()
  onTextChanged: fittedFontSize = calculateFontSize()
}
