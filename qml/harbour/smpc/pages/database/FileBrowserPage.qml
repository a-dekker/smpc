import QtQuick 2.2
import Sailfish.Silica 1.0
import harbour.smpc.components 1.0

Page {
	id: filePage
	allowedOrientations: Orientation.All
	property string filepath
	property var listmodel
	property int lastContentPosY: 0

	SilicaListView {
			id: fileListView
			model: listmodel
			quickScrollEnabled: jollaQuickscroll
			highlightFollowsCurrentItem: true
			SpeedScroller {
				id: scroller
				listview: fileListView
				scrollenabled: fastscrollenabled
			}
			clip: true
			ScrollDecorator {}

			anchors.fill: parent
			contentWidth: width
			header: PageHeader {
				title: qsTr("filebrowser")
			}
			PullDownMenu {
				MenuItem {
					text: qsTr("home")
					onClicked: {
						pageStack.clear()
						pageStack.push(initialPage)
					}
				}
				MenuItem {
					text: qsTr("add folder")
					onClicked: {
						addFiles(filepath)
					}
				}
				MenuItem {
					text: qsTr("play folder")
					onClicked: {
						playFiles(filepath)
					}
				}
			}
			delegate: FileDelegate {}
	}

	onStatusChanged: {
		// Restore scroll position
		if (status === PageStatus.Activating && lastContentPosY) {
			fileListView.cancelFlick()
			fileListView.positionViewAtIndex(lastContentPosY, ListView.Center)
		}
	}

	Component.onDestruction: {
		fastscrollenabled = false
		popfilemodelstack()
	}
}
