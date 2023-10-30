import QtQuick 2.2

import Sailfish.Silica 1.0
import "../../components"

Page {
    id: albumTracksPage
    property string albumname
    property string artistname
    property int lastIndex: 0

    Component {
        id: pullDownComp
        PullDownMenu {
            MenuItem {
                enabled: (artistname !== "")
                visible: enabled
                text: qsTr("Show all tracks")
                onClicked: {
                    albumClicked("", albumname)
                    artistname = ""
                }
            }
            MenuItem {
                text: qsTr("Show artist")
                onClicked: {
                    artistClicked(artistname)
                    pageStack.pop()
                    pageStack.pop()
                    pageStack.replace(Qt.resolvedUrl("AlbumListPage.qml"), {
                                          "artistname": artistname
                                      })
                }
            }

            MenuItem {
                text: qsTr("Replace album")
                visible: ctl.player.playbackStatus.title === ""
                         && mArtist === ""
                onClicked: {
                    ctl.player.playlist.clear()
                    ctl.player.playlist.addAlbum(artistname, albumname)
                }
            }
            MenuItem {
                text: qsTr("Add album")
                onClicked: {
                    ctl.player.playlist.addAlbum(artistname, albumname)
                }
            }
            MenuItem {
                text: qsTr("Play album")
                onClicked: {
                    ctl.player.playlist.playAlbum(artistname, albumname)
                }
            }
        }
    }

    Loader {
        id: portraitLoader
        active: false
        anchors.fill: parent
        sourceComponent: Component {

            SilicaListView {
                id: albumTracksListView
                quickScroll: jollaQuickscroll
                contentWidth: width
                model: tracksModel
                clip: true
                populate: Transition {
                    NumberAnimation {
                        properties: "x"
                        from: albumTracksListView.width * 2
                        duration: populateDuration
                    }
                }
                header: Item {
                    height: headerColumn.height
                    width: albumTracksListView.width
                    Column {
                        id: headerColumn
                        height: header.height + imageRow.height
                        width: parent.width
                        PageHeader {
                            id: header
                            title: albumname
                        }
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
                                source: artistname == "" ? "image://imagedbprovider/artistfromalbum/" + albumname : "image://imagedbprovider/artist/" + artistname
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
                                source: artistname
                                        == "" ? "image://imagedbprovider/album/"
                                                + albumname : "image://imagedbprovider/album/"
                                                + artistname + "/" + albumname
                                fillMode: Image.PreserveAspectCrop
                                onStatusChanged: {
                                    if (status == Image.Error
                                            && artistImage.status == Image.Error) {
                                        // Disable image and set imageRow height to 0
                                        imageRow.height = 0
                                    }
                                }

                                MouseArea {
                                    anchors.fill: albumImage
                                    onClicked: {
                                        ctl.player.playlist.playAlbum(
                                                    artistname, albumname)
                                    }
                                }
                            }
                        }
                    }
                    OpacityRampEffect {
                        sourceItem: headerColumn
                        direction: OpacityRamp.TopToBottom
                    }
                }
                delegate: trackDelegate
                Component.onCompleted: pullDownComp.createObject(this)
            }
        }
    }

    Loader {
        id: landscapeLoader
        anchors {
            fill: parent
        }
        active: false
        sourceComponent: Component {
            Item {
                id: landscapeItem
                anchors.fill: parent
                Column {
                    id: pictureColumn
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                    }

                    width: parent.height / 2
                    Image {
                        id: artistImageLC
                        width: height
                        height: pictureColumn.width
                        cache: true
                        asynchronous: true
                        source: artistname
                                == "" ? "image://imagedbprovider/artistfromalbum/"
                                        + albumname : "image://imagedbprovider/artist/" + artistname
                        fillMode: Image.PreserveAspectCrop
                        onStatusChanged: {
                            if (status == Image.Error
                                    && albumImageLC.status == Image.Error) {
                                // Disable image and set imageRow height to 0
                                pictureColumn.width = 0
                            }
                        }
                    }
                    Image {
                        id: albumImageLC
                        width: height
                        height: pictureColumn.width
                        cache: true
                        asynchronous: true
                        source: artistname == "" ? "image://imagedbprovider/album/"
                                                   + albumname : "image://imagedbprovider/album/"
                                                   + artistname + "/" + albumname
                        fillMode: Image.PreserveAspectCrop
                        onStatusChanged: {
                            if (status == Image.Error
                                    && artistImageLC.status == Image.Error) {
                                // Disable image and set imageRow height to 0
                                pictureColumn.width = 0
                            }
                        }

                        MouseArea {
                            anchors.fill: albumImageLC
                            onClicked: {
                                ctl.player.playlist.playAlbum(artistname,
                                                              albumname)
                            }
                        }
                    }
                }
                SilicaListView {
                    id: listViewLC
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.right
                        left: pictureColumn.right
                    }
                    header: PageHeader {
                        title: albumname
                    }
                    quickScroll: jollaQuickscroll

                    model: tracksModel
                    clip: true
                    populate: Transition {
                        NumberAnimation {
                            properties: "x"
                            from: listViewLC.width * 2
                            duration: populateDuration
                        }
                    }
                    delegate: trackDelegate
                    Component.onCompleted: pullDownComp.createObject(this)
                }
                OpacityRampEffect {
                    sourceItem: pictureColumn
                    direction: OpacityRamp.LeftToRight
                }
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Deactivating) {

        } else if (status === PageStatus.Activating) {
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
        } else if (status === PageStatus.Active) {

            requestAlbumInfo([albumname, artistname])
            pageStack.pushAttached(Qt.resolvedUrl("AlbumInfoPage.qml"), {
                                       "albumname": albumname
                                   })
        }
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

    Component.onDestruction: {
        clearTrackList()
    }

    Component {
        id: trackDelegate
        ListItem {
            menu: contextMenu
            contentHeight: Theme.itemSizeSmall
            Column {
                id: mainColumn
                clip: true
                height: (titleRow.height + artistLabel.height
                         >= Theme.itemSizeSmall ? titleRow.height
                                                  + artistLabel.height : Theme.itemSizeSmall)
                anchors {
                    right: parent.right
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: listPadding
                    rightMargin: listPadding
                }

                Row {
                    id: titleRow
                    Label {
                        text: tracknr + ". "
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    Label {
                        clip: true
                        wrapMode: Text.WrapAnywhere
                        elide: Text.ElideRight
                        text: (title === "" ? filename : title)
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    Label {
                        text: (length === 0 ? "" : " (" + lengthformated + ")")
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Label {
                    id: artistLabel
                    text: (artist !== "" ? artist + " - " : "") + (album !== "" ? album : "")
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            OpacityRampEffect {
                sourceItem: mainColumn
                slope: 3.5
                offset: 0.75
            }
            onClicked: {
                //albumTracksListView.currentIndex = index
                albumTrackClicked(title, album, artist, lengthformated, path,
                                  year, tracknr, trackmbid, artistmbid,
                                  albummbid, genre)
            }
            function playTrackRemorse() {
                remorseAction(qsTr("Playing track"), function () {
                    ctl.player.playlist.playTrack(path)
                }, remorseTimerSecs * 1000)
            }
            function addTrackRemorse() {
                remorseAction(qsTr("Adding track"), function () {
                    ctl.player.playlist.addTrack(path)
                }, remorseTimerSecs * 1000)
            }
            function addTrackAfterCurrentRemorse() {
                remorseAction(qsTr("Adding track"), function () {
                    ctl.player.playlist.addTrackAfterCurrent(path)
                }, remorseTimerSecs * 1000)
            }
            Component {
                id: contextMenu
                ContextMenu {
                    anchors {
                        right: (parent != null) ? parent.right : undefined
                        left: (parent != null) ? parent.left : undefined
                    }
                    MenuItem {
                        text: qsTr("Play track")
                        onClicked: {
                            playTrackRemorse()
                        }
                    }

                    MenuItem {
                        text: qsTr("Add track to list")
                        onClicked: {
                            addTrackRemorse()
                        }
                    }
                    MenuItem {
                        text: qsTr("Play after current")
                        onClicked: {
                            addTrackAfterCurrentRemorse()
                        }
                    }
                    MenuItem {
                        text: qsTr("Add to saved list")
                        onClicked: {
                            requestSavedPlaylists()
                            pageStack.push(Qt.resolvedUrl(
                                               "AddToPlaylistDialog.qml"), {
                                               "url": path
                                           })
                        }
                    }
                }
            }
        }
    }
}
