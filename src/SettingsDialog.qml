import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import QtQuick.Window 2.15

Window {
    id: settingsDialog
    width: 400
    height: 350
    title: "设置"
    flags: Qt.Window | Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint
    visible: false
    color: "transparent"

    property point startPos
    property string tempSingleImagePath: ""
    property string tempFolderPath: ""
    property bool tempIsFolderMode: false
    property int tempIntervalTime: 1000

    // 初始化临时变量
    onVisibleChanged: {
        if (visible) {
            tempFolderPath = deskMate.folderImagePath
            tempSingleImagePath = deskMate.gifImagePath
            tempIsFolderMode = deskMate.isFolderMode
            tempIntervalTime = deskMate.intervalTime
        }
    }

    Rectangle {
        id: windowFrame
        anchors.fill: parent
        color: "#ffffff"
        radius: 8
        border.width: 1
        border.color: "#d0d0d0"

        // 标题栏
        Rectangle {
            id: titleBar
            height: 32
            color: "#f5f5f5"
            radius: 8
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            Text {
                text: "设置"
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 13
                font.bold: true
                color: "#404040"
            }

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    startPos = Qt.point(mouse.x, mouse.y)
                }
                onPositionChanged: {
                    if (mouse.buttons & Qt.LeftButton) {
                        var delta = Qt.point(mouse.x - startPos.x, mouse.y - startPos.y)
                        settingsDialog.x += delta.x
                        settingsDialog.y += delta.y
                    }
                }
            }
        }

        // 内容区域
        ColumnLayout {
            anchors {
                top: titleBar.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 16
            }
            spacing: 0

            GroupBox {
                Layout.fillWidth: true
                Layout.preferredHeight: 250
                padding: 8
                topPadding: 8
                background: Rectangle {
                    color: "#ffffff"
                    border.color: "#e0e0e0"
                    radius: 4
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    RadioButton {
                        id: singleImageMode
                        text: "单个图片模式"
                        checked: !tempIsFolderMode
                        onCheckedChanged: tempIsFolderMode = !checked
                        padding: 0
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: -4
                        enabled: singleImageMode.checked
                        spacing: 6

                        TextField {
                            id: singleImagePath
                            Layout.fillWidth: true
                            text: tempSingleImagePath
                            placeholderText: "选择图片文件"
                            readOnly: true
                            font.pixelSize: 12
                            leftPadding: 8
                            rightPadding: 8
                            height: 26
                            background: Rectangle {
                                border.color: "#e0e0e0"
                                radius: 3
                            }
                        }

                        Button {
                            text: "浏览"
                            implicitWidth: 50
                            implicitHeight: 26
                            font.pixelSize: 12
                            onClicked: singleFileDialog.open()
                        }
                    }

                    RadioButton {
                        id: folderMode
                        text: "文件夹模式"
                        checked: tempIsFolderMode
                        padding: 0
                        Layout.topMargin: 4
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: -4
                        enabled: folderMode.checked
                        spacing: 6

                        TextField {
                            id: folderPath
                            Layout.fillWidth: true
                            text: tempFolderPath
                            placeholderText: "选择图片文件夹"
                            readOnly: true
                            font.pixelSize: 12
                            leftPadding: 8
                            rightPadding: 8
                            height: 26
                            background: Rectangle {
                                border.color: "#e0e0e0"
                                radius: 3
                            }
                        }

                        Button {
                            text: "浏览"
                            implicitWidth: 50
                            implicitHeight: 26
                            font.pixelSize: 12
                            onClicked: folderDialog.open()
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        enabled: folderMode.checked
                        spacing: 6

                        Label {
                            text: "切换间隔(毫秒):"
                            font.pixelSize: 12
                        }

                        SpinBox {
                            id: intervalSpinBox
                            from: 100
                            to: 10000
                            stepSize: 100
                            value: tempIntervalTime
                            onValueChanged: tempIntervalTime = value
                            font.pixelSize: 12
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }

            // 底部按钮
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Layout.alignment: Qt.AlignRight

                Button {
                    text: "取消"
                    implicitWidth: 64
                    implicitHeight: 26
                    font.pixelSize: 12
                    onClicked: settingsDialog.visible = false
                }

                Button {
                    text: "保存"
                    implicitWidth: 64
                    implicitHeight: 26
                    font.pixelSize: 12
                    onClicked: {
                        // 更新设置
                        deskMate.isFolderMode = tempIsFolderMode;
                        if (tempIsFolderMode) {
                            deskMate.setGifImagePath(tempSingleImagePath)
                            deskMate.setImagePath(tempFolderPath);
                        } else {
                            deskMate.setFolderImagePath(tempFolderPath)
                            deskMate.setImagePath(tempSingleImagePath);
                        }
                        console.log(deskMate.isFolderMode, deskMate.imagePath);
                        deskMate.intervalTime = tempIntervalTime;
                        deskMate.updateImage(); // 通知更新图片
                        settingsDialog.visible = false;
                    }
                }
            }
        }
    }

    FileDialog {
        id: singleFileDialog
        title: "选择图片文件"
        nameFilters: ["图片文件 (*.jpg *.jpeg *.png *.gif *.bmp)"]
        selectMultiple: false
        onAccepted: {
            tempSingleImagePath = fileUrl.toString().replace("file:///", "")
        }
    }

    FileDialog {
        id: folderDialog
        title: "选择图片文件夹"
        selectFolder: true
        onAccepted: {
            tempFolderPath = folder.toString().replace("file:///", "")
        }
    }

    function open() {
        show()
        raise()
    }

    function close() {
        visible = false
    }
}
