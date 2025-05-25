import QtQuick 2.2
import Sailfish.Silica 1.0

Component {
    ListItem {
        id: filesDelegate
        menu: contextMenu
        contentHeight: fileicon.height
        Image {
            id: fileicon
            height: (filenametext.height + trackLabel
                     >= Theme.itemSizeSmall ? filenametext.height
                                              + trackLabel : Theme.itemSizeSmall)
            anchors {
                leftMargin: listPadding
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
            source: (isDirectory ? "image://theme/icon-m-folder" : (isPlaylist ? "image://theme/icon-m-document" : imageURL))
            width: height
        }
        Label {
            id: filenametext
            text: name
            wrapMode: "NoWrap"
            elide: Text.ElideMiddle
            anchors {
                verticalCenter: isFile ? undefined : parent.verticalCenter
                top: isFile ? parent.top : undefined
                left: fileicon.right
                right: parent.right
                rightMargin: listPadding
                leftMargin: Theme.paddingMedium
            }
            width: parent.width - Theme.paddingSmall
            truncationMode: TruncationMode.Fade
        }
        Label {
            id: trackLabel
            visible: isFile
            text: (!isFile ? "" : (title === "" ? "" : title + " - ")
                             + (artist === "" ? "" : artist))
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryColor
            width: parent.width - Theme.paddingSmall
            truncationMode: TruncationMode.Fade
            anchors {
                top: filenametext.bottom
                left: fileicon.right
                right: parent.right
                rightMargin: listPadding
                leftMargin: Theme.paddingMedium
            }
        }
        onClicked: {
            if (isDirectory) {
                lastContentPosY = index
                filesClicked((prepath == "/" ? "" : prepath + "/") + name)
            }
            if (isFile) {
                albumTrackClicked(title, album, artist, length, path, year,
                                  tracknr, discnr, trackmbid, artistmbid,
                                  albummbid, genre)
            }
            if (isPlaylist) {
                savedPlaylistClicked(
                            (prepath == "/" ? "" : prepath + "/") + name)
                pageStack.push(Qt.resolvedUrl(
                                   "../pages/database/PlaylistTracksPage.qml"),
                               {
                                   "playlistname": name
                               })
            }
        }

        function addTrackRemorse() {
            remorseAction(qsTr("adding track"), function () {
                ctl.player.playlist.addTrack(path)
            }, remorseTimerSecs * 1000)
        }
        function addTrackAfterCurrentRemorse() {
            remorseAction(qsTr("adding track"), function () {
                ctl.player.playlist.addTrackAfterCurrent(path)
            }, remorseTimerSecs * 1000)
        }
        function addPlaylistRemorse() {
            remorseAction(qsTr("adding playlist"), function () {
                addPlaylist((prepath == "/" ? "" : prepath + "/") + name)
            }, remorseTimerSecs * 1000)
        }
        function addFolderRemorse() {
            remorseAction(qsTr("adding directory"), function () {
                ctl.player.playlist.addTrack(
                            (prepath == "/" ? "" : prepath + "/") + name)
            }, remorseTimerSecs * 1000)
        }
        function playTrackRemorse() {
            remorseAction(qsTr("playing track"), function () {
                ctl.player.playlist.playTrack(path)
            }, remorseTimerSecs * 1000)
        }
        function playPlaylistRemorse() {
            remorseAction(qsTr("playing playlist"), function () {
                playPlaylist((prepath == "/" ? "" : prepath + "/") + name)
            }, remorseTimerSecs * 1000)
        }
        function playFolderRemorse() {
            remorseAction(qsTr("playing directory"), function () {
                ctl.player.playlist.playTrack(
                            (prepath == "/" ? "" : prepath + "/") + name)
            }, remorseTimerSecs * 1000)
        }
        Component {
            id: contextMenu
            ContextMenu {
                MenuItem {
                    text: isFile ? qsTr(
                                       "Play file") : (isDirectory ? qsTr("Play directory") : qsTr(
                                                                         "Play playlist"))
                    onClicked: {
                        if (isFile) {
                            playTrackRemorse()
                        } else if (isDirectory) {
                            playFolderRemorse()
                        } else if (isPlaylist) {
                            playPlaylistRemorse()
                        }
                    }
                }

                MenuItem {
                    text: isFile ? qsTr(
                                       "Add file") : (isDirectory ? qsTr("Add directory") : qsTr(
                                                                        "Add playlist"))
                    onClicked: {
                        if (isFile) {
                            addTrackRemorse()
                        } else if (isDirectory) {
                            addFolderRemorse()
                        } else if (isPlaylist) {
                            addPlaylistRemorse()
                        }
                    }
                }
                MenuItem {
                    enabled: isFile
                    visible: isFile
                    text: qsTr("Play after current")
                    onClicked: {
                        addTrackAfterCurrentRemorse()
                    }
                }
                MenuItem {
                    enabled: isFile
                    visible: isFile
                    text: qsTr("Add to saved list")
                    onClicked: {
                        requestSavedPlaylists()
                        pageStack.push(
                                    Qt.resolvedUrl(
                                        "../pages/database/AddToPlaylistDialog.qml"),
                                    {
                                        "url": path
                                    })
                    }
                }
            }
        }
    }
}
