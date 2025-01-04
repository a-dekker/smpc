import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    menu: contextMenu
    contentHeight: ((listImageSize  === 1) || (listImageSize  === 0)  ? Theme.itemSizeSmall : (listImageSize  === 2 ? Theme.itemSizeMedium : Theme.itemSizeLarge) )
    Row {
        id: mainRow
        height: parent.height
        spacing: Theme.paddingSmall
        anchors {
            right: parent.right
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: listPadding
            rightMargin: listPadding
        }
        Rectangle {
            id: imageRectangle
            color: Theme.rgba(Theme.highlightBackgroundColor,0.2)
            width: ( listImageSize !== 0 ) ? mainRow.height : 0
            height: mainRow.height
            Image{
                id: albumPicture
                anchors.fill: parent
                cache: false
                asynchronous: true
                source: ( listImageSize === 0 ) ? "" : coverURL
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            Label {
                id: albumLabel
                text: (title === "" ? qsTr("No album tag") : title)
                truncationMode: TruncationMode.Fade
                width: mainRow.width - imageRectangle.width
            }
            Label {
                id: artistLabel
                text: (artist === "" ? qsTr("No artist tag") : artist)
                truncationMode: TruncationMode.Fade
                width: mainRow.width - imageRectangle.width
            }
        }
    }

    function playAlbumRemorse() {
        remorseAction(qsTr("Playing album"), function () {
            ctl.player.playlist.playAlbum(artist, title)
        }, remorseTimerSecs * 1000)
    }
    function addAlbumRemorse() {
        remorseAction(qsTr("Adding album"), function () {
            ctl.player.playlist.addAlbum(artist, title)
        }, remorseTimerSecs * 1000)
    }
    Component {
        id: contextMenu
        ContextMenu {
            MenuItem {
                text: qsTr("Play album")
                onClicked: {
                    if (title !== "") {
                        playAlbumRemorse()
                    }
                }
            }

            MenuItem {
                text: qsTr("Add album to list")
                onClicked: {
                    if (title !== "") {
                        addAlbumRemorse()
                    }
                }
            }
        }
    }
}
