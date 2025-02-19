import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1
import QtGraphicalEffects 1.15
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

    // 任务列表窗口
    Window {
        id: taskListWindow
        width: 240
        height: 340
        visible: false
        flags: Qt.Tool | Qt.FramelessWindowHint
        color: "transparent"

        // 添加显示/隐藏动画
        Behavior on visible {
            NumberAnimation {
                target: taskListWindow
                property: "opacity"
                from: 0
                to: 1
                duration: 200
            }
        }

        Rectangle {
            id: taskListBackground
            anchors.fill: parent
            color: "#4CAF50"  // 更柔和的绿色
            radius: 12
            opacity: 0.95

            // 添加阴影效果
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 3
                verticalOffset: 3
                radius: 8.0
                samples: 17
                color: "#80000000"
            }

            // 标题栏
            Rectangle {
                id: titleBar
                height: 40
                color: "#388E3C"  // 深一点的绿色作为标题栏
                radius: 12
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                // 底部直角
                Rectangle {
                    height: parent.height/2
                    color: parent.color
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                }

                Text {
                    text: "任务列表"
                    color: "white"
                    font {
                        pixelSize: 16
                        bold: true
                    }
                    anchors.centerIn: parent
                }
            }

            // 任务列表区域
            Column {
                anchors {
                    top: titleBar.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: 15
                }
                spacing: 12

                Repeater {
                    model: deskMate.taskCount
                    delegate: Rectangle {
                        id: taskItem
                        property var currentTask: deskMate.getTask(index)
                        width: parent.width
                        height: 45
                        color: "transparent"
                        radius: 6

                        // 监听任务变化
                        Connections {
                            target: deskMate
                            function onTasksChanged() {
                                taskItem.currentTask = deskMate.getTask(index)
                            }
                        }

                        // 任务项背景（鼠标悬停效果）
                        Rectangle {
                            anchors.fill: parent
                            color: taskMouseArea.containsMouse ? "#40FFFFFF" : "transparent"
                            radius: 6
                            
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }

                        Row {
                            anchors {
                                fill: parent
                                leftMargin: 8
                                rightMargin: 8
                            }
                            spacing: 10

                            CheckBox {
                                id: taskCheckBox
                                width: 30
                                anchors.verticalCenter: parent.verticalCenter
                                text: ""
                                checked: currentTask ? currentTask.completed : false
                                
                                indicator: Rectangle {
                                    width: 20
                                    height: 20
                                    radius: 4
                                    border.color: taskCheckBox.checked ? "#388E3C" : "#80FFFFFF"
                                    border.width: 2
                                    color: taskCheckBox.checked ? "#388E3C" : "transparent"

                                    Text {
                                        visible: taskCheckBox.checked
                                        text: "✓"
                                        color: "white"
                                        anchors.centerIn: parent
                                        font.pixelSize: 14
                                    }

                                    Behavior on border.color {
                                        ColorAnimation { duration: 150 }
                                    }
                                }

                                onCheckedChanged: {
                                    deskMate.updateTaskStatus(index, checked)
                                }
                            }

                            TextEdit {
                                id: taskText
                                width: parent.width - taskCheckBox.width - 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: currentTask ? currentTask.text : ""
                                color: "white"
                                font {
                                    pixelSize: 14
                                    family: "Microsoft YaHei"
                                    strikeout: currentTask ? currentTask.completed : false
                                }
                                wrapMode: TextEdit.Wrap
                                selectByMouse: true
                                selectedTextColor: "black"
                                selectionColor: "#80FFFFFF"

                                onTextChanged: {
                                    if (text !== (currentTask ? currentTask.text : "")) {
                                        deskMate.updateTaskText(index, text)
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: taskMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                        }
                    }
                }
            }
        }
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

        // 鼠标事件处理
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            property point startPos
            property bool isDragging: false

            onPressed: {
                startPos = Qt.point(mouse.x, mouse.y)
                if (mouse.button === Qt.LeftButton) {
                    isDragging = true
                    taskListWindow.visible = false
                }
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

            onClicked: {
                if (mouse.button === Qt.RightButton) {
                    // 显示任务列表窗口在精灵窗口下方
                    taskListWindow.x = mainWindow.x
                    taskListWindow.y = mainWindow.y + mainWindow.height
                    taskListWindow.visible = true
                }
            }

            onDoubleClicked: {
                if (mouse.button === Qt.LeftButton) {
                    settingsDialog.open()
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
        objectName: "settingsDialog"  // 添加 objectName 以便从 C++ 访问
        x: Screen.width / 2 - width / 2
        y: Screen.height / 2 - height / 2
    }
}
