import Quickshell
import QtQuick
import QtQuick.Shapes
import qs.colors

Rectangle {
  id: parentRect
  height: 270
  width: height
  color: "transparent"
  radius: height/2
  Repeater {
    model: 40
    Rectangle {
      id: ticks
      height: 10
      width: index % 5 === 0 ? 4 : 2
      radius: width/2
      color: "#" + Color.colors.primary
      anchors.horizontalCenter: parent.horizontalCenter
      transform: Rotation {
        origin.x: ticks.width/2
        origin.y: parentRect.height/2
        angle: index * 9
      }
    }
  }
  Rectangle {
    id: innerRect
    anchors.centerIn: parent
    height: parent.height-25
    width: height
    radius: height/2
    color: "transparent"
    Repeater {
      model: 8
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: index === 2 ? 7 : index === 6 ? -7 : 0
        font.family: "Symbols Nerd Font"
        color: "#" + Color.colors.primary
        font.pointSize: 30
        text: ({
          0: "󰽤",
          1: "󰽧",
          2: "󰽡",
          3: "󰽨",
          4: "󰽢",
          5: "󰽦",
          6: "󰽣",
          7: "󰽥"
        })[index]
        transform: Rotation {
          origin.x: width/2
          origin.y: innerRect.height/2
          angle: index * 45
        }
        rotation: -(index*45)
      }
    }
  }
  Rectangle {
    id: clockHandRect
    width: clockHand.width * clockHand.scale
    height: clockHand.height * clockHand.scale
    anchors.centerIn: parent
    anchors.verticalCenterOffset: -45.5
    rotation: 0
    color: "transparent"
    transform: Rotation {
      origin.x: clockHandRect.width/2
      origin.y: clockHandRect.height-7
      angle: Moonphase.moonAngle
    }
    Shape {
      id: clockHand
      asynchronous: true
      antialiasing: true
      smooth: true
      preferredRendererType: Shape.CurveRenderer
      anchors.centerIn: parent
      anchors.horizontalCenterOffset: -5.7
      scale: 0.1
      ShapePath {
        strokeColor: "transparent"
        fillColor: "#" + Color.colors.primary
        capStyle: ShapePath.RoundCap
        PathSvg {
          path: "M 201.363 1045.98 Q 180.477 1042.21 164.585 1026.49 Q 145.414 1007.54 144.262 979 Q 143.476 959.55 152.198 942.689 Q 157.817 931.827 168.422 922.729 Q 179.027 913.632 190.258 910.041 Q 191.808 909.546 193.203 908.648 Q 194.598 907.75 195.008 906.986 Q 196 905.131 196 872.673 L 195.954 854.936 L 195.731 845.093 Q 195.462 839.997 194.25 839.508 Q 192.5 838.802 179.5 835.021 L 169.717 832.114 Q 165.989 830.953 164.106 830.178 Q 161.062 828.927 159.601 826.841 Q 155.542 821.046 161.402 816.371 Q 164.959 813.533 172.483 810.684 Q 180.007 807.835 188.561 806.088 Q 198.218 804.115 198.784 803.549 Q 199.653 802.68 193.444 763.5 Q 184.076 704.385 186.817 665.272 L 187.936 651.664 Q 188.57 644.975 188.975 642.5 L 190.318 634.309 Q 198.675 583.331 200.063 568.383 Q 201.451 553.434 201.422 514.722 L 201.418 508.5 L 200.82 460.113 Q 200.239 449.562 197.375 435 Q 187.913 386.902 154.165 362.181 Q 147.5 357.299 137 350.942 Q 126.5 344.584 125.765 343.542 Q 125.462 343.112 125.242 341.991 Q 125.022 340.87 125.015 339.725 Q 125.006 338.046 125.907 336.96 Q 126.808 335.875 129.579 334.225 Q 169.456 310.49 184.018 280.642 Q 195.409 257.294 199.384 219.172 Q 203.359 181.051 205.809 71.6607 L 206.709 44.4435 Q 207.091 40.343 208.861 38.9107 Q 211.824 36.512 217.062 37.1446 Q 222.3 37.7772 223.456 40.6734 Q 223.757 41.4269 224.228 63.1134 L 225.059 114.5 L 226.397 183.814 Q 227.095 200.405 229.518 220.5 Q 232.284 243.442 235.529 255.695 Q 238.773 267.948 245.671 281.5 Q 260.357 310.355 291.417 328.857 Q 302.023 335.175 302.96 336.926 Q 304.346 339.516 302.452 341.926 Q 300.557 344.336 293.646 348.773 Q 241.381 382.331 230.123 441.5 Q 225.989 463.229 226.021 507.395 Q 226.065 568.422 236.462 631 Q 238.871 645.5 240.043 664.246 Q 241.255 683.629 239.903 698.944 L 231.062 766 Q 227.082 793.499 226.791 798.933 L 226.5 804.366 L 232.605 805.623 Q 241.548 807.466 251.428 811.387 Q 261.308 815.308 264.138 818.138 Q 266.052 820.052 265.935 822.934 Q 265.818 825.817 263.75 827.7 Q 259.821 831.277 240.42 836.532 Q 230.5 839.219 229.25 840.232 Q 228 841.245 228 873.431 Q 228 905.618 229.25 907.199 Q 229.766 907.851 231.308 908.682 Q 232.85 909.512 234.5 910.027 Q 266.603 920.041 278.611 955 Q 280.632 960.884 280.629 975.43 Q 280.625 989.977 278.601 996.5 Q 271.879 1018.17 254.656 1031.83 Q 237.432 1045.5 215.576 1046.49 Q 211.822 1046.66 207.655 1046.51 Q 203.475 1046.36 201.361 1045.98 L 201.363 1045.98 M 220.938 989.16 Q 225.761 985.632 227.315 980.133 Q 228.869 974.633 226.471 969.581 Q 222.464 961.136 212.688 960.938 Q 202.911 960.74 198.752 969.02 Q 196.358 973.785 197.104 978.685 Q 197.85 983.586 201.528 987.259 Q 205.219 990.945 211.075 991.518 Q 216.931 992.092 220.938 989.16 M 220.182 394.213 Q 225.865 382.926 231.658 374.213 Q 241.958 358.72 259.204 344.431 Q 262.785 341.464 262.212 339.295 Q 261.638 337.127 255.95 332.12 Q 243.939 321.547 232.457 302.601 Q 228.887 296.711 223.949 286.35 Q 219.012 275.988 219.005 274.372 Q 218.999 273.057 217.5 272.06 Q 216.001 271.062 214.752 271.542 Q 214.132 271.78 212.877 273.865 Q 211.621 275.951 210.477 278.641 Q 204.775 292.058 191.961 308.922 Q 179.146 325.787 168.288 334.163 Q 162.709 338.468 163.141 340.96 Q 163.574 343.452 170.742 348.302 Q 186.892 359.232 196.582 375.603 Q 200.664 382.5 204.943 393 Q 209.221 403.5 210.269 404.793 Q 211.924 406.836 213.981 404.641 Q 216.038 402.445 220.182 394.213"
        }
      }
    }
  }
  Rectangle {
    anchors.centerIn: parent
    height: 6
    width: height
    radius: height/2
    color: "#" + Color.colors.on_primary
  }
}
