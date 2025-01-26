import QtQuick 2.2
import Sailfish.Silica 1.0

Dialog {
    id: songDialog
    property string title
    property string album
    property string artist
    property string lengthtext
    property string nr
    property string date
    property string genre
    property string filename
    property int fontsize: Theme.fontSizeMedium
    property int fontsizegrey: Theme.fontSizeSmall
    property string trackmbid
    property string albummbid
    property string artistmbid

    Component {
        id: pullDownComp
        PullDownMenu {
            MenuItem {
                text: qsTr("Add song")
                onClicked: {
                    accept()
                }
            }
            MenuItem {
                text: qsTr("Play after current")
                onClicked: {
                    ctl.player.playlist.addTrackAfterCurrent(filename)
                    pageStack.navigateBack(PageStackAction.Animated)
                }
            }
            MenuItem {
                text: qsTr("Play song")
                onClicked: {
                    ctl.player.playlist.playTrack(filename)
                    pageStack.navigateBack(PageStackAction.Animated)
                }
            }
        }
    }

    Loader {
        id: portraitLoader
        active: false
        anchors.fill: parent
        sourceComponent: Component {
            Item {
                anchors.fill: parent
                SilicaFlickable {
                    id: songFlickable
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        bottom: buttonRow.top
                    }

                    contentHeight: flickColumn.height
                    clip: true
                    Column {
                        id: flickColumn
                        width: parent.width
                        DialogHeader {
                            id: header
                            anchors {
                                left: parent.left
                                right: parent.right
                            }

                            acceptText: qsTr("Add song")
                        }

                        Item {
                            id: imageFakeItm
                            width: parent.width
                            height: imageRow.height
                            Row {
                                id: imageRow
                                width: parent.width
                                height: width / 2
                                Image {
                                    id: artistImage
                                    width: parent.width / 2
                                    height: imageRow.height
                                    cache: true
                                    asynchronous: true
                                    sourceSize.width: width
                                    sourceSize.height: height
                                    source: "image://imagedbprovider/artist/" + artist
                                    fillMode: Image.PreserveAspectCrop
                                    onStatusChanged: {
                                        if (status == Image.Error
                                                && albumImage.status == Image.Error) {
                                            // Disable image and set imageRow height to 0
                                            imageRow.height = 0
                                        }
                                    }
                                }
                                Image {
                                    id: albumImage
                                    width: parent.width / 2
                                    height: imageRow.height
                                    cache: true
                                    asynchronous: true
                                    sourceSize.width: width
                                    sourceSize.height: height
                                    source: "image://imagedbprovider/album/" + artist + "/" + album
                                    fillMode: Image.PreserveAspectCrop
                                    onStatusChanged: {
                                        if (status == Image.Error
                                                && artistImage.status == Image.Error) {
                                            // Disable image and set imageRow height to 0
                                            imageRow.height = 0
                                        }
                                    }
                                }
                            }

                            OpacityRampEffect {
                                sourceItem: imageRow
                                direction: OpacityRamp.TopToBottom
                            }
                        }

                        Column {
                            id: infocolumn
                            width: parent.width
                            clip: true
                            anchors {
                                right: parent.right
                                left: parent.left
                                leftMargin: listPadding
                                rightMargin: listPadding
                            }

                            ScrollLabel {
                                id: titleText
                                text: title
                                color: Theme.primaryColor
                                font.pixelSize: fontsize
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                }
                            }
                            ScrollLabel {
                                id: albumText
                                text: album
                                color: Theme.primaryColor
                                font.pixelSize: fontsize
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                }
                            }
                            ScrollLabel {
                                id: artistText
                                text: artist
                                color: Theme.primaryColor
                                font.pixelSize: fontsize
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                }
                            }
                            Row {
                                Label {
                                    text: qsTr("Length: ")
                                    color: Theme.secondaryColor
                                    font.pixelSize: fontsize
                                }
                                Label {
                                    id: lengthText
                                    text: lengthtext
                                    color: Theme.primaryColor
                                    font.pixelSize: fontsize
                                    wrapMode: "WordWrap"
                                }
                            }
                            Row {
                                Label {
                                    text: qsTr("Date: ")
                                    color: Theme.secondaryColor
                                    font.pixelSize: fontsize
                                }
                                Label {
                                    id: dateText
                                    text: date
                                    color: Theme.primaryColor
                                    font.pixelSize: fontsize
                                    wrapMode: "WordWrap"
                                }
                            }
                            Row {
                                Label {
                                    text: qsTr("Nr: ")
                                    color: Theme.secondaryColor
                                    font.pixelSize: fontsize
                                }
                                Label {
                                    id: nrText
                                    text: nr
                                    color: Theme.primaryColor
                                    font.pixelSize: fontsize
                                    wrapMode: "WordWrap"
                                }
                            }
                            Row {
                                visible: genre !== ""
                                width: parent.width
                                Label {
                                    id: genreLabel
                                    text: qsTr("Genre: ")
                                    color: Theme.secondaryColor
                                    font.pixelSize: fontsize
                                }
                                Label {
                                    id: genreText
                                    text: genre
                                    color: Theme.primaryColor
                                    font.pixelSize: fontsize
                                    width: parent.width - genreLabel.width
                                    wrapMode: "WordWrap"
                                }
                            }
                            Label {
                                visible: trackmbid !== ""
                                text: qsTr("Musicbrainz track id: ")
                                color: Theme.secondaryColor
                                font.pixelSize: fontsize
                            }
                            Label {
                                visible: trackmbid !== ""
                                id: trackmbidText
                                text: trackmbid
                                color: Theme.primaryColor
                                font.pixelSize: fontsize
                                wrapMode: "WordWrap"
                            }
                            Label {
                                visible: albummbid !== ""
                                text: qsTr("Musicbrainz album id: ")
                                color: Theme.secondaryColor
                                font.pixelSize: fontsize
                            }
                            Label {
                                visible: albummbid !== ""
                                id: albummbidText
                                text: albummbid
                                color: Theme.primaryColor
                                font.pixelSize: fontsize
                                wrapMode: "WrapAnywhere"
                            }
                            Label {
                                visible: artistmbid !== ""
                                text: qsTr("Musicbrainz artist id: ")
                                color: Theme.secondaryColor
                                font.pixelSize: fontsize
                            }
                            Label {
                                visible: artistmbid !== ""
                                text: artistmbid
                                color: Theme.primaryColor
                                font.pixelSize: fontsize
                                wrapMode: "WordWrap"
                            }
                            Label {
                                text: qsTr("URI:")
                                color: Theme.secondaryColor
                                font.pixelSize: fontsizegrey
                            }
                            Label {
                                id: fileText
                                text: filename
                                color: Theme.primaryColor
                                font.pixelSize: fontsize
                                wrapMode: "WrapAnywhere"
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                }
                            }
                        }

                        Component.onCompleted: pullDownComp.createObject(this)
                    }
                }
                Row {
                    id: buttonRow
                    height: addButton.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors {
                        bottom: parent.bottom
                    }
                    IconButton {
                        id: playButton
                        icon.source: "image://theme/icon-m-play"
                        onClicked: {
                            ctl.player.playlist.playTrack(filename)
                            pageStack.pop()
                        }
                    }
                    IconButton {
                        id: addButton
                        icon.source: "image://theme/icon-m-add"
                        onClicked: {
                            accept()
                        }
                    }
                }
            }
        }
    }

    Loader {
        id: landscapeLoader
        active: false
        anchors.fill: parent
        sourceComponent: Component {
            Item {
                anchors.fill: parent
                Column {
                    id: imageColumn
                    anchors {
                        top: parent.top
                        left: parent.left
                        bottom: parent.bottom
                    }
                    height: parent.height
                    Image {
                        id: artistImage
                        width: height
                        height: parent.height / 2
                        cache: true
                        asynchronous: true
                        source: "image://imagedbprovider/artist/" + artist
                        fillMode: Image.PreserveAspectCrop
                        onStatusChanged: {
                            if (status == Image.Error
                                    && albumImage.status == Image.Error) {
                                // Disable image and set imageRow height to 0
                                imageColumn.width = 0
                            }
                        }
                    }
                    Image {
                        id: albumImage
                        width: height
                        height: parent.height / 2
                        cache: true
                        asynchronous: true
                        source: "image://imagedbprovider/album/" + artist + "/" + album
                        fillMode: Image.PreserveAspectCrop
                        onStatusChanged: {
                            if (status == Image.Error
                                    && artistImage.status == Image.Error) {
                                // Disable image and set imageRow height to 0
                                imageRow.width = 0
                            }
                        }
                    }
                }
                OpacityRampEffect {
                    sourceItem: imageColumn
                    direction: OpacityRamp.LeftToRight
                }
                SilicaFlickable {
                    id: songFlickable
                    anchors {
                        top: parent.top
                        left: imageColumn.right
                        right: parent.right
                        bottom: buttonRowRoot.top
                    }
                    contentHeight: infocolumn.height
                    clip: true
                    Column {
                        clip: true
                        anchors {
                            right: parent.right
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: listPadding
                            rightMargin: listPadding
                        }
                        id: infocolumn
                        DialogHeader {
                            id: header
                            acceptText: qsTr("Add song")
                        }

                        ScrollLabel {
                            id: titleText
                            text: title
                            color: Theme.primaryColor
                            font.pixelSize: fontsize
                            anchors {
                                left: parent.left
                                right: parent.right
                            }
                        }
                        ScrollLabel {
                            id: albumText
                            text: album
                            color: Theme.primaryColor
                            font.pixelSize: fontsize
                            anchors {
                                left: parent.left
                                right: parent.right
                            }
                        }
                        ScrollLabel {
                            id: artistText
                            text: artist
                            color: Theme.primaryColor
                            font.pixelSize: fontsize
                            anchors {
                                left: parent.left
                                right: parent.right
                            }
                        }
                        Row {
                            Label {
                                text: qsTr("Length:")
                                color: Theme.secondaryColor
                                font.pixelSize: fontsize
                                width: infocolumn.width / 6
                            }
                            Label {
                                id: lengthText
                                text: lengthtext
                                color: Theme.primaryColor
                                font.pixelSize: fontsize
                                wrapMode: "WordWrap"
                                width: infocolumn.width / 3
                            }
                            Label {
                                text: qsTr("Date: ")
                                color: Theme.secondaryColor
                                font.pixelSize: fontsize
                                width: infocolumn.width / 7
                            }
                            Label {
                                id: dateText
                                text: date
                                color: Theme.primaryColor
                                font.pixelSize: fontsize
                                wrapMode: "WordWrap"
                                width: infocolumn.width / 3
                            }
                        }
                        Row {
                            Label {
                                text: qsTr("Nr: ")
                                color: Theme.secondaryColor
                                font.pixelSize: fontsize
                                width: infocolumn.width / 6
                            }
                            Label {
                                id: nrText
                                text: nr
                                color: Theme.primaryColor
                                font.pixelSize: fontsize
                                wrapMode: "WordWrap"
                                width: infocolumn.width / 3
                            }
                            Label {
                                visible: genre !== ""
                                text: qsTr("Genre: ")
                                color: Theme.secondaryColor
                                font.pixelSize: fontsize
                                width: infocolumn.width / 7
                            }
                            Label {
                                id: genreText
                                visible: genre !== ""
                                text: genre
                                color: Theme.primaryColor
                                font.pixelSize: fontsize
                                wrapMode: "WordWrap"
                                width: infocolumn.width / 3
                            }
                        }
                        Row {
                            visible: trackmbid !== ""
                            Label {
                                text: qsTr("Musicbrainz track id: ")
                                color: Theme.secondaryColor
                                font.pixelSize: fontsize
                            }
                            Label {
                                id: trackmbidText
                                text: trackmbid
                                color: Theme.primaryColor
                                font.pixelSize: fontsize
                                wrapMode: "WordWrap"
                            }
                        }
                        Row {
                            visible: albummbid !== ""
                            Label {
                                text: qsTr("Musicbrainz album id: ")
                                color: Theme.secondaryColor
                                font.pixelSize: fontsize
                            }
                            Label {
                                id: albummbidText
                                text: albummbid
                                color: Theme.primaryColor
                                font.pixelSize: fontsize
                                wrapMode: "WordWrap"
                            }
                        }
                        Row {
                            visible: artistmbid !== ""
                            Label {
                                text: qsTr("Musicbrainz artist id: ")
                                color: Theme.secondaryColor
                                font.pixelSize: fontsize
                            }
                            Label {
                                text: artistmbid
                                color: Theme.primaryColor
                                font.pixelSize: fontsize
                                wrapMode: "WordWrap"
                            }
                        }
                        Row {
                            anchors {
                                left: parent.left
                                right: parent.right
                            }
                            Label {
                                id: uriTxt
                                text: qsTr("URI: ")
                                color: Theme.secondaryColor
                                font.pixelSize: fontsize
                            }
                            Label {
                                id: fileText
                                text: filename
                                width: parent.width - uriTxt.width
                                color: Theme.primaryColor
                                font.pixelSize: fontsize
                                wrapMode: "WrapAnywhere"
                            }
                        }
                    }
                    Component.onCompleted: pullDownComp.createObject(this)
                }
                Item {
                    id: buttonRowRoot
                    anchors {
                        left: imageColumn.right
                        bottom: parent.bottom
                        right: parent.right
                    }
                    height: buttonRow.height
                    Row {
                        id: buttonRow
                        anchors.horizontalCenter: parent.horizontalCenter
                        IconButton {
                            id: playButton
                            icon.source: "image://theme/icon-m-play"
                            onClicked: {
                                ctl.player.playlist.playTrack(filename)
                                pageStack.pop()
                            }
                        }
                        IconButton {
                            id: addButton
                            icon.source: "image://theme/icon-m-add"
                            onClicked: {
                                accept()
                            }
                        }
                    }
                }
            }
        }
    }

    onAccepted: {
        ctl.player.playlist.addTrack(filename)
    }
    onOrientationTransitionRunningChanged: {
        if (!orientationTransitionRunning) {
            // Activate correct loader
            if ((orientation === Orientation.Portrait)
                    || (orientation === Orientation.PortraitInverted)) {

                portraitLoader.active = true
            } else if ((orientation === Orientation.Landscape)
                       || (orientation === Orientation.LandscapeInverted)) {
                landscapeLoader.active = true
            }
        } else {
            // Deactivate both loaders
            portraitLoader.active = false
            landscapeLoader.active = false
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            if (!orientationTransitionRunning) {
                // Activate correct loader
                if ((orientation === Orientation.Portrait)
                        || (orientation === Orientation.PortraitInverted)) {
                    if (landscapeLoader.active) {
                        landscapeLoader.active = false
                    }
                    portraitLoader.active = true
                } else if ((orientation === Orientation.Landscape)
                           || (orientation === Orientation.LandscapeInverted)) {
                    if (portraitLoader.active) {
                        portraitLoader.active = false
                    }
                    landscapeLoader.active = true
                }
            } else {
                // Deactivate both loaders
                portraitLoader.active = false
                landscapeLoader.active = false
            }
        }
    }
}
