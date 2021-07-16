import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    id: serverListPage
    SilicaListView {
        id: serverListView
        model: serverList
        anchors.fill: parent
        clip: true
        contentWidth: width
        header: PageHeader {
            title: qsTr("Servers")
        }
        ScrollDecorator {}
        PullDownMenu {
            MenuItem {
                text: qsTr("Add server")
                onClicked: {
                    console.log("Clicked option add server")
                    pageStack.push(Qt.resolvedUrl("ServerEditPage.qml"), {
                                       "newprofile": true
                                   })
                }
            }
        }
        delegate: ListItem {
            contentHeight: Theme.itemSizeSmall
            Image {
                id: image
                x: Theme.paddingLarge
                source: "image://theme/icon-m-computer"
                anchors.verticalCenter: parent.verticalCenter
                opacity: parent.enabled ? 1.0 : 0.4
            }
            Label {
                x: Theme.paddingLarge
                anchors {
                    left: image.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: listPadding
                    rightMargin: listPadding
                }
                text: name
            }

            function removeProfileRemorse() {
                remorseAction(qsTr("Removing server profile"), function () {
                    deleteProfile(index)
                }, remorseTimerSecs * 1000)
            }
            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Remove server profile")
                    onClicked: {
                        removeProfileRemorse()
                    }
                }
            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("ServerEditPage.qml"), {
                                   "hostname": hostname,
                                   "port": port,
                                   "name": name,
                                   "password": password,
                                   "index": index,
                                   "autoconnect": autoconnect,
                                   "macaddress": macaddress,
                                   "newprofile": false
                               })
            }
        }
    }
}
