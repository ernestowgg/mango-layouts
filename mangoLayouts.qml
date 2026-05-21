import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property string activeLayout: ""

    readonly property var layouts: [
        {
            code: "S",
            name: "Scroller"
        },
        {
            code: "T",
            name: "Tile"
        },
        {
            code: "G",
            name: "Grid"
        },
        {
            code: "M",
            name: "Monocle"
        },
        {
            code: "K",
            name: "Deck"
        },
        {
            code: "CT",
            name: "Center Tile"
        },
        {
            code: "RT",
            name: "Right Tile"
        },
        {
            code: "VS",
            name: "V. Scroller"
        },
        {
            code: "VT",
            name: "V. Tile"
        },
        {
            code: "VG",
            name: "V. Grid"
        },
        {
            code: "VK",
            name: "V. Deck"
        },
        {
            code: "DW",
            name: "Dwindle"
        },
        {
            code: "F",
            name: "Fair"
        },
        {
            code: "VF",
            name: "V. Fair"
        },
    ]

    function parseLayout(line) {
        const parts = line.trim().split(/\s+/);
        return parts[parts.length - 1];
    }

    Process {
        id: getLayout
        command: ["mmsg", "-g", "-l"]
        running: true
        stdout: SplitParser {
            onRead: data => root.activeLayout = root.parseLayout(data)
        }
    }

    Process {
        id: watchLayout
        command: ["mmsg", "-w", "-l"]
        running: true
        stdout: SplitParser {
            onRead: data => root.activeLayout = root.parseLayout(data)
        }
    }

    Process {
        id: setLayout
        onRunningChanged: if (!running)
            running = false
    }

    function switchLayout(code) {
        setLayout.running = false;
        setLayout.command = ["mmsg", "-s", "-l", code];
        setLayout.running = true;
    }

    horizontalBarPill: Component {
        DankIcon {
            name: "view_quilt"
            size: Theme.iconSize
            color: Theme.surfaceText
        }
    }

    verticalBarPill: Component {
        DankIcon {
            name: "view_quilt"
            size: Theme.iconSize
            color: Theme.surfaceText
        }
    }

    popoutContent: Component {
        PopoutComponent {
            headerText: "Layout"
            detailsText: root.layouts.find(l => l.code === root.activeLayout)?.name ?? root.activeLayout
            showCloseButton: true

            Column {
                width: parent.width
                spacing: 2

                Repeater {
                    model: root.layouts

                    delegate: Item {
                        id: delegateItem
                        required property var modelData
                        readonly property bool active: root.activeLayout === modelData.code

                        width: parent.width
                        height: rowContent.implicitHeight + Theme.spacingS * 2

                        Rectangle {
                            anchors.fill: parent
                            color: delegateItem.active ? Theme.surfaceContainerHigh : "transparent"
                            radius: Theme.cornerRadius
                        }

                        Row {
                            id: rowContent
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                right: parent.right
                                leftMargin: Theme.spacingS
                                rightMargin: Theme.spacingS
                            }
                            spacing: Theme.spacingS

                            StyledText {
                                text: delegateItem.modelData.code
                                width: 28
                                font.pixelSize: Theme.fontSizeSmall
                                color: delegateItem.active ? Theme.surfaceText : Theme.surfaceVariantText
                            }

                            StyledText {
                                text: delegateItem.modelData.name
                                font.pixelSize: Theme.fontSizeSmall
                                color: delegateItem.active ? Theme.surfaceText : Theme.surfaceVariantText
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.switchLayout(delegateItem.modelData.code)
                        }
                    }
                }
            }
        }
    }

    popoutWidth: 200
    popoutHeight: 480
}
