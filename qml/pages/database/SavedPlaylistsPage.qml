import QtQuick 2.2
import Sailfish.Silica 1.0
import "../../components"

Page {
    id: savedPlaylistPage
    property string artistname
    SilicaListView {
        id: savedPlaylistsListView
        SpeedScroller {
            listview: savedPlaylistsListView
        }
        ScrollDecorator {
        }
        quickScroll: jollaQuickscroll
        anchors.fill: parent
        contentWidth: width
        header: PageHeader {
            title: qsTr("Playlists")
        }
        model: savedPlaylistsModel
        delegate: ListItem {
            menu: contextMenu
            Column {
                id: mainColumn
                anchors {
                    right: parent.right
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: listPadding
                    rightMargin: listPadding
                }
                Label {
                    text: modelData
                }
            }
            OpacityRampEffect {
                sourceItem: mainColumn
                slope: 3.5
                offset: 0.75
            }
            onClicked: {
                savedPlaylistClicked(modelData)
                pageStack.push(Qt.resolvedUrl("PlaylistTracksPage.qml"), {
                                   "playlistname": modelData
                               })
            }
            function playListRemorse() {
                remorseAction(qsTr("Playing list"), function () {
                    playPlaylist(modelData)
                }, remorseTimerSecs * 1000)
            }
            function addListRemorse() {
                remorseAction(qsTr("Adding list"), function () {
                    addPlaylist(modelData)
                }, remorseTimerSecs * 1000)
            }
            Component {

                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text: qsTr("Play playlist")
                        onClicked: {
                            playListRemorse()
                        }
                    }

                    MenuItem {
                        text: qsTr("Add list")
                        onClicked: {
                            addListRemorse()
                        }
                    }
                }
            }
        }
    }
    Component.onDestruction: {
        clearPlaylists()
    }
}
