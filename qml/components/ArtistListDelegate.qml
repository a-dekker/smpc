import QtQuick 2.2
import Sailfish.Silica 1.0

Component {
    ListItem {
        menu: contextMenu
        contentHeight: ((listImageSize === 1)
                        || (listImageSize === 0) ? Theme.itemSizeSmall : (listImageSize === 2 ? Theme.itemSizeMedium : Theme.itemSizeLarge))
        Row {
            id: mainRow
            height: parent.height
            anchors {
                right: parent.right
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: listPadding
                rightMargin: listPadding
            }
            spacing: Theme.paddingSmall
            Rectangle {
                id: imageRectangle
                color: Theme.rgba(Theme.highlightBackgroundColor, 0.2)
                width: (listImageSize !== 0) ? mainRow.height : 0
                height: mainRow.height
                Image {
                    anchors.fill: parent
                    cache: false
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true

                    /*sourceSize.width: width
                    sourceSize.height: height*/
                    source: (listImageSize === 0) ? "" : imageURL
                }
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: artist === "" ? qsTr("No Artist Tag") : artist
            }
        }
        OpacityRampEffect {
            sourceItem: mainRow
            slope: 3
            offset: 0.65
        }
        onClicked: {
            artistListView.currentIndex = index
            artistClicked(artist)
            pageStack.push(Qt.resolvedUrl(
                               "../pages/database/AlbumListPage.qml"), {
                               "artistname": artistname
                           })
        }
        function playArtistRemorse() {
            remorseAction(qsTr("Playing artist"), function () {
                ctl.player.playlist.playArtist(artist)
            }, remorseTimerSecs * 1000)
        }
        function addArtistRemorse() {
            remorseAction(qsTr("Adding artist"), function () {
                ctl.player.playlist.addArtist(artist)
            }, remorseTimerSecs * 1000)
        }
        Component {
            id: contextMenu
            ContextMenu {
                MenuItem {
                    text: qsTr("Play artist")
                    onClicked: {
                        if (artist !== "") {
                            playArtistRemorse()
                        }
                    }
                }

                MenuItem {
                    text: qsTr("Add artist to list")
                    onClicked: {
                        if (artist !== "") {
                            addArtistRemorse()
                        }
                    }
                }
            }
        }
    }
}
