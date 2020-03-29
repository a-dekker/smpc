import QtQuick 2.2
import Sailfish.Silica 1.0

Dialog {
	allowedOrientations: Orientation.All

	Column {
		width: parent.width
		spacing: Theme.paddingMedium
		anchors.margins: Theme.paddingMedium
		DialogHeader {
			acceptText: qsTr("Add url")
		}
		Label {
			text: qsTr("Enter url:")
		}
		TextField {
			id: urlInputField
			width: parent.width
			placeholderText: qsTr("Input url (http://, file://, etc)")
		}
	}
	onDone: {
		if (result === DialogResult.Accepted) {
			addSong(urlInputField.text)
		}
		urlInputField.text = ""
		urlInputField.focus = false
	}
	onOpened: {
		urlInputField.focus = true
	}
}
