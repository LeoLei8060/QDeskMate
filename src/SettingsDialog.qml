import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import QtQuick.Window 2.15

Window {
    id: settingsDialog
    width: 400
    height: 300
    title: "设置"
    flags: Qt.Window | Qt.WindowStaysOnTopHint
    visible: false

    Rectangle {
        anchors.fill: parent
        color: "#f0f0f0"
        radius: 5

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            Text {
                text: "设置"
                font.pixelSize: 16
                font.bold: true
            }

            GroupBox {
                title: "图片设置"
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    RadioButton {
                        id: singleImageMode
                        text: "单个图片模式"
                        checked: !deskMate.isFolderMode
                        onCheckedChanged: deskMate.isFolderMode = !checked
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        enabled: singleImageMode.checked

                        TextField {
                            id: singleImagePath
                            Layout.fillWidth: true
                            text: deskMate.imagePath
                            placeholderText: "选择图片文件"
                            readOnly: true
                        }

                        Button {
                            text: "浏览"
                            onClicked: singleFileDialog.open()
                        }
                    }

                    RadioButton {
                        id: folderMode
                        text: "文件夹模式"
                        checked: deskMate.isFolderMode
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        enabled: folderMode.checked

                        TextField {
                            id: folderPath
                            Layout.fillWidth: true
                            text: deskMate.imagePath
                            placeholderText: "选择图片文件夹"
                            readOnly: true
                        }

                        Button {
                            text: "浏览"
                            onClicked: folderDialog.open()
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        enabled: folderMode.checked

                        Label {
                            text: "切换间隔(毫秒):"
                        }

                        SpinBox {
                            id: intervalSpinBox
                            from: 100
                            to: 10000
                            stepSize: 100
                            value: deskMate.intervalTime
                            onValueChanged: deskMate.intervalTime = value
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 10

                Button {
                    text: "确定"
                    onClicked: settingsDialog.hide()
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {} // 防止点击穿透
        }
    }

    FileDialog {
        id: singleFileDialog
        title: "选择图片文件"
        nameFilters: ["图片文件 (*.jpg *.jpeg *.png *.gif *.bmp)"]
        selectMultiple: false
        onAccepted: {
            deskMate.imagePath = fileUrl.toString().replace("file:///", "")
        }
    }

    FileDialog {
        id: folderDialog
        title: "选择图片文件夹"
        selectFolder: true
        onAccepted: {
            deskMate.imagePath = folder.toString().replace("file:///", "")
        }
    }

    function open() {
        show()
        raise()
    }

    function close() {
        hide()
    }
}
