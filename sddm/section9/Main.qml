import QtQuick 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0

Rectangle {
    id: root

    width: 640
    height: 480
    color: "#02080e"

    property string loginUser:
        String(userModel.lastUser || "Kid_A")

    property int loginSession:
        sessionModel.lastIndex >= 0
        ? sessionModel.lastIndex
        : 0

    property int sessionNameRole: Qt.UserRole + 4

    property bool authenticationPending: false
    property bool authenticationFailed: false
    property bool authenticationSucceeded: false
    property int failedAttempts: 0

    property string currentSession: {
        var count = sessionModel.rowCount()

        if (count <= 0)
            return "HYPRLAND"

        if (loginSession < 0 || loginSession >= count)
            return "HYPRLAND"

        var name = sessionModel.data(
            sessionModel.index(loginSession, 0),
            sessionNameRole
        )

        return String(name || "HYPRLAND")
    }

    /*
     * Create one vertical Matrix-style character stream.
     */
    function makeMatrixColumn(length) {
        var characters =
            "01ABCDEF#@+-<>[]{}アイウエオカキクケコサシスセソ"

        var output = ""

        for (var i = 0; i < length; i++) {
            var position = Math.floor(
                Math.random() * characters.length
            )

            output += characters.charAt(position)

            if (i < length - 1)
                output += "\n"
        }

        return output
    }

    function normalizeSession() {
        var count = sessionModel.rowCount()

        if (count <= 0) {
            loginSession = 0
            return
        }

        if (loginSession < 0 || loginSession >= count)
            loginSession = 0
    }

    function cycleSession() {
        if (authenticationPending)
            return

        var count = sessionModel.rowCount()

        if (count <= 1)
            return

        loginSession = (loginSession + 1) % count
        passwordInput.forceActiveFocus()
    }

    function submitLogin() {
        if (authenticationPending)
            return

        if (passwordInput.text.length === 0)
            return

        normalizeSession()

        authenticationPending = true
        authenticationFailed = false
        authenticationSucceeded = false

        sddm.login(
            loginUser,
            passwordInput.text,
            loginSession
        )
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            authenticationPending = false
            authenticationSucceeded = false
            authenticationFailed = true
            failedAttempts += 1

            passwordInput.clear()
            passwordInput.forceActiveFocus()
            failureReset.restart()
        }

        function onLoginSucceeded() {
            authenticationSucceeded = true
            authenticationFailed = false
            authenticationPending = true
        }
    }

    Timer {
        id: failureReset

        interval: 1800
        repeat: false

        onTriggered: authenticationFailed = false
    }

    Item {
        id: mainFrame

        property var geometry:
            screenModel.geometry(screenModel.primary)

        x: geometry.x
        y: geometry.y
        width: geometry.width
        height: geometry.height

        clip: true

        /*
         * Solid background.
         */
        Rectangle {
            anchors.fill: parent
            color: "#02080e"
        }

        /*
         * Subtle falling Matrix characters.
         */
        Item {
            id: matrixRain

            anchors.fill: parent
            clip: true
            opacity: 0.20

            Repeater {
                id: matrixColumns

                model: Math.max(
                    14,
                    Math.floor(matrixRain.width / 58)
                )

                delegate: Text {
                    id: matrixGlyph

                    property int fallDuration:
                        7000 +
                        Math.floor(Math.random() * 8000)

                    property int startDelay:
                        Math.floor(Math.random() * 5000)

                    x:
                        index *
                        (
                            matrixRain.width /
                            Math.max(1, matrixColumns.count)
                        ) +
                        Math.random() * 18

                    y: -height

                    text:
                        root.makeMatrixColumn(
                            22 + index % 10
                        )

                    color: "#5bdaeb"

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

                            duration:
                                1000 +
                                index % 5 * 180
                        }

                        NumberAnimation {
                            from: 0.75
                            to: 0.25

                            duration:
                                1200 +
                                index % 4 * 220
                        }
                    }
                }
            }
        }

        /*
         * Dark veil keeps the Matrix effect behind the interface.
         */
        Rectangle {
            anchors.fill: parent

            color: "#02080e"
            opacity: 0.42
        }

        /*
         * Slow cyber scan line.
         */
        Rectangle {
            id: scanLine

            width: parent.width
            height: 1

            color: "#5bdaeb"
            opacity: 0.10

            NumberAnimation on y {
                running: true
                loops: Animation.Infinite

                from: 0
                to: mainFrame.height

                duration: 6000
                easing.type: Easing.Linear
            }
        }

        Timer {
            interval: 1000
            running: true
            repeat: true

            onTriggered: {
                clockText.text =
                    Qt.formatDateTime(
                        new Date(),
                        "HH:mm"
                    )

                dateText.text =
                    Qt.formatDateTime(
                        new Date(),
                        "yyyy-MM-dd // dddd"
                    )
            }
        }

        /*
         * Main login interface.
         *
         * This entire layer fades and slides into place.
         */
        Item {
            id: loginLayer

            anchors.fill: parent
            opacity: 0

            transform: Translate {
                id: introTranslation
                y: 14
            }

            Text {
                id: clockText

                anchors.horizontalCenter:
                    parent.horizontalCenter

                anchors.verticalCenter:
                    parent.verticalCenter

                anchors.verticalCenterOffset: -245

                text:
                    Qt.formatDateTime(
                        new Date(),
                        "HH:mm"
                    )

                color: "#5bdaeb"

                font.family: "monospace"
                font.pixelSize: 62
                font.weight: Font.Light
            }

            Text {
                id: dateText

                anchors.horizontalCenter:
                    parent.horizontalCenter

                anchors.verticalCenter:
                    parent.verticalCenter

                anchors.verticalCenterOffset: -195

                text:
                    Qt.formatDateTime(
                        new Date(),
                        "yyyy-MM-dd // dddd"
                    )

                color: "#aac3cc"

                font.family: "monospace"
                font.pixelSize: 14
            }

            Text {
                anchors.horizontalCenter:
                    parent.horizontalCenter

                anchors.verticalCenter:
                    parent.verticalCenter

                anchors.verticalCenterOffset: -120

                text:
                    "SECTION 9 // CYBERBRAIN AUTHORIZATION"

                color: "#5bdaeb"

                font.family: "monospace"
                font.pixelSize: 20
                font.weight: Font.Medium
            }

            Text {
                anchors.horizontalCenter:
                    parent.horizontalCenter

                anchors.verticalCenter:
                    parent.verticalCenter

                anchors.verticalCenterOffset: -82

                text:
                    "IDENTITY // " +
                    root.loginUser.toUpperCase()

                color: "#d7e8ee"

                font.family: "monospace"
                font.pixelSize: 14
                font.letterSpacing: 1
            }

            /*
             * Graphical session selector.
             */
            Rectangle {
                id: sessionSelector

                anchors.horizontalCenter:
                    parent.horizontalCenter

                anchors.verticalCenter:
                    parent.verticalCenter

                anchors.verticalCenterOffset: -20

                width:
                    Math.min(
                        360,
                        parent.width * 0.42
                    )

                height: 38
                radius: 2

                color:
                    sessionMouse.containsMouse
                    ? "#061722"
                    : "#030e15"

                border.width: 1

                border.color:
                    sessionMouse.containsMouse
                    ? "#5bdaeb"
                    : "#315f6b"

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 14

                    anchors.verticalCenter:
                        parent.verticalCenter

                    text:
                        "TARGET // " +
                        root.currentSession.toUpperCase()

                    color: "#5bdaeb"

                    font.family: "monospace"
                    font.pixelSize: 12
                    font.bold: true
                    font.letterSpacing: 1
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 14

                    anchors.verticalCenter:
                        parent.verticalCenter

                    text:
                        sessionModel.rowCount() > 1
                        ? "F3"
                        : "FIXED"

                    color: "#829aa2"

                    font.family: "monospace"
                    font.pixelSize: 10
                }

                MouseArea {
                    id: sessionMouse

                    anchors.fill: parent
                    hoverEnabled: true

                    enabled:
                        !authenticationPending

                    onClicked:
                        root.cycleSession()
                }
            }

            /*
             * Password input.
             */
            Rectangle {
                id: passwordContainer

                anchors.horizontalCenter:
                    parent.horizontalCenter

                anchors.verticalCenter:
                    parent.verticalCenter

                anchors.verticalCenterOffset: 55

                width:
                    Math.min(
                        420,
                        parent.width * 0.31
                    )

                height: 54
                radius: 2

                color: "#030e15"
                border.width: 2

                border.color: {
                    if (authenticationFailed)
                        return "#ff5b69"

                    if (
                        authenticationPending ||
                        authenticationSucceeded
                    )
                        return "#50e6aa"

                    if (keyboard.capsLock)
                        return "#f2b84b"

                    return "#5bdaeb"
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Text {
                    anchors.centerIn: parent

                    visible:
                        passwordInput.text.length === 0 &&
                        !authenticationPending

                    text:
                        keyboard.capsLock
                        ? "CAPS LOCK ACTIVE"
                        : "CYBERBRAIN PASSPHRASE"

                    color:
                        keyboard.capsLock
                        ? "#f2b84b"
                        : "#8797a2"

                    font.family: "monospace"
                    font.pixelSize: 12
                }

                TextInput {
                    id: passwordInput

                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18

                    focus: true
                    activeFocusOnTab: true
                    clip: true

                    enabled:
                        !authenticationPending

                    readOnly:
                        authenticationPending

                    echoMode: TextInput.Password
                    passwordCharacter: "•"

                    color: "#daeef2"
                    selectionColor: "#5bdaeb"
                    selectedTextColor: "#02080e"

                    horizontalAlignment:
                        TextInput.AlignHCenter

                    verticalAlignment:
                        TextInput.AlignVCenter

                    font.family: "monospace"
                    font.pixelSize: 18
                    font.bold: true
                    font.letterSpacing: 4

                    cursorVisible:
                        activeFocus &&
                        !authenticationPending

                    onAccepted:
                        root.submitLogin()

                    Keys.onEscapePressed: {
                        if (!authenticationPending) {
                            clear()
                            authenticationFailed = false
                        }
                    }
                }
            }

            /*
             * Authentication status.
             */
            Text {
                anchors.horizontalCenter:
                    parent.horizontalCenter

                anchors.verticalCenter:
                    parent.verticalCenter

                anchors.verticalCenterOffset: 128

                text: {
                    if (authenticationSucceeded)
                        return (
                            "ACCESS GRANTED // STARTING " +
                            root.currentSession.toUpperCase()
                        )

                    if (authenticationPending)
                        return "VERIFYING IDENTITY"

                    if (authenticationFailed)
                        return (
                            "ACCESS DENIED // ATTEMPT " +
                            failedAttempts
                        )

                    return "SECURE AUTHENTICATION CHANNEL"
                }

                color: {
                    if (
                        authenticationSucceeded ||
                        authenticationPending
                    )
                        return "#50e6aa"

                    if (authenticationFailed)
                        return "#ff5b69"

                    return "#5bdaeb"
                }

                font.family: "monospace"
                font.pixelSize: 11
                font.letterSpacing: 1
            }

            /*
             * Quiet bottom hints.
             */
            Text {
                anchors.left: parent.left
                anchors.bottom: parent.bottom

                anchors.leftMargin: 24
                anchors.bottomMargin: 20

                text: "TTY // CTRL+ALT+F3"
                color: "#829aa2"

                font.family: "monospace"
                font.pixelSize: 10
                font.letterSpacing: 1
            }

            Text {
                anchors.horizontalCenter:
                    parent.horizontalCenter

                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20

                text: "PUBLIC SECURITY SECTION 9"
                color: "#5b6970"

                font.family: "monospace"
                font.pixelSize: 9
                font.letterSpacing: 1
            }

            Text {
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                anchors.rightMargin: 24
                anchors.bottomMargin: 20

                text: "ROOT // sudo -i AFTER LOGIN"
                color: "#829aa2"

                font.family: "monospace"
                font.pixelSize: 10
                font.letterSpacing: 1
            }
        }

        /*
         * Intro animation.
         */
        ParallelAnimation {
            id: introAnimation

            NumberAnimation {
                target: loginLayer
                property: "opacity"

                from: 0
                to: 1

                duration: 950
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target: introTranslation
                property: "y"

                from: 14
                to: 0

                duration: 950
                easing.type: Easing.OutCubic
            }
        }

        Timer {
            id: passwordFocusTimer

            interval: 180
            repeat: false

            onTriggered:
                passwordInput.forceActiveFocus()
        }

        Shortcut {
            sequence: "F3"
            enabled: !authenticationPending

            onActivated:
                root.cycleSession()
        }

        Shortcut {
            sequence: "F11"

            onActivated: {
                if (
                    sddm.canPowerOff &&
                    !authenticationPending
                ) {
                    sddm.powerOff()
                }
            }
        }

        Shortcut {
            sequence: "F12"

            onActivated: {
                if (
                    sddm.canReboot &&
                    !authenticationPending
                ) {
                    sddm.reboot()
                }
            }
        }

        Component.onCompleted: {
            root.normalizeSession()
            introAnimation.start()
            passwordFocusTimer.start()
        }
    }
}
