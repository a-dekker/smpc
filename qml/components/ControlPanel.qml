import QtQuick 2.2
import Sailfish.Silica 1.0

DockedPanel {
    id: controlPanel

    open: !hideControl && !Qt.inputMethod.visible
    width: parent.width
    height: textColumn.height + Theme.paddingMedium
    contentHeight: height

    property bool hideControl: false

    flickableDirection: Flickable.VerticalFlick

    Item {
        id: progressBarItem
        width: parent.width
        height: Theme.paddingSmall
        visible: ctl.player.playbackStatus.title !== "" && mArtist !== ""

        Rectangle {
            id: progressBar
            height: parent.height
            width: parent.width * (mPosition / mLength)
            color: Theme.highlightColor
            opacity: 0.5
        }

        Rectangle {
            anchors {
                left: progressBar.right
                right: parent.right
            }
            height: parent.height
            color: "black"
            opacity: Theme.highlightBackgroundOpacity
        }
    }

    Image {
        width: parent.width
        fillMode: Image.PreserveAspectFit
        source: "image://theme/graphic-gradient-edge"
    }

    Label {
        id: notPlayingLabel
        visible: ctl.player.playbackStatus.title == "" && mArtist == ""
        text: qsTr("Not playing")
        anchors.centerIn: parent
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeLarge
        font.bold: false
        font.family: Theme.fontFamily
    }

    Column {
        id: textColumn
        anchors {
            top: parent.top
            right: parent.right
            left: parent.left
        }

        ScrollLabel {
            id: titleText
            text: ctl.player.playbackStatus.title
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeSmall
            font.bold: false
            font.family: Theme.fontFamily
            anchors {
                left: parent.left
                right: parent.right
            }
            active: controlPanel.open && Qt.application.active
        }

        ScrollLabel {
            id: artistText
            text: mArtist
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeSmall
            font.bold: false
            font.family: Theme.fontFamily
            anchors {
                left: parent.left
                right: parent.right
            }
            active: controlPanel.open && Qt.application.active
        }
    }

    PushUpMenu {
        id: pushUp

        PlaybackControls {}

        VolumeSlider {
            id: volumeSlider
            width: parent.width
        }
    }
}
