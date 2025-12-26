pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
  id: root
  readonly property var colors: JSON.parse(colorFile.text())
  signal imageChanged()
  FileView {
    id: colorFile
    path: Qt.resolvedUrl("./colors.json")
    watchChanges: true
    onFileChanged: reload(), root.imageChanged()
  }
}
