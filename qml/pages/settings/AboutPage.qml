import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../components"

Page {
	id: aboutPage
	allowedOrientations: Orientation.All
	onStatusChanged: {
		if (status === PageStatus.Activating || status === PageStatus.Active) {
			quickControlPanel.hideControl = true
		} else {
			quickControlPanel.hideControl = false
		}
		//quickControlPanel.hideControl = status === PageStatus.Activating || status === PageStatus.Active
	}

	SilicaFlickable {
		id: aboutFlickable
		anchors.fill: parent
		contentHeight: contentColumn.height

		Column {
			width: parent.width
			id: contentColumn

			PageHeader {
				id: pageHeading
				title: qsTr("about")
			}

			Image {
				id: logo
				source: "qrc:images/smpc.svg"
				sourceSize.height: parent.width
				sourceSize.width: parent.width
				smooth: true
				anchors.horizontalCenter: parent.horizontalCenter
				width: (orientation === Orientation.Portrait
					? aboutPage.width - Theme.paddingLarge * 5
					: aboutPage.height - pageHeading.height - nameText.height - versionText.height
				)
				height: width
				cache: false

				BackgroundItem {
					id: debugEnabled
					property int clickcount: 0
					onClicked: {
						if (clickcount++ >= 5) {
							mDebugEnabled = true
						}
					}
					anchors.fill: parent
				}
			}

			Label {
				id: nameText
				anchors.horizontalCenter: parent.horizontalCenter
				text: "SMPC"
				font.pixelSize: Theme.fontSizeExtraLarge
			}
			Label {
				id: versionText
				anchors.horizontalCenter: parent.horizontalCenter
				text: qsTr("Version:") + " " + versionstring
				font.pixelSize: Theme.fontSizeLarge
			}
			Button {
				anchors.horizontalCenter: parent.horizontalCenter
				text: "source code"
				onClicked: {
					Qt.openUrlExternally('https://github.com/djselbeck/smpc')
				}
			}
			Separator {
				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width - Theme.paddingLarge
				color: Theme.primaryColor
			}
			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				Label {
					id: copyLeft
					text: "©"
					transform: Rotation {
						id: mirror
						origin.x: copyLeft.width / 2
						axis.x: 0
						axis.y: 1
						axis.z: 0
						angle: 180
					}
				}

				Label {
					text: " 2013-2015 by Hendrik Borghorst"
					font.pixelSize: Theme.fontSizeMedium
				}
			}
			Button {
				anchors.horizontalCenter: parent.horizontalCenter
				text: "@djselbeck"
				onClicked: {
					Qt.openUrlExternally('https://twitter.com/djselbeck')
				}
			}

			Label {
				anchors.horizontalCenter: parent.horizontalCenter
				text: qsTr("Licensed under GPLv3")
				font.pixelSize: Theme.fontSizeMedium
			}
			Separator {
				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width - Theme.paddingLarge
				color: Theme.primaryColor
			}
			Label {
				visible: lastfmEnabled
				anchors.horizontalCenter: parent.horizontalCenter
				text: qsTr("Fetches metadata from last.fm")
				font.pixelSize: Theme.fontSizeTiny
				MouseArea {
					anchors.fill: parent
					onClicked: {
						Qt.openUrlExternally('https://www.last.fm')
					}
				}
			}
		}
	}
}
