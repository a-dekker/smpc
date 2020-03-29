import QtQuick 2.2
import Sailfish.Silica 1.0
import harbour.smpc.components 1.0

Page {
	id: savedPlaylistPage
	allowedOrientations: Orientation.All
	property string artistname

	SilicaListView {
		id: savedPlaylistsListView
		quickScrollEnabled: jollaQuickscroll
		anchors.fill: parent
		contentWidth: width

		SpeedScroller {
			listview: savedPlaylistsListView
		}
		ScrollDecorator {}

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
				slope: 3
				offset: 0.65
			}
			onClicked: {
				savedPlaylistClicked(modelData)
				pageStack.push(Qt.resolvedUrl("PlaylistTracksPage.qml"), {playlistname: modelData})
			}
			function playListRemorse() {
				remorseAction(qsTr("playing list"), function() { playPlaylist(modelData) }, 3000)
			}
			function addListRemorse() {
				remorseAction(qsTr("adding list"), function() { addPlaylist(modelData) }, 3000)
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
