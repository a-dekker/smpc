import QtQuick 2.0
import Amber.Mpris 1.0

MprisPlayer {
    id: mprisPlayer

    property string artist: ctl.player.playbackStatus.artist
    property string artUrl: ""
    property string coverImageUrl: ""
    onArtistChanged: {
        metaData.contributingArtist = artist
    }

    Component.onCompleted: {
        albumArtRefresh.start()
    }

    onCoverImageUrlChanged: {
        albumArtRefresh.start()
    }

    property string song: ctl.player.playbackStatus.title
    property Timer albumArtRefresh: Timer {
        interval: 2000
        repeat: false
        onTriggered: {
            if (mainWindow.coverimageurl !== "") {
                artUrl = "file:///tmp/harbour-smpc/" + Qt.btoa(
                    coverImageUrl) + ".png"
                metaData.artUrl = artUrl
                console.debug(metaData.artUrl)
            }
            console.debug("changed over url")
        }
    }

    onSongChanged: {
        metaData.title = song
    }

    property string message: ""
    onMessageChanged: {
        if (message !== "") {
            console.debug("MPRIS Message: ", message)
            //console.debug(ctl.player.playbackStatus.playlistSize, ctl.player.playbackStatus.trackNo)
            console.debug("playlistSize and trackNo:")
            console.debug(ctl.player.playbackStatus.playlistSize,
                          ctl.player.playbackStatus.trackNo)
        }
        message = ""
    }

    serviceName: (connected ? "smpc" : "") //this (un)registers the service due to connection to mpd_server

    //Mpris2 Root Interface
    identity: "SMPC"
    //        supportedUriSchemes: ["file"]
    //        supportedMimeTypes: ["audio/x-wav", "audio/x-vorbis+ogg"]

    //Mpris2 Player Interface
    canControl: true
    canGoNext: playbackStatus !== Mpris.Stopped
               && ctl.player.playbackStatus.playlistSize > 1 && ctl.player.playbackStatus.playlistSize !== ctl.player.playbackStatus.trackNo
    //onCanGoNextChanged: console.debug(canGoNext)
    canGoPrevious: true
    //onCanGoPreviousChanged: console.debug(canGoPrevious, ctl.player.playbackStatus.trackNo)
    canPause: true //got to be always true for MprisController::playPause to work!
    canPlay: true //mprisPlayer.playbackStatus !== Mpris.Playing
    //onCanPlayChanged: console.debug("canPlay", canPlay)
    canSeek: mprisPlayer.playbackStatus === Mpris.Playing
             || mprisPlayer.playbackStatus === Mpris.Paused

    playbackStatus: (ctl.player.playbackStatus.playbackStatus
                     === 0 ? Mpris.Paused : (ctl.player.playbackStatus.playbackStatus
                                             === 1 ? Mpris.Playing : Mpris.Stopped))

    loopStatus: (ctl.player.playbackStatus.repeat ? 1 : 0)
    shuffle: ctl.player.playbackStatus.shuffle
    volume: ctl.player.playbackStatus.volume

    onPauseRequested: {
        message = "Pause requested"
        ctl.player.play()
    }
    onPlayRequested: {
        message = "Play requested"
        ctl.player.play()
    }
    onPlayPauseRequested: {
        message = "Play/Pause requested"
        ctl.player.play()
        albumArtRefresh.start()
    }
    onStopRequested: {
        message = "Stop requested"
        ctl.player.stop()
    }
    onNextRequested: {
        message = "Next requested"
        ctl.player.next()
    }
    onPreviousRequested: {
        message = "Previous requested"
        ctl.player.previous()
    }
}
