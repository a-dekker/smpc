import QtQuick 2.2
import Sailfish.Silica 1.0

Page {

    // Update mpd stats
    Component.onCompleted: requestCollectionInfo()

    PageHeader {
        id: header
        title: qsTr("Database")
        anchors {
            right: parent.right
            left: parent.left
        }
    }

    SilicaFlickable {
        id: mainFlickable
        anchors {
            fill: parent
            topMargin: header.height
        }
        contentHeight: mainColumn.height
        clip: true

        VerticalScrollDecorator {}

        Column {
            id: mainColumn
            anchors {
                right: parent.right
                left: parent.left
            }
            SectionHeader {
                text: qsTr("MPD server stats")
            }
            Row {
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                width: parent.width
                Label {
                    text: qsTr("Artists")
                    width: mainColumn.width - artistCount.width - Theme.paddingLarge * 2
                }
                Label {
                    id: artistCount
                    text: totalArtists
                    horizontalAlignment: Text.AlignRight
                    width: parent.width - (Theme.paddingLarge * 2)
                    color: Theme.secondaryColor
                }
            }
            Row {
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                width: parent.width
                Label {
                    text: qsTr("Albums")
                    width: mainColumn.width - albumCount.width - Theme.paddingLarge * 2
                }
                Label {
                    id: albumCount
                    text: totalAlbums
                    horizontalAlignment: Text.AlignRight
                    width: parent.width - (Theme.paddingLarge * 2)
                    color: Theme.secondaryColor
                }
            }
            Row {
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                width: parent.width
                Label {
                    text: qsTr("Songs")
                    width: mainColumn.width - songCount.width - Theme.paddingLarge * 2
                }
                Label {
                    id: songCount
                    text: totalSongs
                    horizontalAlignment: Text.AlignRight
                    width: parent.width - (Theme.paddingLarge * 2)
                    color: Theme.secondaryColor
                }
            }
            Row {
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                width: parent.width
                Label {
                    text: qsTr("DB playtime")
                    width: mainColumn.width - dbplayTime.width - Theme.paddingLarge * 2
                }
                Label {
                    id: dbplayTime
                    text: dBplayTimeFmt
                    horizontalAlignment: Text.AlignRight
                    width: parent.width - (Theme.paddingLarge * 2)
                    color: Theme.secondaryColor
                }
            }
            Row {
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                width: parent.width
                Label {
                    text: qsTr("DB update")
                    width: mainColumn.width - dbUpdateTime.width - Theme.paddingLarge * 2
                }
                Label {
                    id: dbUpdateTime
                    text: lastDbUpdate
                    horizontalAlignment: Text.AlignRight
                    width: parent.width - (Theme.paddingLarge * 2)
                    color: Theme.secondaryColor
                }
            }
            Row {
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                width: parent.width
                Label {
                    text: qsTr("MPD version")
                    width: mainColumn.width - mpdVer.width - Theme.paddingLarge * 2
                }
                Label {
                    id: mpdVer
                    text: mpdVersion
                    horizontalAlignment: Text.AlignRight
                    width: parent.width - (Theme.paddingLarge * 2)
                    color: Theme.secondaryColor
                }
            }

            SectionHeader {
                text: qsTr("Local stats")
            }
            Row {
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                width: parent.width
                Label {
                    text: qsTr("Artists")
                    width: mainColumn.width - artistsCount.width - Theme.paddingLarge * 2
                }
                Label {
                    id: artistsCount
                    text: dbStatistic.getArtistCount()
                    horizontalAlignment: Text.AlignRight
                    width: parent.width - (Theme.paddingLarge * 2)
                    color: Theme.secondaryColor
                }
            }
            Row {
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                width: parent.width
                Label {
                    text: qsTr("Albums")
                    width: mainColumn.width - albumCount.width - Theme.paddingLarge * 2
                }
                Label {
                    id: dbsongCount
                    text: dbStatistic.getAlbumCount()
                    horizontalAlignment: Text.AlignRight
                    width: parent.width - (Theme.paddingLarge * 2)
                    color: Theme.secondaryColor
                }
            }
            Row {
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                width: parent.width
                Label {
                    text: qsTr("Blacklisted albums")
                    width: mainColumn.width - blacklistCount.width - Theme.paddingLarge * 2
                }
                Label {
                    id: blacklistCount
                    text: dbStatistic.getAlbumBlacklistCount()
                    horizontalAlignment: Text.AlignRight
                    width: parent.width - (Theme.paddingLarge * 2)
                    color: Theme.secondaryColor
                }
            }
            Row {
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                width: parent.width
                Label {
                    text: qsTr("Images")
                    width: mainColumn.width - imagesCount.width - Theme.paddingLarge * 2
                }
                Label {
                    id: imagesCount
                    text: dbStatistic.getImageCount()
                    horizontalAlignment: Text.AlignRight
                    width: parent.width - (Theme.paddingLarge * 2)
                    color: Theme.secondaryColor
                }
            }
            Row {
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                width: parent.width
                Label {
                    text: qsTr("Filesize")
                    width: mainColumn.width - fileSizeMB.width - Theme.paddingLarge * 2
                }
                Label {
                    id: fileSizeMB
                    text: Math.round(
                              (dbStatistic.getDatabaseSize(
                                   ) / 1048576) * 100) / 100 + qsTr(" MB")
                    horizontalAlignment: Text.AlignRight
                    width: parent.width - (Theme.paddingLarge * 2)
                    color: Theme.secondaryColor
                }
            }
            Row {
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                width: parent.width
                visible: artistsRemaining.text !== ""
                Label {
                    text: qsTr("Artist downloads remaining")
                    width: mainColumn.width - artistsRemaining.width - Theme.paddingLarge * 2
                }
                Label {
                    id: artistsRemaining
                    text: dbStatistic.getArtistQueueSize()
                    horizontalAlignment: Text.AlignRight
                    width: parent.width - (Theme.paddingLarge * 2)
                    color: Theme.secondaryColor
                }
            }
            Row {
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                width: parent.width
                visible: albumRemaining.text !== ""
                Label {
                    text: qsTr("Album downloads remaining")
                    width: mainColumn.width - albumRemaining.width - Theme.paddingLarge * 2
                }
                Label {
                    id: albumRemaining
                    text: dbStatistic.getAlbumQueueSize()
                    horizontalAlignment: Text.AlignRight
                    width: parent.width - (Theme.paddingLarge * 2)
                    color: Theme.secondaryColor
                }
            }
            TextSwitch {
                id: lastfmEnabledSwitch
                text: qsTr("Last.fm Metadata download")
                checked: lastfmEnabled
                onClicked: {
                    if (checked) {
                        localCoverEnabledSwitch.checked = false
                        newSettingKey(["lastfmEnabled", "1"])
                    } else {
                        newSettingKey(["lastfmEnabled", "0"])
                    }
                }
            }

            TextSwitch {
                id: localCoverEnabledSwitch
                text: qsTr("Use album cover from MPD server")
                description: qsTr("Album art is read from a cover image (cover.jpg .png .webp, etc.) in the album folder on the server. Requires MPD 0.21 or newer.")
                checked: localCoverEnabled
                onClicked: {
                    if (checked) {
                        lastfmEnabledSwitch.checked = false
                        newSettingKey(["localCoverEnabled", "1"])
                    } else {
                        newSettingKey(["localCoverEnabled", "0"])
                    }
                }
            }

            ComboBox {
                id: downloadSizeComboBox
                visible: lastfmEnabled
                label: qsTr("Download size:")
                currentIndex: downloadSize
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Small")
                    }
                    MenuItem {
                        text: qsTr("Medium")
                    }
                    MenuItem {
                        text: qsTr("Large")
                    }
                    MenuItem {
                        text: qsTr("Extra large")
                    }
                    MenuItem {
                        text: qsTr("Mega")
                    }
                }

                onValueChanged: {
                    newDownloadSize(currentIndex)
                }
            }
            Row {
                x: Theme.paddingLarge
                visible: lastfmEnabled
                width: parent.width
                Image {
                    id: infoIcon
                    source: "image://theme/icon-s-warning"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Label {
                    id: warningLabel
                    width: parent.width - (Theme.paddingLarge + infoIcon.width)
                    font.bold: true
                    text: qsTr("Although the setting \"mega\" will look the best, it will require huge amount of local data cached.")
                    wrapMode: "WordWrap"
                }
            }

            Column {
                spacing: Theme.paddingSmall
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    id: downloadArtistImagesBtn
                    visible: lastfmEnabled || localCoverEnabled
                    width: isPortrait ? mainColumn.width - Theme.paddingLarge
                                        * 2 : (mainColumn.width / 2) * 0.95
                    text: qsTr("↓ Artist images [Deezer]")
                    onClicked: pageStack.push(dialogComponent, {
                                                  "confirmationRole": 4
                                              })
                    enabled: dbStatistic.getArtistQueueSize() === 0
                             && (lastfmEnabled || localCoverEnabled)
                }
                Button {
                    id: downloadArtistInfoBtn
                    visible: lastfmEnabled || localCoverEnabled
                    width: isPortrait ? mainColumn.width - Theme.paddingLarge
                                        * 2 : (mainColumn.width / 2) * 0.95
                    text: qsTr("↓ Artist info [Wikipedia]")
                    onClicked: pageStack.push(dialogComponent, {
                                                  "confirmationRole": 6
                                              })
                    enabled: dbStatistic.getArtistQueueSize() === 0
                             && (lastfmEnabled || localCoverEnabled)
                }
                Button {
                    id: downloadAlbumImagesBtn
                    visible: lastfmEnabled || localCoverEnabled
                    width: isPortrait ? mainColumn.width - Theme.paddingLarge
                                        * 2 : (mainColumn.width / 2) * 0.95
                    text: qsTr("↓ Album images")
                          + (localCoverEnabledSwitch.checked ? " [MPD]" : " [Last.fm]")
                    onClicked: pageStack.push(dialogComponent, {
                                                  "confirmationRole": 5
                                              })
                    enabled: dbStatistic.getAlbumQueueSize() === 0
                             && (lastfmEnabled || localCoverEnabled)
                }
                Button {
                    id: clearBlacklistBtn
                    width: isPortrait ? mainColumn.width - Theme.paddingLarge
                                        * 2 : (mainColumn.width / 2) * 0.95
                    text: qsTr("Clear blacklisted albums")
                    onClicked: pageStack.push(dialogComponent, {
                                                  "confirmationRole": 0
                                              })
                    enabled: dbStatistic.getArtistQueueSize() === 0
                             && dbStatistic.getAlbumQueueSize() === 0
                }
                Button {
                    id: clearArtistBtn
                    width: isPortrait ? mainColumn.width - Theme.paddingLarge
                                        * 2 : (mainColumn.width / 2) * 0.95
                    text: qsTr("Clear artist images")
                    onClicked: pageStack.push(dialogComponent, {
                                                  "confirmationRole": 1
                                              })
                    enabled: dbStatistic.getArtistQueueSize() === 0
                             && dbStatistic.getAlbumQueueSize() === 0
                }
                Button {
                    id: clearAlbumBtn
                    width: isPortrait ? mainColumn.width - Theme.paddingLarge
                                        * 2 : (mainColumn.width / 2) * 0.95
                    text: qsTr("Clear album images")
                    onClicked: pageStack.push(dialogComponent, {
                                                  "confirmationRole": 2
                                              })
                    enabled: dbStatistic.getArtistQueueSize() === 0
                             && dbStatistic.getAlbumQueueSize() === 0
                }
                Button {
                    id: clearDBBtn
                    width: isPortrait ? mainColumn.width - Theme.paddingLarge
                                        * 2 : (mainColumn.width / 2) * 0.95
                    text: qsTr("Clear complete database")
                    onClicked: pageStack.push(dialogComponent, {
                                                  "confirmationRole": 3
                                              })
                    enabled: dbStatistic.getArtistQueueSize() === 0
                             && dbStatistic.getAlbumQueueSize() === 0
                }
            }
        }
    }

    Component {
        id: dialogComponent

        Dialog {
            id: confirmationDialog
            property int confirmationRole
            property string headerText
            property string questionText

            DialogHeader {
                id: confirmationHeader
                title: headerText
            }
            Label {
                id: questionLabel
                text: questionText
                width: parent.width - (2 * listPadding)
                wrapMode: Text.WordWrap
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: confirmationHeader.bottom
                }
            }

            Component.onCompleted: {
                switch (confirmationRole) {
                    // Clear blacklisted albums
                case 0:
                    confirmationDialog.headerText = qsTr(
                                "Clear blacklist albums")
                    confirmationDialog.questionText = qsTr(
                                "Do you really want to delete all albums which are blacklisted from local database cache? There is no turning back!")
                    break
                    // Clear artists
                case 1:
                    confirmationDialog.headerText = qsTr("Clear artists")
                    confirmationDialog.questionText = qsTr(
                                "Do you really want to delete all artists from local database cache? There is no turning back!")
                    break
                    // Clear albums
                case 2:
                    confirmationDialog.headerText = qsTr("Clear albums")
                    confirmationDialog.questionText = qsTr(
                                "Do you really want to delete all albums from local database cache? There is no turning back!")
                    break
                    // Clear all
                case 3:
                    confirmationDialog.headerText = qsTr("Clear database")
                    confirmationDialog.questionText = qsTr(
                                "Do you really want to delete the complete local database cache? There is no turning back!")
                    break
                case 4:
                    confirmationDialog.headerText = qsTr("Download artists [Deezer]")
                    confirmationDialog.questionText = qsTr(
                                "This will download the images for all artists in your MPD database which have none yet. "
                                + "This action will run in the background but take some time.")
                    break
                case 6:
                    confirmationDialog.headerText = qsTr("Download artist info [wikipedia]")
                    confirmationDialog.questionText = qsTr(
                                "This will download the biography for all artists in your MPD database which have none yet. "
                                + "\n⚠️This action will run in the background and can take HOURS because of download rate limits.")
                    break
                case 5:
                    confirmationDialog.headerText = qsTr("Download albums")
                    confirmationDialog.questionText = qsTr(
                                "This will download metadata information for all your albums in your MPD database. "
                                + "This action will run in the background but take some time.")
                    break
                }
            }
            onAccepted: {
                switch (confirmationRole) {
                case 0:
                    cleanupBlacklisted()
                    break
                case 1:
                    cleanupArtists()
                    break
                case 2:
                    cleanupAlbums()
                    break
                case 3:
                    cleanupDB()
                    break
                case 4:
                    bulkDownloadArtists()
                    break
                case 5:
                    bulkDownloadAlbums()
                    break
                case 6:
                    bulkDownloadArtistInfo()
                    break
                }
            }
        }
    }
}
