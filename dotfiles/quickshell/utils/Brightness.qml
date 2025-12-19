pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
  readonly property real currentBrightness: brightnessFile.text()
  readonly property real maxBrightness: maxBrightness.text.split("\n")[0]
  FileView {
    id: brightnessFile
    path: brightnessPath.text.split("\n")[0]
    watchChanges: true
    onFileChanged: reload()
  }
  Process {
    command: ["bash", "-c", "echo /sys/class/backlight/*/brightness"]
    running: true
    stdout: StdioCollector {
      id: brightnessPath
    }
  }
  Process {
    command: ["bash", "-c", "cat /sys/class/backlight/*/max_brightness"]
    running: true
    stdout: StdioCollector {
      id: maxBrightness
    }
  }
}
