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
        width: albumImg.visible ? parent.width - albumImg.width : parent.width
        height: Theme.paddingSmall
        visible: ctl.player.playbackStatus.title !== "" && mArtist !== ""
        x: albumImg.visible ? albumImg.width : 0

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

    Image {
        id: albumImg
        source: coverimageurl
        height: parent.height
        width: height
        anchors.left: parent.left
        anchors.top: parent.top
        cache: false
        fillMode: Image.PreserveAspectCrop
        visible: !pushUp.active && showPlayButtonOnDockedPanel
        onStatusChanged: {
            if (albumImg.status == 3) {
                // we do not have coverart
                coverimageurl = "image://theme/icon-m-music"
            }
        }
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
            right: playButton.visible ? playButton.left : parent.right
            left: albumImg.visible ? albumImg.right : parent.left
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
            onTextChanged: {
                if (albumImg.status == 3) {
                    // we do not have coverart
                    coverimageurl = "image://theme/icon-m-music"
                }
            }
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
    IconButton {
        id: playButton
        icon.source: ctl.player.playbackStatus.playbackStatus
                     === 1 ? "image://theme/icon-m-pause" : "image://theme/icon-m-play"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        onClicked: ctl.player.play()
        visible: !pushUp.active && showPlayButtonOnDockedPanel
    }

    PushUpMenu {
        id: pushUp

        PlaybackControls {}

        PositionSlider {
            id: positionSlider
            visible: showPositionSlider
            width: parent.width
            onPressedChanged: {
                mPositionSliderActive = pressed
            }
        }

        VolumeSlider {
            id: volumeSlider
            visible: showVolumeSlider
            width: parent.width
        }
    }
}
