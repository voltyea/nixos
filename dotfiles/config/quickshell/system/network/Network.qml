pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
  id: network
  property var networks: []
  property bool wifiEnabled: false
  property string activeSsid: ""
  property real activeSignalStrength: 0

  Process {
    running: true
    command: [ Qt.resolvedUrl("./network_power") ]
    stdout: SplitParser {
      onRead: data => {
        network.wifiEnabled=JSON.parse(data)
      }
    }
  }
  Process {
    running: true
    command: [ Qt.resolvedUrl("./network") ]
    stdout: SplitParser {
      onRead: data => {
        network.networks = JSON.parse(data)
        const active = network.networks.find(n => n.active)
        network.activeSsid = active ? active.ssid : ""
        network.activeSignalStrength = active ? active.signalStrength : 0
      }
    }
  }
}
