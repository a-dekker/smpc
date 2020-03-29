import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
	id: albumInfoPage
	allowedOrientations: Orientation.All
	property string albumname

	PageHeader {
		id: header
		title: albumname
		clip: true
	}

	SilicaFlickable {
		id: textFlickable
		anchors {
			top: header.bottom
			bottom: parent.bottom
			right: parent.right
			left: parent.left
		}
		contentHeight: albumText.implicitHeight
		clip: true

		ScrollDecorator {}

		Label {
			id: albumText
			x: Theme.paddingMedium
			y: Theme.paddingMedium
			width: parent.width - 2 * Theme.paddingMedium
			height: implicitHeight
			text: albumInfoText + "\n"
			wrapMode: "WordWrap"
		}
	}
}
