import QtQuick 2.2
import Sailfish.Silica 1.0
import "../components"

CoverBackground {
	id: coverpage
	anchors.fill: parent

	function recheckActive() {
		if (status === Cover.Activating || status === Cover.Active) {
			coverimg.active = true
		} else {
			coverimg.active = false
		}
	}

	OpacityRampEffect {
		sourceItem: toggleImage
		direction: OpacityRamp.BottomToTop
		visible: coverimg.sourceprimary != "" || coverimg.sourcesecondary != ""
	}

	Item {
		id: toggleImage
		anchors.fill: parent

		ToggleImage {
			id: coverimg
			anchors.fill: parent
			sourceprimary: coverimageurl
			sourcesecondary: artistimageurl
			fillMode: Image.PreserveAspectCrop
		}
	}

	Rectangle {
		visible: coverimg.ready
		anchors.fill: parent
		color: Theme.highlightBackgroundColor
		gradient: Gradient {
			GradientStop {
				position: 0.6
				color: Qt.rgba(0.0, 0.0, 0.0, 0.0)
			}
			GradientStop {
				position: 0.7
				color: Theme.rgba(Theme.highlightColor, 0.2)
			}
			GradientStop {
				position: 1.0
				color: Theme.rgba(Theme.highlightColor, 0.5)
			}
		}
	}

	Icon {
		id: logo
		visible: !coverimg.ready && mTitle == ""
		source: "qrc:images/pictogram.svg"
		sourceSize.width: Theme.iconSizeExtraLarge
		sourceSize.height: Theme.iconSizeExtraLarge
		anchors.centerIn: parent
		color: Theme.primaryColor
	}

	onStatusChanged: {
		recheckActive()
	}

	Label {
		id: textLabel
		anchors.centerIn: coverpage
		width: coverpage.width - (2 * listPadding)
		height: (coverpage.height / 3) * 2
		wrapMode: "WordWrap"
		elide: Text.ElideRight
		font.pixelSize: Theme.fontSizeLarge
		style: Text.Raised
		styleColor: Theme.secondaryColor
		horizontalAlignment: Text.AlignHCenter
		text: mTitle == "" ? "SMPC" : mTitle
	}

	CoverActionList {
		id: coverAction

		CoverAction {
			iconSource: playbuttoniconsourcecover
			onTriggered: play()
		}

		CoverAction {
			iconSource: "image://theme/icon-cover-next-song"
			onTriggered: next()
		}
	}
}
