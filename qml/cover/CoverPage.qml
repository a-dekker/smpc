import QtQuick 2.2
import Sailfish.Silica 1.0
import "../components"

CoverBackground {
    id: coverpage
    anchors.fill: parent

    function recheckActive() {
        if ((status === Cover.Activating || status === Cover.Active)) {
            coverimg.active = true
        } else {
            coverimg.active = false
        }
    }

    OpacityRampEffect {
        sourceItem: toggleImage
        direction: OpacityRamp.BottomToTop
        visible: (coverimg.sourceprimary != ""
                  || coverimg.sourcesecondary != "")
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
        visible: (coverimg.ready)
        anchors.fill: parent
        color: Theme.highlightBackgroundColor
        gradient: Gradient {
            GradientStop {
                position: 0.6
                color: Qt.rgba(0.0, 0.0, 0.0, 0.0)
            }
            GradientStop {
                position: 0.7
                //color: Qt.rgba(0.0, 0.0, 0.0, 0.3)
                color: Theme.rgba(Theme.highlightColor, 0.2)
            }
            GradientStop {
                position: 1.0
                color: Theme.rgba(Theme.highlightColor, 0.5)
                //color: Qt.rgba(0.0,0.0,0.0, 0.8)
            }
        }
    }
    HighlightImage {
        id: logo
        color: Theme.primaryColor
        visible: ((!coverimg.ready) && (ctl.player.playbackStatus.title == ""))
        source: "qrc:images/pictogram.png"
        anchors.centerIn: parent
    }

    onStatusChanged: {
        recheckActive()
    }

    Label {
        horizontalAlignment: implicitWidth > width ? Text.AlignLeft : Text.AlignHCenter
        anchors.top: parent.top
        anchors.topMargin: Theme.paddingMedium
        color: Theme.highlightColor
        text: ctl.player.playbackStatus.artist
        truncationMode: TruncationMode.Fade
        width: parent.width
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
        text: (ctl.player.playbackStatus.title == "" ? "SMPC" : ctl.player.playbackStatus.title)
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-previous-song"
            onTriggered: ctl.player.previous()
        }

        CoverAction {
            iconSource: playbuttoniconsourcecover //"image://theme/icon-cover-pause"
            onTriggered: ctl.player.play()
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-next-song"
            onTriggered: ctl.player.next()
        }
    }
}
