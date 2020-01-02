import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../components"

Page {
	id: outputsPage
	allowedOrientations: Orientation.All
	property string artistname

	SilicaListView {
		id: outputsListView
		anchors.fill: parent
		//anchors.bottomMargin: quickControlPanel.visibleSize
		contentWidth: width
		header: PageHeader {
			title: qsTr("outputs")
		}
		clip: true
		model: outputsModel

		ScrollDecorator {}
		delegate: ListItem {
			contentHeight: mainColumn.height

			Column {
				id: mainColumn
				clip: true
				anchors {
					right: parent.right
					left: parent.left
					verticalCenter: parent.verticalCenter
					leftMargin: listPadding
					rightMargin: listPadding
				}

				TextSwitch {
					checked: outputenabled
					text: outputname
					onClicked: {
						if (outputenabled) {
							disableOutput(id)
							outputenabled = false
						} else {
							enableOutput(id)
							outputenabled = true
						}
					}
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
