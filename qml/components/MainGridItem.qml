import QtQuick 2.2
import Sailfish.Silica 1.0

Rectangle {
	anchors.fill: parent
	property string text: textofgrid.text
	Text {
		id: textofgrid
		text: ""
	}
}
