import QtQuick 2.2
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
import "../../components"

Page {
    id: aboutPage

    Component.onDestruction: notification.close()

    Notification {
        id: notification
        appName: "harbour-smpc"
    }

    SilicaFlickable {
        id: aboutFlickable
        anchors.fill: parent
        contentHeight: contentColumn.height
        Column {
            width: parent.width
            id: contentColumn
            PageHeader {
                id: pageHeading
                title: qsTr("About")
            }
            Image {
                id: logo
                source: "qrc:images/smpc.svg"
                sourceSize.height: parent.width
                sourceSize.width: parent.width
                smooth: true
                anchors.horizontalCenter: parent.horizontalCenter
                width: (orientation === Orientation.Portrait ? aboutPage.width - Theme.paddingLarge * 5 : (aboutPage.height - pageHeading.height - nameText.height - versionText.height))
                height: width
                cache: false
                BackgroundItem {
                    id: debugEnabled
                    onPressAndHold: {
                        mDebugEnabled = !mDebugEnabled
                        console.log("Debug: ", mDebugEnabled)
                        notification.previewBody = qsTr("Debuglog toggle in Settings enabled: ") + mDebugEnabled
                        notification.publish()
                    }
                    anchors.fill: parent
                }
            }

            Label {
                id: nameText
                anchors.horizontalCenter: parent.horizontalCenter
                text: "SMPC"
                font.pixelSize: Theme.fontSizeExtraLarge
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("A MPD client for Sailfish OS")
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
            }

            Label {
                id: versionText
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Version: %1").arg(version)
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("source code")
                onClicked: {
                    Qt.openUrlExternally('https://github.com/a-dekker/smpc')
                }
            }
            Separator {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - Theme.paddingLarge
                color: Theme.primaryColor
                horizontalAlignment: Qt.AlignHCenter
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                Label {
                    id: copyLeft
                    text: "©"
                    transform: Rotation {
                        id: mirror
                        origin.x: copyLeft.width / 2
                        axis.x: 0
                        axis.y: 1
                        axis.z: 0
                        angle: 180
                    }
                }

                Label {
                    text: " 2013-2015 Hendrik Borghorst"
                    font.pixelSize: Theme.fontSizeMedium
                }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                Label {
                    text: "©"
                    transform: Rotation {
                        origin.x: copyLeft.width / 2
                        axis.x: 0
                        axis.y: 1
                        axis.z: 0
                        angle: 180
                    }
                }

                Label {
                    text: " 2016-2020 Michael Fuchs/Arno Dekker"
                    font.pixelSize: Theme.fontSizeMedium
                }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                Label {
                    text: "©"
                    transform: Rotation {
                        origin.x: copyLeft.width / 2
                        axis.x: 0
                        axis.y: 1
                        axis.z: 0
                        angle: 180
                    }
                }

                Label {
                    text: " 2021-" + buildyear + " Arno Dekker"
                    font.pixelSize: Theme.fontSizeMedium
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Licensed under GPLv3")
                font.pixelSize: Theme.fontSizeMedium
            }
            Separator {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - Theme.paddingLarge
                color: Theme.primaryColor
                horizontalAlignment: Qt.AlignHCenter
            }
            Label {
                visible: lastfmEnabled
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Fetches metadata from last.fm")
                font.pixelSize: Theme.fontSizeTiny
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Qt.openUrlExternally('https://www.last.fm')
                    }
                }
            }
        }
    }

    onStatusChanged: {
        if ((status === PageStatus.Activating)
                || (status === PageStatus.Active)) {
            quickControlPanel.hideControl = true
        } else {
            quickControlPanel.hideControl = false
        }
    }
}
