import QtQuick 2.2
import Sailfish.Silica 1.0
import "../components"
import QtQml.Models 2.2

Page {
    id: mainPage
    property list<Component> mainMenuBtn: [
        Component {
            MainMenuItem {
                text: qsTr("Saved playlists")
                iconSource: "image://theme/icon-m-document"
                onClicked: {

                }
            }
        },
        Component {
            MainMenuItem {
                text: qsTr("Shuffle all")
                iconSource: "image://theme/icon-m-shuffle"
                onClicked: {

                }
            }
        }
    ]

    SilicaGridView {
        id: gridView
        property int columns: Screen.sizeCategory
                              >= Screen.Large ? 3 : (orientation === Orientation.Landscape
                                                     || orientation
                                                     === Orientation.LandscapeInverted) ? 4 : 2
        anchors.top: mainPage.top
        anchors.bottom: mainPage.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        property bool landscape: orientation === Orientation.Landscape
                                 || orientation === Orientation.LandscapeInverted
        property int rows: Math.ceil((columns === 3 ? 9 : 8) / columns)
        property real maxCellSize: mainPage.width * 0.7 / columns
        // in landscape make sure all rows fit above the control panel;
        // its full height is used so opening/closing it does not resize the grid;
        // the screen size is used because mainPage.height shrinks with the panel
        property real fitCellSize: (Math.min(
                                        Screen.width,
                                        Screen.height) - (headerItem ? headerItem.height : 0)
                                    - quickControlPanel.height) / rows
        width: columns * cellWidth

        header: Item {
            width: GridView.view.width
            height: headerCol.height
            Column {
                id: headerCol
                width: mainPage.width
                anchors.horizontalCenter: parent.horizontalCenter
                PageHeader {
                    title: "SMPC"
                }
                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: connected ? qsTr("Connected to: %1").arg(
                                          profilename) : qsTr("Disconnected")
                    color: Theme.highlightColor
                }
            }
        }

        cellWidth: landscape ? Math.min(maxCellSize, fitCellSize) : maxCellSize
        cellHeight: cellWidth

        model: ObjectModel {
            MainMenuItem {
                text: qsTr("Playlist")
                iconSource: "image://theme/icon-m-document"
                onClicked: if (connected)
                               pageStack.push(
                                           Qt.resolvedUrl(
                                               "database/CurrentPlaylistPage.qml"))
            }
            MainMenuItem {
                text: qsTr("Artists")
                iconSource: "image://theme/icon-m-mic"
                enabled: connected
                onClicked: {
                    if (connected) {
                        requestArtists()
                        pageStack.push(Qt.resolvedUrl(
                                           "database/ArtistListPage.qml"))
                    }
                }
            }

            MainMenuItem {
                text: qsTr("Albums")
                iconSource: "image://theme/icon-m-music"
                onClicked: {
                    artistname = ""
                    if (connected) {
                        requestAlbums()
                        pageStack.push(Qt.resolvedUrl(
                                           "database/AlbumListPage.qml"), {
                                           "artistname": artistname
                                       })
                    }
                }
            }

            MainMenuItem {
                text: qsTr("Files")
                iconSource: "image://theme/icon-m-folder"
                onClicked: if (connected)
                               filesClicked("/")
            }

            MainMenuItem {
                text: qsTr("Search")
                iconSource: "image://theme/icon-m-search"
                onClicked: if (connected)
                               pageStack.push(Qt.resolvedUrl(
                                                  "database/SearchPage.qml"))
            }

            MainMenuItem {
                text: qsTr("Connect")
                iconSource: "image://theme/icon-m-computer"
                onClicked: pageStack.push(Qt.resolvedUrl(
                                              "settings/ConnectServerPage.qml"))
            }
            MainMenuItem {
                text: qsTr("Settings")
                iconSource: "image://theme/icon-m-developer-mode"
                onClicked: pageStack.push(Qt.resolvedUrl(
                                              "settings/SettingsPage.qml"))
            }
            MainMenuItem {
                text: qsTr("About")
                iconSource: "image://theme/icon-m-about"
                onClicked: pageStack.push(Qt.resolvedUrl(
                                              "settings/AboutPage.qml"))
            }
            Loader {
                active: gridView.columns === 3
                sourceComponent: Component {
                    MainMenuItem {
                        width: gridView.cellWidth
                        text: qsTr("Playback")
                        iconSource: "image://theme/icon-m-music"
                        onClicked: pageStack.push(
                                       Qt.resolvedUrl(
                                           "settings/PlaybackSettings.qml"))
                    }
                }
            }
        }
    }

    Timer {
        id: showCurrentSongTimer
        interval: 15000
        repeat: false
        onTriggered: {
            if (connected) {
                pageStack.navigateForward(PageStackAction.Animated)
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            if (mPlaylistPage == undefined) {
                /* Check if running on large device and load corresponding page */
                if (Screen.sizeCategory >= Screen.Large) {
                    var playlistComponent = Qt.createComponent(
                                Qt.resolvedUrl(
                                    "database/CurrentPlaylistPage_large.qml"))
                    var playlistPage = playlistComponent.createObject(
                                mainWindow)
                } else {
                    var playlistComponent = Qt.createComponent(
                                Qt.resolvedUrl(
                                    "database/CurrentPlaylistPage.qml"))
                    var playlistPage = playlistComponent.createObject(
                                mainWindow)
                }
                mPlaylistPage = playlistPage
            }

            pageStack.pushAttached(mPlaylistPage)
            showCurrentSongTimer.start()
        } else if (status === PageStatus.Deactivating) {
            if (showCurrentSongTimer.running) {
                showCurrentSongTimer.stop()
            }
        }
    }
}
