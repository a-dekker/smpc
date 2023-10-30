import QtQuick 2.2
import Sailfish.Silica 1.0
import "pages"

// FIXME to harbour.smpc.components.whatever import
import "components"

ApplicationWindow {
    id: mainWindow

    // Signals for c++<->qml communication
    signal setHostname(string hostname)
    signal setPort(int port)
    signal setPassword(string password)
    signal setCurrentArtist(string artist)
    signal connectToServer

    // Signals for database requests to networkaccess
    signal addSongToSaved(variant data)
    signal removeSongFromSaved(variant data)
    signal addPlaylist(string name)
    signal playPlaylist(string name)
    signal playPlaylistSongNext(int index)
    // Adds all tracks from last search result to playlist
    signal addlastsearch
    signal requestSavedPlaylists
    signal requestSavedPlaylist(string name)
    signal requestAlbums
    signal requestAlbum(variant album)
    signal requestArtists
    signal requestArtistAlbums(string artist)
    signal requestFilesPage(string files)
    signal requestFilesModel(string files)
    signal requestOutputs
    signal requestSearch(variant request)
    // Request an MPD database update (remote mpd db)
    signal updateDB

    // Signals controller that stack of filemodels can be wiped
    signal popfilemodelstack
    signal cleanFileStack

    // Controller model clear signals (memory cleanup)
    signal clearAlbumList
    signal clearArtistList
    signal clearTrackList
    signal clearPlaylists

    // MPD Output controls
    signal enableOutput(int nr)
    signal disableOutput(int nr)

    //Playlist signals
    signal savePlaylist(string name)
    signal deleteSavedPlaylist(string name)

    // Changes server profile or creates new one
    signal changeProfile(variant profile)
    signal newProfile(variant profile)
    signal deleteProfile(int index)
    // Requests controller to connect to MPD host
    signal connectProfile(int index)

    // Database stuff (local-metadata DB)
    signal bulkDownloadArtists
    signal bulkDownloadAlbums
    signal cleanupBlacklisted
    signal cleanupArtists
    signal cleanupAlbums
    signal cleanupDB

    // Wiki/Biography information requests for sqlDB
    signal requestArtistInfo(string artist)
    signal requestAlbumInfo(variant album)

    // Signals change in download-size preference
    signal newDownloadSize(int size)

    // Signals changed settings key
    // [settingkey,value]
    signal newSettingKey(variant setting)

    signal wakeUpServer(int index)

    // Propertys of application
    property string hostname

    property int port
    property string password
    property int listfontsize: 12
    property int liststretch: 20
    property int lastsongid: ctl.player.playbackStatus.id
    property int volStep: 5
    property string playbuttoniconsourcecover: ctl.player.playbackStatus.playbackStatus
                                               === 1 ? "image://theme/icon-cover-pause" : "image://theme/icon-cover-play"
    property string volumebuttoniconsource
    property string lastpath
    property string artistname
    property string albumname
    property string playlistname
    property string coverimageurl
    property string artistimageurl
    property string profilename
    property bool quitbtnenabled
    property bool connected
    property bool playing: false
    property bool stopped: false
    property bool fastscrollenabled: false

    property real listPadding: Theme.paddingLarge
    property int populateDuration: 500

    //property bool volumeChanging: false

    // current song information
    property string mTitle: ctl.player.playbackStatus.title
    property string mArtist: ctl.player.playbackStatus.artist
    property string mAlbum: ctl.player.playbackStatus.album
    property int mVolume: ctl.player.playbackStatus.volume
    property int mLength: ctl.player.playbackStatus.length
    property int mPosition: ctl.player.playbackStatus.currentTime
    property int mPlaylistlength: ctl.player.playbackStatus.playlistSize
    property bool mDebugEnabled
    property bool mPositionSliderActive: false
    property string mAudioProperties: ctl.player.playbackStatus.samplerate + " Hz "
                                      + ctl.player.playbackStatus.bitDepth + " " + qsTr(
                                          "bits") + " "
                                      + ctl.player.playbackStatus.channelCount + " " + qsTr(
                                          "channels")
    property string mTrackNr: ctl.player.playbackStatus.trackNo
    property string mBitrate: ctl.player.playbackStatus.bitrate + " " + qsTr(
                                  "kbps")
    property string mUri: ctl.player.playbackStatus.uri
    property string mLengthText: formatLength(ctl.player.playbackStatus.length)

    property bool jollaQuickscroll: false

    property Page mPlaylistPage
    property Page mCurrentSongPage
    property bool applicationActive: Qt.application.active

    allowedOrientations: Orientation.Portrait | Orientation.Landscape
                         | Orientation.LandscapeInverted
    _defaultPageOrientations: Orientation.Portrait | Orientation.Landscape
                              | Orientation.LandscapeInverted

    // JS-functions
    //TODO separation
    function slotConnected(profile) {
        profilename = profile
        connected = true
    }

    function slotDisconnected() {
        connected = false
        profilename = ""
        playing = false
    }

    function busy() {
        busyIndicator.running = true
        inputBlock.enabled = true
    }

    function ready() {
        busyIndicator.running = false
        inputBlock.enabled = false
    }

    function savedPlaylistClicked(modelData) {
        playlistname = modelData
        requestSavedPlaylist(modelData)
    }

    function filesClicked(path) {
        lastpath = path
        requestFilesPage(path)
    }

    function albumTrackClicked(title, album, artist, lengthformatted, uri, year, tracknr, trackmbid, artistmbid, albummbid, genre) {
        pageStack.push(Qt.resolvedUrl("components/SongDialog.qml"), {
                           "title": title,
                           "album": album,
                           "artist": artist,
                           "filename": uri,
                           "lengthtext": lengthformatted,
                           "date": year,
                           "nr": tracknr,
                           "trackmbid": trackmbid,
                           "artistmbid": artistmbid,
                           "albummbid": albummbid,
                           "genre": genre
                       })
    }

    function receiveFilesPage() {
        pageStack.push("pages/database/FileBrowserPage.qml", {
                           "listmodel": filesModel,
                           "filepath": lastpath
                       })
        fastscrollenabled = true
    }

    function popCleared() {
        fastscrollenabled = true
    }

    // Nicely formats length values to string
    function formatLength(length) {
        if (length === 0) {
            return "00:00"
        }

        var temphours = Math.floor(length / 3600)
        var min = 0
        var sec = 0
        var temp = ""
        if (temphours > 1) {
            min = (length - (3600 * temphours)) / 60
        } else {
            min = Math.floor(length / 60)
        }
        sec = length - temphours * 3600 - min * 60
        if (temphours === 0) {
            temp = ((min < 10 ? "0" : "") + min) + ":" + (sec < 10 ? "0" : "") + (sec)
        } else {
            temp = ((temphours < 10 ? "0" : "") + temphours) + ":"
                    + ((min < 10 ? "0" : "") + min) + ":" + (sec < 10 ? "0" : "") + (sec)
        }
        return temp
    }

    function albumClicked(artist, albumstring) {
        requestAlbum([artist, albumstring])
        artistname = artist
        albumname = albumstring
    }

    function artistClicked(item) {
        mainWindow.artistname = item
        requestArtistAlbums(item)
    }

    function coverArtReceiver(url) {
        coverimageurl = url
        mprisPlayer.coverImageUrl = coverimageurl
    }

    function coverArtistArtReceiver(url) {
        artistimageurl = url
    }

    onApplicationActiveChanged: {
        if (useVolumeRocker) {
            // resourceHandler.acquire()
            if (!applicationActive) {
                resourceHandler.release()
            } else {
                resourceHandler.acquire()
            }
        }
    }

    // Notifies user about ongoing action in netaccess
    BusyIndicator {
        id: busyIndicator
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
    }

    // Prevents clicking if active request is running
    MouseArea {
        id: inputBlock
        anchors.fill: parent
        preventStealing: true
        enabled: false
    }

    Keys.onVolumeDownPressed: {
        // value: ctl.player.playbackStatus.volume
        if (mVolume >= 5) {
            volStep = 5
        } else {
            volStep = mVolume
        }
        ctl.player.setVolume(mVolume - volStep)
    }

    Keys.onVolumeUpPressed: {
        if (mVolume <= 95) {
            volStep = 5
        } else {
            volStep = 100 - mVolume
        }
        ctl.player.setVolume(mVolume + volStep)
    }

    SMPCMprisPlayer {
        id: mprisPlayer
    }

    ControlPanel {
        id: quickControlPanel
    }

    bottomMargin: quickControlPanel.visibleSize

    initialPage: Qt.resolvedUrl("pages/MainPage.qml")
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
}
