import QtQuick 2.2
import Sailfish.Silica 1.0
import "../../components"

Page {
	id: searchpage
	allowedOrientations: Orientation.All
	property int currentindex: -1
	property string selectedsearch

	Drawer {
		id: mainDrawer
		anchors.fill: parent
		open: true
		dock: Dock.Bottom
		backgroundSize: searchhead.height
		background: Column {
			id: searchhead
			spacing: Theme.paddingMedium
			anchors {
				top: parent.top
				left: parent.left
				right: parent.right
			}

			SearchField {
				id: searchfield
				anchors {
					left: parent.left
					right: parent.right
				}
				placeholderText: qsTr("search value")
				text: ""
				//inputMethodHints: Qt.ImhNoPredictiveText
				EnterKey.onClicked: {
					startSearch()
				}
			}

			ComboBox {
				id: searchforcombobox
				label: qsTr("Search for:")
				anchors {
					left: parent.left
					right: parent.right
				}
				menu: ContextMenu {
					MenuItem {
						text: qsTr("titles")
					}
					MenuItem {
						text: qsTr("albums")
					}
					MenuItem {
						text: qsTr("artists")
					}
					MenuItem {
						text: qsTr("files")
					}
				}
			}
		}

		SilicaListView {
			id: searchsongListView
			anchors.fill: parent

			quickScrollEnabled: jollaQuickscroll
			SpeedScroller {
				listview: searchsongListView
			}
			ScrollDecorator {}

			header: PageHeader {
				title: qsTr("search")
				width: searchsongListView.width
			}
//			populate: Transition {
//				NumberAnimation { properties: "x"; from: albumsongs_list_view.width * 2; duration: populateDuration }
//			}
			clip: true
			model: tracksModel

			PullDownMenu {
				enabled: searchsongListView.model !== undefined
				MenuItem {
					text: qsTr("new search")
					visible: searchsongListView.model !== undefined
					onClicked: {
						newSearch()
					}
				}
				MenuItem {
					text: qsTr("add all results")
					visible: searchsongListView.model !== undefined
					onClicked: {
						deletePlaylist()
						addlastsearch()
					}
				}
				MenuItem {
					text: qsTr("play all results")
					visible: searchsongListView.model !== undefined
					onClicked: {
						deletePlaylist()
						addlastsearch()
						playPlaylistTrack(0)
					}
				}
			}

			section {
				delegate: Loader {
					active: sectionsInSearch && visible
					height: sectionsInSearch ? Theme.itemSizeMedium : 0
					width: parent.width
					sourceComponent: PlaylistSectionDelegate {
						width: undefined
					}
				}
				property: "section"
			}

			delegate: ListItem {
				menu: contextMenu
				contentHeight: Theme.itemSizeSmall
				Column {
					id: mainColumn
					clip: true
					height: trackRow + artistRow >= Theme.itemSizeSmall ? trackRow + artistRow : Theme.itemSizeSmall
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
							text: (index + 1) + ". "
							anchors.verticalCenter: parent.verticalCenter
						}
						Label {
							wrapMode: Text.WrapAnywhere
							elide: Text.ElideRight
							text: (title === "" ? filename : title)
							anchors.verticalCenter: parent.verticalCenter
						}
						Label {
							text: (length === 0 ? "" : " (" + lengthformated + ")")
							anchors.verticalCenter: parent.verticalCenter
						}
					}
					Label {
						id: artistRow
						text: (artist !== "" ? artist + " - " : "") + (album !== "" ? album : "")
						color: Theme.secondaryColor
						font.pixelSize: Theme.fontSizeSmall
					}
				}
				onClicked: {
					albumTrackClicked(title, album, artist, lengthformated, path, year, tracknr, trackmbid, artistmbid, albummbid)
				}
				function playTrackRemorse() {
					remorseAction(qsTr("playing track"), function () {
						playSong(path)
					}, 3000)
				}
				function addTrackRemorse() {
					remorseAction(qsTr("adding track"), function () {
						addSong(path)
					}, 3000)
				}

				function playAlbumRemorse() {
					remorseAction(qsTr("playing album"), function () {
						playAlbum(["", album])
					}, 3000)
				}
				function addAlbumRemorse() {
					remorseAction(qsTr("adding album"), function () {
						addAlbum(["", album])
					}, 3000)
				}
				function addTrackAfterCurrentRemorse() {
					remorseAction(qsTr("adding track"), function () {
						addSongAfterCurrent(path)
					}, 3000)
				}
				Component {
					id: contextMenu
					ContextMenu {
						property int lastHeight: 0
						MenuItem {
							text: qsTr("play track")
							onClicked: {
								playTrackRemorse()
							}
						}
						MenuItem {
							text: qsTr("add track to list")
							onClicked: {
								addTrackRemorse()
							}
						}
						MenuItem {
							text: qsTr("play after current")
							onClicked: {
								addTrackAfterCurrentRemorse()
							}
						}
						MenuItem {
							text: qsTr("add album to list")
							onClicked: {
								addAlbumRemorse()
							}
						}
						MenuItem {
							text: qsTr("play album")
							onClicked: {
								playAlbumRemorse()
							}
						}
						MenuItem {
							text: qsTr("add to saved list")
							onClicked: {
								requestSavedPlaylists()
								pageStack.push(Qt.resolvedUrl("AddToPlaylistDialog.qml"), {url: path})
							}
						}
					}
				}
			}
		}
	}

	function startSearch() {
		mainDrawer.hide()
		var searchfor
		switch (searchforcombobox.currentIndex) {
			case 0:
				searchfor = "title"
			break
			case 1:
				searchfor = "album"
			break
			case 2:
				searchfor = "artist"
			break
			case 3:
				searchfor = "file"
			break
		}

		requestSearch([searchfor, searchfield.text])
		searchsongListView.forceActiveFocus()
	}

	function newSearch() {
		searchfield.text = ""
		clearTrackList()
		mainDrawer.show()
	}

	Component.onDestruction: {
		clearTrackList()
	}
}
