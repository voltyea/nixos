pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
  id: networkParent
  property alias network: network
  property alias process: process
  readonly property bool wifiEnabled: wifiState.text.split("\n")[0] === "enabled"
  property string activeSsid: ""
  property real activeSignalStrength: 0
  Process {
    id: process
    command: [`${Quickshell.env("HOME")}/.config/quickshell/network.sh`]
    running: true
    onExited: {
      var networkName = JSON.parse(networkModel.text)
      network.clear()
      networkName.forEach(function(item) {
        network.append(item)
      })
      if (network.count === 0) {
        networkParent.activeSsid=""
        networkParent.activeSignalStrength=0
      }
      else {
        var foundActive = false
        for (let i = 0; i < network.count; i++) {
          if (network.get(i).active) {
            networkParent.activeSsid=network.get(i).ssid
            networkParent.activeSignalStrength=network.get(i).signalStrength
            foundActive = true
            break
          }
        }
        if (!foundActive) {
          networkParent.activeSsid = ""
          networkParent.activeSignalStrength = 0
        }
      }
    }
    stdout: StdioCollector {
      id: networkModel
      waitForEnd: false
    }
  }
  Process {
    id: process1
    command: ["nmcli", "radio", "wifi"]
    running: true
    stdout: StdioCollector {
      id: wifiState
    }
  }
  Process {
    running: true
    command: [`${Quickshell.env("HOME")}/.config/quickshell/networkMonitor.sh`]
    stdout: SplitParser {
      onRead: {
        process.running=true
        process1.running=true
      }
    }
  }
  ListModel {
    id: network
  }
}
