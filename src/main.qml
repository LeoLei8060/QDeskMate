import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1
import com.deskmate.backend 1.0

Window {
    id: mainWindow
    width: 128
    height: 128
    visible: true
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool
    color: "transparent"
    objectName: "mainWindow"  // 添加 objectName 以便从 C++ 访问

    // 添加显示设置窗口的方法
    function showSettings() {
        settingsDialog.open()
        settingsDialog.raise()
    }

    // 图片显示区域
    Item {
        id: imageContainer
        anchors.fill: parent

        // GIF模式
        AnimatedImage {
            id: gifImage
            anchors.fill: parent
            source: !deskMate.isFolderMode && deskMate.currentImagePath ? (deskMate.currentImagePath.startsWith("qrc:/") ? deskMate.currentImagePath : "file:///" + deskMate.currentImagePath) : ""
            visible: !deskMate.isFolderMode && deskMate.currentImagePath
            fillMode: Image.PreserveAspectFit
        }

        // 文件夹模式
        Image {
            id: folderImage
            anchors.fill: parent
            source: deskMate.isFolderMode && deskMate.currentImagePath ? (deskMate.currentImagePath.startsWith("qrc:/") ? deskMate.currentImagePath : "file:///" + deskMate.currentImagePath) : ""
            visible: deskMate.isFolderMode && deskMate.currentImagePath
            fillMode: Image.PreserveAspectFit
            onVisibleChanged: {
                if (visible) {
                    deskMate.updateImage();  // 启动定时器更新图片
                }
            }
        }

        Connections {
            target: deskMate
            function onIsFolderModeChanged() {
                if (deskMate.isFolderMode) {
                    deskMate.updateImage();  // 手动启动定时器更新图片
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            property point startPos
            property bool isDragging: false

            onPressed: {
                startPos = Qt.point(mouse.x, mouse.y)
                isDragging = true
            }

            onPositionChanged: {
                if (isDragging) {
                    var delta = Qt.point(mouse.x - startPos.x, mouse.y - startPos.y)
                    mainWindow.x += delta.x
                    mainWindow.y += delta.y
                }
            }

            onReleased: {
                isDragging = false
            }

            onDoubleClicked: {
                settingsDialog.open()
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
        objectName: "settingsDialog"  // 添加 objectName 以便从 C++ 访问
        x: Screen.width / 2 - width / 2
        y: Screen.height / 2 - height / 2
    }
}
