import QtQuick
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    delegate: PanelWindow {
        id: root

        required property var modelData
        screen: modelData

        color: "#02080e"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        // Empty input region: clicks pass through to the desktop and AGS.
        mask: Region {}

        function makeMatrixColumn(length) {
            const characters =
                "01アイウエオカキクケコサシスセソABCDEFGHIJKLMNOPQRSTUVWXYZ";

            let output = "";

            for (let i = 0; i < length; ++i) {
                output += characters.charAt(
                    Math.floor(Math.random() * characters.length)
                );

                if (i < length - 1)
                    output += "\n";
            }

            return output;
        }

        Item {
            id: effectsLayer
            anchors.fill: parent
            clip: true

            Item {
                id: matrixRain
                anchors.fill: parent

                property int columnCount:
                    Math.max(9, Math.floor(width / 55))

                Repeater {
                    id: matrixColumns
                    model: matrixRain.columnCount

                    delegate: Text {
                        id: matrixGlyph

                        required property int index

                        property int fallDuration:
                            14000 + Math.floor(Math.random() * 12000)

                        property int startDelay:
                            Math.floor(Math.random() * 5000)

                        x:
                            index *
                            (
                                matrixRain.width /
                                Math.max(1, matrixRain.columnCount)
                            ) +
                            Math.random() * 18

                        y: -height

                        text:
                            root.makeMatrixColumn(
                                22 + index % 10
                            )

                        color: "#5bdaeb"
                        opacity: 0.35

                        font.family: "monospace"
                        font.pixelSize: 11 + index % 3

                        horizontalAlignment: Text.AlignHCenter

                        lineHeightMode: Text.FixedHeight
                        lineHeight: font.pixelSize + 3

                        renderType: Text.NativeRendering

                        SequentialAnimation on y {
                            running: true
                            loops: Animation.Infinite

                            PauseAnimation {
                                duration: matrixGlyph.startDelay
                            }

                            NumberAnimation {
                                from:
                                    -matrixGlyph.height -
                                    Math.random() *
                                    matrixRain.height

                                to:
                                    matrixRain.height +
                                    matrixGlyph.height

                                duration:
                                    matrixGlyph.fallDuration

                                easing.type: Easing.Linear
                            }
                        }

                        SequentialAnimation on opacity {
                            running: true
                            loops: Animation.Infinite

                            NumberAnimation {
                                from: 0.25
                                to: 0.75
                                duration: 1000 + index % 5 * 180
                            }

                            NumberAnimation {
                                from: 0.75
                                to: 0.25
                                duration: 1200 + index % 4 * 220
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "#02080e"
                opacity: 0.42
                z: 5
            }

            Rectangle {
                id: scanLine

                x: 0
                y: -height

                width: parent.width
                height: 1

                color: "#5bdaeb"
                opacity: 0.1
                z: 10

                NumberAnimation {
                    id: scanAnimation

                    target: scanLine
                    property: "y"

                    from: -scanLine.height
                    to: effectsLayer.height

                    duration: 6000
                    loops: Animation.Infinite
                    easing.type: Easing.Linear
                }

                Timer {
                    interval: 600
                    running: true
                    repeat: false

                    onTriggered: {
                        scanAnimation.stop();
                        scanLine.y = -scanLine.height;
                        scanAnimation.from = -scanLine.height;
                        scanAnimation.to = effectsLayer.height;
                        scanAnimation.start();
                    }
                }
            }
        }
    }
}
