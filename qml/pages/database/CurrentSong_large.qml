import QtQuick 2.2
import Sailfish.Silica 1.0
import "../../components"

Page {
    id: currentSongLargePage

    Item {
        id: landscapeImageRow
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: width / 2
        clip: true
        Image {
            id: albumImgLandscape
            source: coverimageurl
            width: (parent.width / 2)
            height: width
            anchors {
                top: parent.top
                left: parent.left
            }
            cache: false
            fillMode: Image.PreserveAspectCrop
            Rectangle {
                color: Theme.rgba(Theme.highlightBackgroundColor,
                                  Theme.highlightBackgroundOpacity)
                anchors.fill: parent
                visible: albumImgLandscape.status != Image.Ready
                Image {
                    anchors.fill: parent
                    source: "qrc:images/pictogram.svg"
                    sourceSize.width: Screen.width / 2
                    sourceSize.height: Screen.width / 2
                }
            }
        }
        Image {
            id: artistImgLandscape
            source: artistimageurl
            width: (parent.width / 2)
            height: width
            anchors {
                top: parent.top
                left: albumImgLandscape.right
                leftMargin: Theme.paddingSmall
            }
            cache: false
            fillMode: Image.PreserveAspectCrop
            Rectangle {
                color: Theme.rgba(Theme.highlightBackgroundColor,
                                  Theme.highlightBackgroundOpacity)
                anchors.fill: parent
                visible: artistImgLandscape.status != Image.Ready
                Image {
                    anchors.fill: parent
                    source: "qrc:images/pictogram.svg"
                    sourceSize.width: Screen.width / 2
                    sourceSize.height: Screen.width / 2
                }
            }
        }
    }
    Column {
        id: landscapeTextScrollColumn
        anchors {
            bottom: currentSongLargePage.bottom
        }
        width: currentSongLargePage.width

        ScrollLabel {
            id: titleTextLC
            text: ctl.player.playbackStatus.title
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeMedium
            width: parent.width
            anchors {
                left: parent.left
                right: parent.right
            }
        }
        ScrollLabel {
            id: albumTextLC
            text: mAlbum
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeMedium
            width: parent.width
            anchors {
                left: parent.left
                right: parent.right
            }
        }
        ScrollLabel {
            id: artistTextLC
            text: mArtist
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeMedium
            width: parent.width
            anchors {
                left: parent.left
                right: parent.right
            }
        }
    }
    onStatusChanged: {
        if (status === PageStatus.Activating || status === PageStatus.Active) {
            quickControlPanel.hideControl = true
        } else if (status === PageStatus.Deactivating) {
            quickControlPanel.hideControl = false
        }
    }
}
