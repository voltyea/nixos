pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
  id: moon
  property real moonAngle: 0

  Process {
    running: true
    command: [ Qt.resolvedUrl("./moonphase") ]
    stdout: SplitParser {
      onRead: data => {
        moon.moonAngle=parseFloat(data)
      }
    }
  }
}
