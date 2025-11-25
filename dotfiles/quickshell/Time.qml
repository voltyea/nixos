pragma Singleton

import Quickshell
import QtQuick

Singleton {
  readonly property real synodicDays: {
    const date = clock.date
    const synodicMonth = 29.53059
    const referenceNewMoon = new Date(Date.UTC(2000, 0, 6, 18, 14))

    const diffMs = date - referenceNewMoon
    const diffDays = diffMs / (1000 * 60 * 60 * 24)

    return ((diffDays % synodicMonth) + synodicMonth) % synodicMonth
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}

