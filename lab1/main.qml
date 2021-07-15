import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Tabs")

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        Page1Form {
            id: pg
            width: 600
            height: 400
            GridLayout{
                id: gridHIGH
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left



                rows: 1
                columns: 2
                Label{

                    id: head
                    text: qsTr("ЛР1 Ознакомление")
                    color: "white"
                    font.pixelSize: Qt.application.font.pixelSize * 2
                    padding: 10
                    Layout.preferredWidth: 15
                    Layout.row: 0
                    Layout.column: 0
                    Layout.columnSpan: 2
                    Layout.minimumHeight: 65
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    background: Rectangle{
                        id:headBack
                        color:"black"
                    }
                }
                RowLayout{

                    spacing: 100
                    Layout.row: 0
                    Layout.column: 1
                    anchors.right: parent.right


                    Image{
                        id: search
                        source: "Downloads/search.svg"
                        Layout.column: 0
                        Layout.preferredWidth: 25
                        Layout.preferredHeight: 25

                        }

                Image{
                    source: "Downloads/gear.svg"
                    Layout.column: 1
                    Layout.preferredWidth: 25
                    Layout.preferredHeight: 25
                    Layout.rightMargin: 25

                }


                }
            }
            GridLayout{
                id: gridLOW
                columns: 3
                anchors.top: gridHIGH.bottom

                anchors.right: parent.right
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.margins: 5
                anchors.rightMargin: 10

                DelayButton{
                    Layout.row: 0
                    Layout.column: 0


                    id: control
                         checked: false
                         text: qsTr("Вы\nготовы?")

                         contentItem: Text {
                             text: control.text
                             font: control.font
                             opacity: enabled ? 1.0 : 0.3
                             color: "white"
                             horizontalAlignment: Text.AlignHCenter
                             verticalAlignment: Text.AlignVCenter
                             elide: Text.ElideRight
                         }

                         background: Rectangle {
                             implicitWidth: 100
                             implicitHeight: 100
                             opacity: enabled ? 1 : 0.3
                             color: control.checked ? "green" : "black"

                             radius: size / 2

                             readonly property real size: Math.min(control.width, control.height)
                             width: size
                             height: size
                             anchors.centerIn: parent

                             Canvas {
                                 id: canvas
                                 anchors.fill: parent

                                 Connections {
                                     target: control
                                     function onProgressChanged() { canvas.requestPaint(); }
                                 }

                                 onPaint: {
                                     var ctx = getContext("2d")
                                     ctx.clearRect(0, 0, width, height)
                                     ctx.strokeStyle = "white"
                                     ctx.lineWidth = parent.size / 20
                                     ctx.beginPath()
                                     var startAngle = Math.PI / 5 * 3
                                     var endAngle = startAngle + control.progress * Math.PI / 5 * 9
                                     ctx.arc(width / 2, height / 2, width / 2 - ctx.lineWidth / 2 - 2, startAngle, endAngle)
                                     ctx.stroke()
                                 }
                             }
                         }


                }
                RangeSlider{
                  id: rng
                  Layout.row: 0
                  Layout.column: 1
                  Layout.columnSpan: 2

                  Layout.fillWidth: true
                  background: Rectangle {
                           x: rng.leftPadding
                           y: rng.topPadding + rng.availableHeight / 2 - height / 2
                           implicitWidth: 200
                           implicitHeight: 4
                           width: rng.availableWidth
                           height: implicitHeight
                           radius: 2
                           color: "#bdbebf"

                           Rectangle {
                               x: rng.first.visualPosition * parent.width
                               width: rng.second.visualPosition * parent.width - x
                               height: parent.height
                               color: "black"
                               radius: 2
                           }
                       }

                       first.handle: Rectangle {
                           x: rng.leftPadding + rng.first.visualPosition * (rng.availableWidth - width)
                           y: rng.topPadding + rng.availableHeight / 2 - height / 2
                           implicitWidth: 26
                           implicitHeight: 26

                           color: rng.first.pressed ? "#f0f0f0" : "#f6f6f6"
                           border.color: "#bdbebf"
                       }

                       second.handle: Rectangle {
                           x: rng.leftPadding + rng.second.visualPosition * (rng.availableWidth - width)
                           y: rng.topPadding + rng.availableHeight / 2 - height / 2
                           implicitWidth: 26
                           implicitHeight: 26

                           color: rng.second.pressed ? "#f0f0f0" : "#f6f6f6"
                           border.color: "#bdbebf"
                       }
                }

                ColumnLayout {
                    Layout.row: 1
                    Layout.column: 0
                    Layout.columnSpan: 1
                     CheckBox {
                         checked: true
                         text: qsTr("Студент")
                     }
                     CheckBox {
                         text: qsTr("Комсомолец")
                     }
                     CheckBox {
                         checked: true
                         text: qsTr("Спортсмен")
                     }
                 }
                Tumbler{
                    Text {
                        id: name
                        text: qsTr("Стипендия")
                        font.pixelSize: Qt.application.font.pixelSize * 1.5
                        anchors.topMargin: 15
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    id: tmbl
                    Layout.row: 1
                    Layout.column: 1
                    Layout.columnSpan: 2
                    model:4
                    Layout.fillWidth: true
                    background: Item {
                            Rectangle {
                                opacity: tmbl.enabled ? 0.2 : 0.1
                                border.color: "#000000"
                                width: parent.width
                                height: 1
                                anchors.top: parent.top
                            }

                            Rectangle {
                                opacity: tmbl.enabled ? 0.2 : 0.1
                                border.color: "#000000"
                                width: parent.width
                                height: 1
                                anchors.bottom: parent.bottom
                            }
                        }

                        delegate: Text {
                            text: qsTr("%1").arg(modelData*1000 )
                            font: tmbl.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            opacity: 1.0 - Math.abs(Tumbler.displacement) / (tmbl.visibleItemCount / 2)
                        }

                        Rectangle {
                            anchors.horizontalCenter: tmbl.horizontalCenter
                            y: tmbl.height * 0.4
                            width: 40
                            height: 1
                            color: "black"
                        }

                        Rectangle {
                            anchors.horizontalCenter: tmbl.horizontalCenter
                            y: tmbl.height * 0.6
                            width: 40
                            height: 1
                            color: "black"
                        }
                }
                Slider{
                    id: sl1
                    Layout.row: 2
                    Layout.column: 0
                    from: 1
                    value: 1
                    to: 100
                }
                ProgressBar{
                    Layout.row: 2
                    Layout.column: 1
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    from: 1
                    to:100
                    value: sl1.value

                }

            }

        }

        Page2Form {
        }
    }

    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex

        TabButton {
            text: qsTr("Page 1")
        }
        TabButton {
            text: qsTr("Page 2")
        }
    }
}
