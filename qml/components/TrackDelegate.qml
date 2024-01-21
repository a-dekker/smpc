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
        width: parent.width
        height: parent.height
        opacity: 0.5
        radius: 10
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Theme.rgba(Theme.primaryColor, 0.1)
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
        height: Math.max(trackRow.height + artistLbl.height,
                         Theme.itemSizeSmall)
        anchors {
            right: parent.right
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: listPadding
            rightMargin: listPadding
        }
        Row {
            id: trackRow
            Label {
                id: numberLbl
                text: "%1. ".arg(model.index + 1)
                anchors {
                    verticalCenter: parent.verticalCenter
                }
            }
            Label {
                id: titleLbl
                anchors.verticalCenter: parent.verticalCenter
                clip: true
                wrapMode: Text.WrapAnywhere
                elide: Text.ElideRight
                font.italic: ctl.player.playbackStatus.playbackStatus === 0 && model.playing
                font.bold: model.playing
                color: model.playing ? Theme.highlightColor : Theme.primaryColor
                text: (model.title === "" ? model.filename + " " : model.title + " ")
            }
            Label {
                id: lengthLbl
                anchors.verticalCenter: parent.verticalCenter
                text: (model.length === 0 ? "" : " (" + lengthformated + ")")
            }
        }
        Label {
            id: artistLbl
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            text: (model.artist !== "" ? model.artist + " - " : "")
                  + (model.album !== "" ? model.album : "")
        }
    }
    OpacityRampEffect {
        sourceItem: mainColumn
        slope: 3.5
        offset: 0.75
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
            text: qsTr("Show artist")
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
                albumClicked("", model.album)
                pageStack.push(Qt.resolvedUrl(
                                   "../pages/database/AlbumTracksPage.qml"), {
                                   "artistname": "",
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
