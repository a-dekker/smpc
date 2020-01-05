import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
	id: artistInfoPage
	allowedOrientations: Orientation.All
	property string artistname

	PageHeader {
		id: header
		title: artistname
		clip: true
	}

	SilicaFlickable {
		id: textFlickable
		anchors {
			top: header.bottom
			bottom: parent.bottom
			right: parent.right
			left: parent.left
			//bottomMargin: quickControlPanel.visibleSize
		}
		contentHeight: artistText.implicitHeight
		clip: true

		ScrollDecorator {}

		Label {
			id: artistText
			width: parent.width
			height: implicitHeight
			text: artistInfoText
			wrapMode: "WordWrap"
		}
	}
}
