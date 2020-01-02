import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
	id: saveToList
	property string url
	allowedOrientations: Orientation.All
	canAccept: false
	Component.onDestruction: {
		clearPlaylists()
	}

	SilicaListView {
		id: savedListView
		model: savedPlaylistsModel
		anchors.fill: parent
		header: DialogHeader {
			acceptText: qsTr("select playlist")
			title: qsTr("select playlist")
		}
		delegate: ListItem {
			onClicked: {
				addSongToSaved([url, modelData])
				pageStack.pop()
			}

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
		}
	}
}
