import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    id: mainWindow
    width: 200
    height: 200
    visible: true
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"

    property point startPos
    property bool isResizing: false
    property real aspectRatio: animatedImage.sourceSize.width / animatedImage.sourceSize.height

    // 添加显示设置窗口的方法
    function showSettings() {
        settingsDialog.open()
        settingsDialog.raise()
    }

    AnimatedImage {
        id: animatedImage
        anchors.fill: parent
        source: deskMate.currentImage
        fillMode: Image.PreserveAspectFit

        MouseArea {
            id: dragArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onPressed: {
                if (mouse.button === Qt.LeftButton) {
                    startPos = Qt.point(mouse.x, mouse.y)
                }
            }

            onPositionChanged: {
                if (mouse.buttons & Qt.LeftButton) {
                    var delta = Qt.point(mouse.x - startPos.x, mouse.y - startPos.y)
                    mainWindow.x += delta.x
                    mainWindow.y += delta.y
                }
            }
        }

        Rectangle {
            id: resizeHandle
            width: 10
            height: 10
            color: "gray"
            radius: 5
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.SizeFDiagCursor

                onPressed: {
                    isResizing = true
                    startPos = Qt.point(mouseX, mouseY)
                }

                onPositionChanged: {
                    if (isResizing) {
                        var delta = Qt.point(mouse.x - startPos.x, mouse.y - startPos.y)
                        var newWidth = mainWindow.width + delta.x
                        mainWindow.width = Math.max(100, newWidth)
                        mainWindow.height = mainWindow.width / aspectRatio
                    }
                }

                onReleased: {
                    isResizing = false
                }
            }
        }
    }

    Rectangle {
        id: modalBackground
        anchors.fill: parent
        color: "#80000000"
        visible: settingsDialog.visible
        MouseArea {
            anchors.fill: parent
            onClicked: settingsDialog.close()
        }
    }

    SettingsDialog {
        id: settingsDialog
        x: Screen.width / 2 - width / 2
        y: Screen.height / 2 - height / 2
    }
}
