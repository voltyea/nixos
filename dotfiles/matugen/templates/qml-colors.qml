pragma Singleton

import Quickshell
import QtQuick

Singleton {
<* for name, value in colors *>
readonly property string {{name}}: "{{value.default.hex_stripped}}"
<* endfor *>
}
