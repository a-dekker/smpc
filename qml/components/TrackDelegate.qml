import QtQuick 2.2
import Sailfish.Silica 1.0

ListItem {
    id: item

    function remove() {
        remorseAction(qsTr("Deleting"), function () {
            ctl.player.playlist.deleteTrack(model.index)
            item.ListView.view.mDeleteRemorseRunning = false
        }, mainWindow.remorseTimeout)
    }

    Rectangle {
        width: parent.width * (ctl.player.playbackStatus.currentTime
                               / ctl.player.playbackStatus.length)
        height: parent.height
        opacity: 0.8
        radius: 10
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Theme.rgba(Theme.primaryColor, 0.2)
            }
            GradientStop {
                position: 1.0
                color: Theme.rgba(Theme.primaryColor, 0.05)
            }
        }
        visible: model.playing
    }

    contentHeight: mainColumn.height

    Column {
        id: mainColumn
        clip: true
        height: Math.max(titleLbl.height + artistLbl.height,
                         Theme.itemSizeSmall)
        anchors {
            right: parent.right
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: listPadding
            rightMargin: listPadding
        }
        Label {
            id: titleLbl
            text: "%1. ".arg(model.index + 1)
                  + (model.title === "" ? model.filename + " " : model.title + " ")
                  + (model.length === 0 ? "" : " (" + lengthformated + ")")
            font.italic: ctl.player.playbackStatus.playbackStatus === 0
                         && model.playing
            font.bold: model.playing
            color: model.playing ? Theme.highlightColor : Theme.primaryColor
            truncationMode: TruncationMode.Fade
            width: parent.width
        }
        Label {
            id: artistLbl
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            text: (model.artist !== "" ? model.artist + " - " : "")
                  + (model.album !== "" ? model.album : "")
            width: parent.width
            truncationMode: TruncationMode.Fade
        }
    }

    menu: ContextMenu {
        MenuItem {
            text: qsTr("Remove song")
            visible: !playlistView.mDeleteRemorseRunning
            enabled: !playlistView.mDeleteRemorseRunning
            onClicked: {
                playlistView.mDeleteRemorseRunning = true
                remove()
                playlistView.mDeleteRemorseRunning = false
            }
        }

        MenuItem {
            text: qsTr("Show albums from artist")
            onClicked: {
                artistClicked(model.artist)
                pageStack.push(Qt.resolvedUrl(
                                   "../pages/database/AlbumListPage.qml"), {
                                   "artistname": model.artist
                               })
            }
        }

        MenuItem {
            text: qsTr("Show album")
            onClicked: {
                console.log(model.album)
                albumClicked(model.artist, model.album)
                pageStack.push(Qt.resolvedUrl(
                                   "../pages/database/AlbumTracksPage.qml"), {
                                   "artistname": model.artist,
                                   "albumname": model.album
                               })
            }
        }
        MenuItem {
            visible: !model.playing
            text: qsTr("Play as next")
            onClicked: {
                playNextWOTimer.windUp(model.index)
            }
        }

        MenuItem {
            visible: model.playing
            text: qsTr("Show information")
            onClicked: pageStack.navigateForward(PageStackAction.Animated)
        }

        MenuItem {
            text: qsTr("Add to saved list")
            onClicked: {
                requestSavedPlaylists()
                pageStack.push(
                            Qt.resolvedUrl(
                                "../pages/database/AddToPlaylistDialog.qml"), {
                                "url": model.path
                            })
            }
        }
    }
    onClicked: {
        ListView.view.currentIndex = model.index
        if (!model.playing) {
            ctl.player.playlist.playTrackNumber(model.index)
        } else {
            pageStack.navigateForward(PageStackAction.Animated)
        }
    }
}
