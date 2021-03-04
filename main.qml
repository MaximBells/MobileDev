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
            width: 600
            height: 400

            GridLayout{
            Label {
                text: qsTr("ЛР1 Ознакомление")
                font.pixelSize: Qt.application.font.pixelSize * 2
                padding: 10
                color: "white"
                background: Rectangle {
                    id: blackTop
                    width: 640
                    height: 75
                    color: "black"


                }
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
