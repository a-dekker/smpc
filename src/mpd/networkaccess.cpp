#include "networkaccess.h"

/** Constructor for NetworkAccess object. Handles all the network stuff
  */

#define MPD_WHILE_PARSE_LOOP while (Q_LIKELY((mTCPSocket->state()==QTcpSocket::ConnectedState)&&(!response.startsWith("OK"))&&(!response.startsWith("ACK"))))

NetworkAccess::NetworkAccess(QObject *parent) :
    QThread(parent)
{
    mHostname = "";
    mPort = 6600;
    mPassword = "";

    mStatusInterval = 1000;
    mPlaylistversion = 0;
    mPlaybackStatus = new MPDPlaybackStatus();
    //create socket later used for communication
    mTCPSocket = nullptr;
    mStatusTimer = new QTimer(this);
    mQMLThread = nullptr;


    // Status updating/interpolation
    connect(mStatusTimer,SIGNAL(timeout()),this,SLOT(interpolateStatus()));

    // MPD idle stuff
    mIdling = false;
    // Timer used to countdown to idle mode. This ensures that the client not misses anything importang.
    mIdleCountdown = new QTimer(this);
    mIdleCountdown->setSingleShot(true);
    connect(mIdleCountdown,SIGNAL(timeout()),this,SLOT(goIdle()));

    /* Reset server capabilities */
    mServerInfo = nullptr;

    mTimeoutTimer = nullptr;
}

NetworkAccess::~NetworkAccess()
{
    if(connected() ) {
        // Try to disconnect here
        disconnectFromServer();
    }
    delete(mPlaybackStatus);
}

/** connects to host and return true if successful, false if not. Takes an string as hostname and int as port */
void NetworkAccess::connectToHost(QString hostname, quint16 port,QString password)
{
    emit busy();
    mHostname = hostname;
    mPort = port;
    mPassword = password;
    /* Check if the client is currently connected to a server, if yes disconnect */

    disconnectFromServer();

    Q_ASSERT(!mTCPSocket);

    if (!mTCPSocket) {
        // qDebug() << "Created new socket";
        mTCPSocket = new QTcpSocket(this);

        // TCP signal handling
        connect(mTCPSocket, SIGNAL(connected()), this, SLOT(onServerConnected()));
        connect(mTCPSocket, SIGNAL(disconnected()), this, SIGNAL(disconnected()));
        connect(mTCPSocket, SIGNAL(disconnected()), this, SLOT(onServerDisconnected()));
        connect(mTCPSocket, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(onConnectionError()));
        connect(mTCPSocket, SIGNAL(stateChanged(QAbstractSocket::SocketState)), this, SLOT(onConnectionStateChanged(QAbstractSocket::SocketState)));
    }

    mIdling = false;

    // Initiate TCP connection here
    qDebug() << "Connecting to: " << hostname << ":" << port;
    mTCPSocket->connectToHost(hostname, port, QIODevice::ReadWrite);
}

void NetworkAccess::disconnectFromServer()
{
    qDebug() << "Disconnect requested";

    emit busy();
    // Check if the socket is really connected before trying to close the connection.
    if (connected() && mTCPSocket) {
        // Send connection termination request.
        sendMPDCommand("close\n");

        // Wait for connection termination and forcefully close the socket if not done gracefully.
        mTCPSocket->close();
        mTCPSocket->waitForDisconnected(5000);
        if ( mTCPSocket->state() != QAbstractSocket::UnconnectedState) {
            mTCPSocket->abort();
            mTCPSocket->reset();
        }
        mIdling = false;
    }
    if (mTCPSocket) {
        mTCPSocket->deleteLater();
        mTCPSocket = nullptr;
    }
    // qDebug() << "Old socket cleared for deletion";
    emit ready();
}


/** return all albums currently availible from connected MPD as MpdAlbum objects,
  * empty list if not connected or no albums are availible */
void NetworkAccess::getAlbums()
{
    emit busy();
    /* Emit ready signal and send list with it */
    emit albumsReady((QList<QObject*>*)getAlbums_prv());
    /* Notify potential busy indicators */
    emit ready();
}

//QList<MpdAlbum *> *NetworkAccess::parseMPDAlbums()
//{
//    return parseMPDAlbums("");
//}

QList<MpdAlbum *> *NetworkAccess::parseMPDAlbums(QString listedArtist = nullptr)
{

    QList<MpdAlbum *> *albums = new QList<MpdAlbum *>();

    QString response = "";
    MpdAlbum *tempalbum;
    QString artist = listedArtist;
    QString name = "", mbid = "", date = "", section = "";
    QString name_old;
    QString tagName;

    bool skipFirstAlbum = mServerInfo->getListGroupFormatOld();

    MPD_WHILE_PARSE_LOOP
    {
        mTCPSocket->waitForReadyRead(READYREAD);
        while (mTCPSocket->canReadLine())
        {
            response = QString::fromUtf8(mTCPSocket->readLine()).trimmed();
            //qDebug() << response;
            if (response.startsWith(tagName = "AlbumArtist:")) {
                artist = response.split(tagName).takeLast().trimmed();
                        //response.right(response.length() - (tagName.length() + 1));
            } else if (response.startsWith(tagName = "Date:")) {
                date = response.split(tagName).takeLast().trimmed().left(4);
                        //response.right(response.length() - (tagName.length() + 1));
            } else if (response.startsWith(tagName = "MUSICBRAINZ_ALBUMID:")) {
                mbid = response.split(tagName).takeLast().trimmed();
            } else if (response.startsWith(tagName = "Album:")
                       /* also add last album for old list format: */
                       || (response == "OK" && mServerInfo->getListGroupFormatOld()))
            {
                QString _name = response.split(tagName).takeLast().trimmed();
                        //response.right(response.length() - (tagName.length()));

                /* add album
                 * (for old format, use previous albumname): */
                if (!mServerInfo->getListGroupFormatOld()) {
                    name = _name;
                }
                /* skip albums with no albumname when listing all albums*/
                if (!((name.isEmpty() && listedArtist.isEmpty())
                      /* skip first album entry for old list format */
                      || skipFirstAlbum || name == name_old))
                {
                    section = name.toUpper()[0];
                    //                    if (mUseAlbumArtist && listedArtist.isEmpty()) {
                    //                        section = artist.toUpper()[0];
                    //                    }
                    if (mSortAlbumsByYear && !listedArtist.isEmpty()) {
                        section = date;
                    }
                    //qDebug() << "adding album" << name << artist << date << mbid << section << skipFirstAlbum << name.isEmpty();
                    tempalbum = new MpdAlbum(nullptr, name, artist, date, mbid, section);
                    /* This helps with qml Q_PROPERTY accesses */
                    tempalbum->moveToThread(mQMLThread);
                    /* Set ownership to CppOwnership to guarantee that the GC of qml never deletes this */
                    QQmlEngine::setObjectOwnership(tempalbum, QQmlEngine::CppOwnership);
                    albums->append(tempalbum);
                }

                /* set new name for old list format */
                name = _name;
                /* set new name for old list format */
                skipFirstAlbum = false;
                // remember previous name, workaround for albums displayed multiple times when song name per album are not unique
                name_old = name;
            }
        }
    }

    return albums;
}


QList<MpdAlbum*> *NetworkAccess::getAlbums_prv()
{
    QList<MpdAlbum *> *albums = new QList<MpdAlbum *>();
    if (connected()) {

        /* Start getting list from mpd. If server is new enough try to filter my musicbrainz album id.
         * This helps with albums that have the same name as others (e.g. "Greatest Hits").
         * Not fully implemented yet
         * Multiple use of grouping issue v>20.21 v<21.11: https://github.com/MusicPlayerDaemon/MPD/issues/408
         */

        //qDebug() << "Getting albums";
        if (mServerInfo->getListGroupSupported()) {
            //qDebug() << "Getting albums multigroup";
            if (mServerInfo->getListMultiGroupSupported()) {
                sendMPDCommand(QString("list album group MUSICBRAINZ_ALBUMID group albumartist\n"));
            } else {
                sendMPDCommand(QString("list album group albumartist\n"));
            }
        } else {
            sendMPDCommand(QString("list album\n"));
        }
        albums = parseMPDAlbums();
    }

    /* Sort list */
    std::sort(albums->begin(), albums->end(), MpdAlbum::lessThan);

    return albums;
}

void NetworkAccess::getArtists()
{
    emit busy();
    /* Requests all artists of the mpd database and send them back with a ready signal */
    emit artistsReady((QList<QObject*>*)getArtists_prv());
    emit ready();

}

/* Private function to fetch and parse artists from mpd */
QList<MpdArtist *> *NetworkAccess::getArtists_prv()
{
    QList<MpdArtist *> *artists = new QList<MpdArtist*>();
    if (connected()) {
        //Send request
        //TODO is it proper to use albumartist here??
        QString tagName = (mUseAlbumArtist ? "albumartist" : "artist");
        sendMPDCommand(QString("list %1\n").arg(tagName));

        //Read & parse all artists until OK send from mpd
        tagName = (mUseAlbumArtist ? "AlbumArtist:" : "Artist:");
        QString response = "";
        MpdArtist *tempartist;
        QString name;
        MPD_WHILE_PARSE_LOOP
        {
            /* Wait until data is available */
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                /* Read line and chop new line at the end */
                response = QString::fromUtf8(mTCPSocket->readLine()).trimmed();
                //qDebug() << response;
                /* Parse mpd output */
                if (response.startsWith(tagName))
                {
                    name = response.split(tagName).takeLast().trimmed();
                    tempartist = new MpdArtist(nullptr, name);
                    /* This helps with qml Q_PROPERTY accesses */
                    tempartist->moveToThread(mQMLThread);
                    /* Set ownership to CppOwnership to guarantee that the GC of qml never deletes this */
                    QQmlEngine::setObjectOwnership(tempartist, QQmlEngine::CppOwnership);
                    artists->append(tempartist);
                }
            }
        }
    }
    /* Sort the created list */
    std::sort(artists->begin(), artists->end(), MpdArtist::lessThan);
    /* Return the list directly, this will later be send further via signals for multithreading. */
    return artists;
}

/* Tries to authenticate with mpd server. Returns true if successfully authenticated */
bool NetworkAccess::authenticate(QString password)
{
    if (connected()) {

        QTextStream outstream(mTCPSocket);
        outstream.setCodec("UTF-8");
        outstream << "password " << password << "\n";
        outstream.flush();
        mTCPSocket->waitForReadyRead(READYREAD);
        //Check Response
        QString response;
        while (mTCPSocket->canReadLine())
        {
            response += mTCPSocket->readLine();
        }
        QString teststring = response;
        teststring.truncate(2);
        /* Check authentication result here and return */
        if (teststring == QString("OK"))
        {
            return true;
        }
        return false;
    }
    return false;
}

QString NetworkAccess::escapeCommandArgument(const QString arg)
{
    //FIXME fooxl: is this enough? Do we need to escape backslashes themselves?
    return QString(arg).replace("\"","\\\"").replace("\'","\\\'");
}


void NetworkAccess::getArtistsAlbums(QString artist)
{
    emit busy();
    /* Request all albums for the specific artist and send them away via a signal
     * for multithreading. */
    emit(artistAlbumsReady((QList<QObject*>*)getArtistsAlbums_prv(artist)));
    emit ready();
}

QList<MpdAlbum *> *NetworkAccess::getArtistsAlbums_prv(QString artist)
{
    QList<MpdAlbum *> *albums = new QList<MpdAlbum *>();
    if (connected()) {
        //Send request
        /* command %1: tag albumartist/artist; %2: name of artist; %3: groups */
        QString command = "list album %1 \"%2\" %3\n";
        QString artistTagName = "", groupString = "";
        if (mServerInfo->getListGroupSupported()) {
            if (mServerInfo->getListMultiGroupSupported()) {
                groupString = "group MUSICBRAINZ_ALBUMID" + (mSortAlbumsByYear ? QString(" group date") : QString());
            } else {
                groupString = (mSortAlbumsByYear ? QString("group date") : QString("group MUSICBRAINZ_ALBUMID"));
            }
            artistTagName = (mUseAlbumArtist ? QString("albumartist") : QString("artist"));
        }
        //qDebug() << command.arg(artistTagName).arg(escapeCommandArgument(artist)).arg(groupString);
        sendMPDCommand(command.arg(artistTagName).arg(escapeCommandArgument(artist)).arg(groupString));

        albums = parseMPDAlbums(artist);
    }

    //Get album tracks
    if (mSortAlbumsByYear) std::sort(albums->begin(), albums->end(), MpdAlbum::lessThanDate);
    else std::sort(albums->begin(), albums->end(), MpdAlbum::lessThan);
    return albums;
}

void NetworkAccess::getAlbumTracks(QString album)
{
    emit busy();
    emit trackListReady(getAlbumTracks_prv(album));
    emit ready();
}

QList<MpdTrack*>* NetworkAccess::getAlbumTracks_prv(QString album)
{
    if (connected()) {
        //TODO new filter syntax (album == "album")
        sendMPDCommand(QString("find album \"") + escapeCommandArgument(album) + "\"\n");
    }
    return parseMPDTracks("");
}

void  NetworkAccess::getAlbumTracks(QString album, QString cartist)
{
    emit busy();
    emit trackListReady(getAlbumTracks_prv(album,cartist));
    emit ready();
}

void  NetworkAccess::getAlbumTracks(QVariant albuminfo)
{
    emit busy();
    // New qt 5.4 qml->c++ qvariant cast
    if (albuminfo.userType() == qMetaTypeId<QJSValue>()) {
        albuminfo = qvariant_cast<QJSValue>(albuminfo).toVariant();
    }

    QStringList strings = albuminfo.toStringList();
    emit trackListReady(getAlbumTracks_prv(strings[1],strings[0]));
    emit ready();
}

QList<MpdTrack*>*  NetworkAccess::getAlbumTracks_prv(QString album, QString cartist)
{
    if (cartist=="")
    {

        return getAlbumTracks_prv(album);
    }
    if (connected()) {
        sendMPDCommand(QString("find album \"%1\"\n").arg(escapeCommandArgument(album)));
    }
    return parseMPDTracks(cartist);
}

void NetworkAccess::getTracks()
{
    emit busy();
    if (connected()) {
        sendMPDCommand("listallinfo\n");
    }
    emit parseMPDTracks("");
    emit ready();
}



void NetworkAccess::getCurrentPlaylistTracks()
{
    emit busy();
    if (connected()) {
        sendMPDCommand("playlistinfo\n");
    }
    emit currentPlaylistReady(parseMPDTracks(""));
    emit ready();
}


void NetworkAccess::getPlaylistTracks(QString name)
{
    emit busy();
    if (connected()) {
        sendMPDCommand(QString("listplaylistinfo \"") + name + "\"\n");
    }
    emit trackListReady(parseMPDTracks(""));
    emit ready();
}


void NetworkAccess::getStatus()
{
    // qDebug() << "::getStatus()";
    if (connected()) {
        QString response ="";

        QString playlistidstring="-1";
        quint32 playlistversion = 0;
        QString tracknrstring="";

        QString timestring;
        QString elapstr,runstr;

        sendMPDCommand("status\n");

        bool newSong = false;
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            mLastStatusTimestamp.start();
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());
                response.chop(1);
                if (response.startsWith("bitrate: ")) {
                    mPlaybackStatus->setBitrate(response.right(response.length()-9).toUInt());
                }
                else if (response.startsWith("time: ")) {
                    timestring = response.right(response.length()-6);
                    elapstr = timestring.split(":").at(0);
                    runstr = timestring.split(":").at(1);
                    mPlaybackStatus->setCurrentTime(elapstr.toInt());
                    mPlaybackStatus->setLength(runstr.toInt());
                    mLastSyncElapsedTime = elapstr.toUInt();
                }
                else if (response.startsWith("song: ")) {
                    playlistidstring = response.right(response.length()-6);
                    if ( playlistidstring.toUInt() != mPlaybackStatus->getID() ) {
                        newSong = true;
                    }
                    mPlaybackStatus->setID(playlistidstring.toUInt());
                }
                else if (response.startsWith("volume: ")) {
                    //qDebug() << response.right(response.length()-8);
                    mPlaybackStatus->setVolume(response.right(response.length()-8).toUInt());
                }
                else if (response.startsWith("playlist: ")) {
                    playlistversion = response.right(response.length()-10).toUInt();
                    if ( playlistversion != mPlaybackStatus->getPlaylistVersion() ) {
                        newSong = true;
                    }
                    mPlaybackStatus->setPlaylistVersion(playlistversion);
                }
                else if (response.startsWith("playlistlength: ")) {
                    mPlaybackStatus->setPlaylistSize(response.right(response.length()-16).toUInt());
                }
                else if (response.startsWith("state: ")) {
                    {
                        response = response.right(response.length()-7);
                        if (response == "play")
                        {
                            if ( mPlaybackStatus->getPlaybackStatus() == MPD_STOP) {
                                newSong = true;
                            }
                            mPlaybackStatus->setPlaybackStatus(MPD_PLAYING);
                        }
                        else if (response == "pause") {
                            if ( mPlaybackStatus->getPlaybackStatus() == MPD_STOP) {
                                newSong = true;
                            }
                            mPlaybackStatus->setPlaybackStatus(MPD_PAUSE);
                        }
                        else if (response == "stop") {
                            mPlaybackStatus->setPlaybackStatus(MPD_STOP);
                        }
                    }
                }
                else if (response.startsWith("repeat: ")) {
                    {
                        // qDebug() << response;
                        mPlaybackStatus->setRepeat(response.right(response.length()-8) == "1" ? true : false);
                    }
                }
                else if (response.startsWith("consume: ")) {
                    {
                        // qDebug() << response;
                        mPlaybackStatus->setConsume(response.right(response.length()-9) == "1" ? true : false);
                    }
                }
                else if (response.startsWith("single: ")) {
                    {
                        // qDebug() << response;
                        QString r = response.right(response.length()-8);
                        mPlaybackStatus->setSingle(r == "1" ? MPD_SINGLE_ON :
                                                               r == "3" ? MPD_SINGLE_ONESHOT : MPD_SINGLE_OFF);
                    }
                }
                else if (response.startsWith("random: ")) {
                    {
                        // qDebug() << response;
                        mPlaybackStatus->setShuffle(response.right(response.length()-8) == "1" ? true : false);
                    }
                }
                else if(response.startsWith("audio: ")) {
                    QStringList templist = response.right(response.length()-7).split(":");
                    if(templist.length()==3){
                        mPlaybackStatus->setSamplerate(templist.at(0).toUInt());
                        mPlaybackStatus->setChannelCount(templist.at(2).toUInt());
                        mPlaybackStatus->setBitDepth(templist.at(1).toUInt());
                    }
                }

            }
        }

        if ( newSong ) {
            //FIXME why clearPlayback?
            //mPlaybackStatus->clearPlayback();
            response = "";
            sendMPDCommand("currentsong\n");
            MPD_WHILE_PARSE_LOOP
            {
                mTCPSocket->waitForReadyRead(READYREAD);
                while (mTCPSocket->canReadLine())
                {
                    response = QString::fromUtf8(mTCPSocket->readLine());
                    response.chop(1);
                    if (response.startsWith("Title: ")) {
                        mPlaybackStatus->setTitle(response.right(response.length()-7));
                    }
                    else if (response.startsWith("Artist: ")) {
                        mPlaybackStatus->setArtist(response.right(response.length()-8));
                    }
                    else if (response.startsWith("Album: ")) {
                        mPlaybackStatus->setAlbum(response.right(response.length()-7));
                    }
                    else if (response.startsWith("file: ")) {
                        mPlaybackStatus->setURI(response.right(response.length()-6));
                    }
                    else if (response.startsWith("Track: "))
                    {
                        tracknrstring = response.right(response.length()-7);
                        //tracknr = tracknrstring.toInt();
                        QStringList tempstrs = tracknrstring.split("/");
                        if (tempstrs.length() == 2)
                        {
                            mPlaybackStatus->setTrackNo(tempstrs.first().toUInt());
                            mPlaybackStatus->setAlbumTrackCount(tempstrs.at(1).toUInt());

                        }
                        else if (tempstrs.length() == 1)
                        {
                            mPlaybackStatus->setTrackNo(tracknrstring.toUInt());
                        }
                    }
                }
            }
        }

        if (mPlaylistversion!=playlistversion)
        {
            getCurrentPlaylistTracks();
        }
        mPlaylistversion = playlistversion;
        // qDebug() << "::getStatus() return";
    }
}


void NetworkAccess::pause()
{
    if (connected()) {
        MPD_PLAYBACK_STATE playbackState = getPlaybackState();
        if(playbackState != MPD_STOP) {
            sendMPDCommand("pause\n");
            QString response ="";
            MPD_WHILE_PARSE_LOOP
            {
                mTCPSocket->waitForReadyRead(READYREAD);
                while (mTCPSocket->canReadLine())
                {
                    response = QString::fromUtf8(mTCPSocket->readLine());

                }
            }
            //getStatus();
        }
        else {
            playTrackByNumber(getPlaybackID());
        }
    }
}

void NetworkAccess::stop()
{
    if (connected()) {
        sendMPDCommand("stop\n");
        QString response ="";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
        //getStatus();
    }
}

void NetworkAccess::enableOutput(int nr)
{
    if (connected()) {
        sendMPDCommand(QString("enableoutput ") + QString::number(nr) + "\n");
        QString response ="";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
    }
}

void NetworkAccess::disableOutput(int nr)
{
    if (connected()) {
        sendMPDCommand(QString("disableoutput ") + QString::number(nr) + "\n");
        QString response ="";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
    }
}

void NetworkAccess::updateDB()
{
    if (connected()) {
        sendMPDCommand("update\n");
        QString response ="";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
        //getStatus();
    }
}

void NetworkAccess::next()
{
    if (connected()) {
        sendMPDCommand("next\n");
        QString response ="";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
        //getStatus();
    }
}

void NetworkAccess::previous()
{
    if (connected()) {
        sendMPDCommand("previous\n");
        QString response ="";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
        //getStatus();
    }
}

void NetworkAccess::addAlbumToPlaylist(QString album)
{
    emit busy();
    if (connected()) {
        QList<MpdTrack*> *temptracks = new QList<MpdTrack*>();
        QString response ="";

        temptracks = getAlbumTracks_prv(album);
        //Add Tracks to Playlist
        sendMPDCommand("command_list_begin\n");
        for (int i=0;i<temptracks->length();i++)
        {
            sendMPDCommand(QString("add \"") + escapeCommandArgument(temptracks->at(i)->getFileUri()) + "\"\n");
        }
        sendMPDCommand("command_list_end\n");
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
    }
    emit ready();
    //   getStatus();
}

void NetworkAccess::addArtistAlbumToPlaylist(QString artist, QString album)
{
    emit busy();
    if (connected()) {
        QList<MpdTrack*> *temptracks = new QList<MpdTrack*>();
        //album.replace(QString("\""),QString("\\\""));
        QString response ="";
        temptracks = getAlbumTracks_prv(album,artist);

        //Add Tracks to Playlist
        sendMPDCommand("command_list_begin\n");
        for (int i=0;i<temptracks->length();i++)
        {
            sendMPDCommand(QString("add \"%1\"\n").arg(escapeCommandArgument(temptracks->at(i)->getFileUri())));
        }
        sendMPDCommand("command_list_end\n");
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
    }
    emit ready();
    //     getStatus();
}



//void NetworkAccess::addArtistAlbumToPlaylist(QVariant albuminfo)
//{
//    // New qt 5.4 qml->c++ qvariant cast
//    if (albuminfo.userType() == qMetaTypeId<QJSValue>()) {
//        albuminfo = qvariant_cast<QJSValue>(albuminfo).toVariant();
//    }

//    QStringList strings = albuminfo.toStringList();
//    addArtistAlbumToPlaylist(strings[0],strings[1]);
//}

//void NetworkAccess::playArtistAlbum(QVariant albuminfo)
//{
//    clearPlaylist();
//    // New qt 5.4 qml->c++ qvariant cast
//    if (albuminfo.userType() == qMetaTypeId<QJSValue>()) {
//        albuminfo = qvariant_cast<QJSValue>(albuminfo).toVariant();
//    }
////    addArtistAlbumToPlaylist(albuminfo);
//    playTrackByNumber(0);
//    setRandom(false);
//    setRepeat(false);
//}

void NetworkAccess::playArtistAlbum(QString artist, QString album)
{
    clearPlaylist();
    addArtistAlbumToPlaylist(artist,album);
    playTrackByNumber(0);
    setRandom(false);
    setRepeat(false);
}

void NetworkAccess::playAlbum(QString album)
{
    clearPlaylist();
    addAlbumToPlaylist(album);
    playTrackByNumber(0);
    setRandom(false);
    setRepeat(false);
}


void NetworkAccess::addTrackToPlaylist(QString fileuri)
{
    if (connected()) {
        sendMPDCommand(QString("add \"%1\"\n").arg(escapeCommandArgument(fileuri)));
        QString response ="";
        //Clear read buffer
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
    }
    //getStatus();
}

// Format [URI,playlistName]
void NetworkAccess::addTrackToSavedPlaylist(QVariant data)
{
    // New qt 5.4 qml->c++ qvariant cast
    if (data.userType() == qMetaTypeId<QJSValue>()) {
        data = qvariant_cast<QJSValue>(data).toVariant();
    }

    QStringList inputStrings = data.toStringList();
    if ( inputStrings.size() != 2 ) {
        return;
    }
    if (connected()) {
        //TODO escape URI??
        sendMPDCommand(QString("playlistadd \"") + inputStrings.at(1) + "\" \"" + inputStrings.at(0) + "\"\n");
        QString response ="";
        //Clear read buffer
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
    }
    //getStatus();
}

// Format [index,playlistName]
void NetworkAccess::removeTrackFromSavedPlaylist(QVariant data)
{
    // New qt 5.4 qml->c++ qvariant cast
    if (data.userType() == qMetaTypeId<QJSValue>()) {
        data = qvariant_cast<QJSValue>(data).toVariant();
    }
    QStringList inputStrings = data.toStringList();
    if ( inputStrings.size() != 2 ) {
        return;
    }
    if (connected()) {
        //TODO escape URI??
        sendMPDCommand(QString("playlistdelete \"") + inputStrings.at(1) + "\" " + inputStrings.at(0) + "\n");
        QString response ="";
        //Clear read buffer
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
    }
    //getStatus();
}

void NetworkAccess::playTrackNext(int index)
{
    quint32 currentPosition = getPlaybackID();
    if (connected()) {
        if (!(static_cast<quint32>(index) < currentPosition)) {
            currentPosition++;
        }
        sendMPDCommand(QString("move %1 %2\n").arg(index).arg(currentPosition));
        QString response ="";
        //Clear read buffer
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
    }
}

void NetworkAccess::addTrackAfterCurrent(QString fileuri)
{
    quint32 currentPosition = getPlaybackID();
    if (connected()) {
        sendMPDCommand(QString("addid \"") + escapeCommandArgument(fileuri) + "\" " + QString::number(currentPosition+1) + "\n");
        QString response ="";
        //Clear read buffer
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
    }
    //getStatus();
}

//Replace song with uri and plays it back
void NetworkAccess::playTrack(QString fileuri)
{
    clearPlaylist();
    if (connected()) {
        sendMPDCommand(QString("add \"%1\"\n").arg(escapeCommandArgument(fileuri)));
        QString response ="";
        //Clear read buffer
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
        //Get song id in playlist


        playTrackByNumber(0);
    }
    //getStatus();
}


// Append track to playlist and plays it.
void NetworkAccess::addPlayTrack(QString fileuri)
{
    if (connected()) {
        sendMPDCommand(QString("add \"%1\"\n").arg(escapeCommandArgument(fileuri)));
        QString response ="";
        //Clear read buffer
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
        //Get song id in playlist


        playTrackByNumber(getPlaylistLength() - 1);
    }
    //getStatus();
}

void NetworkAccess::playTrackByNumber(int nr)
{
    if (connected()) {
        sendMPDCommand(QString("play %1\n").arg(nr));
        QString response ="";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
        //getStatus();
    }
}

void NetworkAccess::deleteTrackByNumber(int nr)
{
    if (connected()) {
        sendMPDCommand(QString("delete " ) + QString::number(nr).toUtf8() + "\n");
        QString response ="";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
        //getStatus();
    }
}

void NetworkAccess::seekPosition(int id, int pos)
{
    // qDebug() << "seek: " << id << ":" << pos;
    if (connected()) {
        sendMPDCommand(QString("seek %1 %2\n").arg(id).arg(pos));
        QString response ="";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
        //getStatus();
    }
}

void NetworkAccess::seek(int pos)
{
    seekPosition(getPlaybackID(), pos);
}



void NetworkAccess::setRepeat(bool repeat)
{
    if (connected()) {
        sendMPDCommand(QString("repeat %1\n").arg(repeat ? "1":"0"));
        QString response ="";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());
            }
        }
    }
}

void NetworkAccess::setConsume(bool consume)
{
    if (connected()) {
        sendMPDCommand(QString("consume %1\n").arg(consume ? "1":"0"));
        QString response ="";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());
            }
        }
    }
}

void NetworkAccess::setSingle(quint8 single)
{
    if (connected()) {
//        QString arg;
//        if (single == 0 || single == 1) {
//            arg = QString(single);
//        } else if (single == 3) {
//            arg = QString("oneshot");
//        } else return;
        // qDebug() << single;
        // sendMPDCommand(QString("single %1\n").arg((single == 3 ? "oneshot" : QString(single))));
        sendMPDCommand(QString("single %1\n").arg((single == 3 ? "oneshot" : single == 2 ? "0" : "1")));
        QString response ="";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());
            }
        }
    }
}

void NetworkAccess::setRandom(bool random)
{
    if (connected()) {
        sendMPDCommand(QString("random %1\n").arg(random ? "1":"0"));
        QString response ="";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());
            }
        }
        //TODO do we need this at all?
        //getStatus();
    }
}

void NetworkAccess::setVolume(quint8 volume)
{
    if (connected()) {
        qDebug() << volume;
        sendMPDCommand(QString("setvol %1\n").arg(volume));
        QString response ="";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());
            }
        }
        //TODO do we need this at all?
//        if( mPlaybackStatus ) {
//            mPlaybackStatus->setVolume(volume);
//        }
        //getStatus();
    }
}

void NetworkAccess::savePlaylist(QString name)
{
    emit ready();
    if (connected()) {
        sendMPDCommand(QString("save \"%1\"\n").arg(escapeCommandArgument(name)));
        QString response ="";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());
            }
        }
        if (response.startsWith("OK"))
        {
            emit ready();
            return;
        }
        else {
            emit ready();
            return;
        }
    }
    emit ready();
    return;
}

void NetworkAccess::deletePlaylist(QString name)
{
    if (connected()) {
        sendMPDCommand(QString("rm \"%1\"\n").arg(escapeCommandArgument(name)));
        QString response ="";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());
            }
        }
        if (response.startsWith("OK"))
        {
            return;
        }
        else {
            return;
        }
    }
    return;
}

void NetworkAccess::getSavedPlaylists()
{
    emit busy();
    QStringList *tempplaylists  = new QStringList();
    if (connected()) {
        sendMPDCommand("listplaylists\n");
        QString response ="";
        QString name;

        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());
                response.chop(1);
                if (response.startsWith("playlist: ")) {
                    name = response.right(response.length()-10);
                    tempplaylists->append(name);
                }
            }
        }

    }
    tempplaylists->sort();
    emit ready();
    emit savedPlaylistsReady(tempplaylists);
}


void NetworkAccess::addPlaylist(QString name)
{
    emit busy();
    if (connected()) {
        sendMPDCommand(QString("load \"%1\"\n").arg(escapeCommandArgument(name)));
        QString response ="";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
    }
    emit ready();
}

void NetworkAccess::playPlaylist(QString name)
{
    emit busy();
    clearPlaylist();
    addPlaylist(name);
    playTrackByNumber(0);
    emit ready();
}

void NetworkAccess::clearPlaylist()
{
    if (connected()) {
        sendMPDCommand("clear\n");
        QString response ="";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());

            }
        }
        //getStatus();
    }
}

void NetworkAccess::onServerDisconnected()
{
    qDebug() << "Disconnected";
    mPlaylistversion = 0;
    if ( mPlaybackStatus) {
        mPlaybackStatus->clearPlayback();
        mPlaybackStatus->setID(0);
    }
    if (mStatusTimer->isActive())
    {
        mStatusTimer->stop();
    }
    mIdling = false;
    if ( mIdleCountdown->isActive()) {
        mIdleCountdown->stop();
    }

    /* Reset server capabilities */
    if(mServerInfo != nullptr) {
        delete(mServerInfo);
        mServerInfo = nullptr;
    }

    emit ready();
}

void NetworkAccess::onServerConnected() {
    qDebug() << "Connected to mpd server";

    mIdling = false;

    // Create new ServerInfo instance
    if (mServerInfo != nullptr) {
        delete(mServerInfo);
    }
    mServerInfo = new ServerInfo();

    if (connected()) {
        //Do host authentication
        mTCPSocket->waitForReadyRead(READYREAD);
        QString response;
        while (mTCPSocket->canReadLine())
        {
            response += mTCPSocket->readLine();
        }
        if (response.startsWith("OK MPD")) {
            QStringList versionParts = response.remove("OK MPD ").split(".");
            if (versionParts.length() == 3) {
                MPD_version_t version;
                version.mpdMajor1 = versionParts[0].toUInt();
                version.mpdMajor2 = versionParts[1].toUInt();
                version.mpdMinor = versionParts[2].toUInt();
                mServerInfo->setVersion(version);
            }
        }

        if (mPassword != "") {
            authenticate(mPassword);
        }
        checkServerCapabilities();
        emit ready();
        emit connectionEstablished();
        // qDebug() << "Handshake with server done";
    }


    mPlaylistversion = 0;
    if (mPlaybackStatus) {
        mPlaybackStatus->clearPlayback();
    }
    mIdling = false;

    //getStatus();

    mStatusTimer->start(mStatusInterval);
}

quint32 NetworkAccess::getPlayListVersion()
{
    quint32 playlistversion = 0;
    if (connected()) {
        sendMPDCommand("status\n");
        QString response ="";
        QString versionstring;
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());
                response.chop(1);
                if (response.startsWith("playlist: ")) {
                    versionstring = response.right(response.length()-10);
                    playlistversion = versionstring.toUInt();
                }
            }
        }
    }
    return playlistversion;
}

void NetworkAccess::getDirectory(QString path)
{
    emit busy();
    QList<MpdFileEntry*> *tempfiles = new QList<MpdFileEntry*>();
    if (connected()) {
        path.replace(QString("\""),QString("\\\""));


        //TODO escape path??
        sendMPDCommand(QString("lsinfo \"") + path + "\"\n");
        QString response ="";

        MpdTrack *temptrack=nullptr;
        MpdFileEntry *tempfile=nullptr;
        QString title="";
        QString artist="";
        QString album="";
        QString albumstring="";
        QString datestring = "";
        int nr=0;
        int albumnrs=0;
        QString file="";
        QString filename="";
        QString prepath="";
        QStringList tempsplitter;
        quint32 length=0;

        QString trackMBID;
        QString artistMBID;
        QString albumMBID;

        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());
                response.chop(1);
                //New file: so new track begins in mpds output
                if (response.startsWith("file: ")) {
                    if (file!=""&&length!=0)
                    {
                        tempsplitter = file.split("/");
                        if (tempsplitter.length()>0)
                        {
                            temptrack = new MpdTrack(nullptr,file,title,artist,album,length);
                            temptrack->setYear(datestring);
                            temptrack->setTrackNr(nr);
                            temptrack->setAlbumTracks(albumnrs);
                            temptrack->setAlbumMBID(albumMBID);
                            temptrack->setArtistMBID(artistMBID);
                            temptrack->setTrackMBID(trackMBID);
                            prepath ="";
                            for (int j=0;j<tempsplitter.length()-1;j++)
                            {
                                prepath += tempsplitter.at(j);
                                if (j!=tempsplitter.length()-2)
                                {
                                    prepath += "/";
                                }

                            }
                            tempfile = new MpdFileEntry(prepath,tempsplitter.last(),MpdFileEntry::MpdFileType_File,temptrack,nullptr);
                            tempfiles->append(tempfile);
                            temptrack->moveToThread(mQMLThread);
                            tempfile->moveToThread(mQMLThread);
                            QQmlEngine::setObjectOwnership(temptrack, QQmlEngine::CppOwnership);
                            QQmlEngine::setObjectOwnership(tempfile, QQmlEngine::CppOwnership);
                            artistMBID = "";
                            tempsplitter.clear();
                        }
                        artist= "";
                        albumstring="";
                        length=0;
                        album="";
                        title="";
                        filename="";
                        nr=0;
                        datestring="";
                        albumnrs=0;
                        trackMBID = "";
                        artistMBID = "";
                        albumMBID = "";
                    }
                    file = response.right(response.length()-6);
                }
                else if (response.startsWith("Title: ")) {
                    title = response.right(response.length()-7);
                }
                else if (response.startsWith("Artist: ")) {
                    artist = response.right(response.length()-8);
                }
                else if (response.startsWith("Album: ")) {
                    albumstring = response.right(response.length()-7);
                    album = albumstring;
                }
                else if (response.startsWith("Time: ")) {
                    albumstring = response.right(response.length()-6);
                    length = albumstring.toUInt();
                }
                else if (response.startsWith("Date: ")) {
                    datestring = response.right(response.length()-6);
                }
                else if (response.startsWith("Track: ")) {
                    albumstring = response.right(response.length()-7);
                    QStringList tracknrs;
                    tracknrs = albumstring.split('/');
                    if(tracknrs.length()>0)
                    {
                        nr = tracknrs.at(0).toInt();
                        if(tracknrs.length()>1)
                            albumnrs = tracknrs.at(1).toInt();
                    }
                }
                else if (response.startsWith("MUSICBRAINZ_TRACKID: ")) {
                    trackMBID = response.right(response.length()-21);
                }
                else if (response.startsWith("MUSICBRAINZ_ALBUMID: ")) {
                    albumMBID = response.right(response.length()-21);
                }
                else if (response.startsWith("MUSICBRAINZ_ARTISTID: ")) {
                    if ( artistMBID == "" ) {
                        artistMBID = response.right(response.length()-22);
                    }
                }
                //Directory found. WORKS
                else if (response.startsWith("directory: "))
                {
                    filename = response.right(response.length()-11);
                    tempsplitter = filename.split("/");
                    if (tempsplitter.length()>0)
                    {
                        prepath ="";
                        for (int j=0;j<tempsplitter.length()-1;j++)
                        {
                            prepath += tempsplitter.at(j);
                            if (j!=tempsplitter.length()-2)
                            {
                                prepath += "/";
                            }

                        }
                        tempfile = new MpdFileEntry(path,tempsplitter.last(),1,nullptr,nullptr);
                        tempfiles->append(tempfile);
                        tempfile->moveToThread(mQMLThread);
                        QQmlEngine::setObjectOwnership(tempfile, QQmlEngine::CppOwnership);
                        filename = "";
                        tempsplitter.clear();
                    }

                }
                if (response.startsWith("playlist: "))
                {
                    filename = response.right(response.length()-10);
                    tempsplitter = filename.split("/");
                    if (tempsplitter.length()>0)
                    {
                        prepath ="";
                        for (int j=0;j<tempsplitter.length()-1;j++)
                        {
                            prepath += tempsplitter.at(j);
                            if (j!=tempsplitter.length()-2)
                            {
                                prepath += "/";
                            }

                        }
                        tempfile = new MpdFileEntry(path,tempsplitter.last(),MpdFileEntry::MpdFileType_Playlist,nullptr,nullptr);
                        tempfiles->append(tempfile);
                        tempfile->moveToThread(mQMLThread);
                        filename = "";
                        tempsplitter.clear();
                    }

                }
            }
        }
        //LAST FILE ADD
        if (file!=""&&title!=""&&length!=0)
        {
            tempsplitter = file.split("/");
            if (tempsplitter.length()>0)
            {
                temptrack = new MpdTrack(nullptr,file,title,artist,album,length);
                temptrack->setTrackNr(nr);
                temptrack->setAlbumTracks(albumnrs);
                temptrack->setYear(datestring);
                temptrack->setAlbumMBID(albumMBID);
                temptrack->setArtistMBID(artistMBID);
                temptrack->setTrackMBID(trackMBID);
                prepath ="";
                for (int j=0;j<tempsplitter.length()-1;j++)
                {
                    prepath += tempsplitter.at(j);
                    if (j!=tempsplitter.length()-2)
                    {
                        prepath += "/";
                    }

                }
                // qDebug() << "Last album: " << albumstring;
                tempfile = new MpdFileEntry(prepath,tempsplitter.last(),MpdFileEntry::MpdFileType_File,temptrack,nullptr);
                tempfiles->append(tempfile);
                temptrack->moveToThread(mQMLThread);
                tempfile->moveToThread(mQMLThread);
                QQmlEngine::setObjectOwnership(temptrack, QQmlEngine::CppOwnership);
                QQmlEngine::setObjectOwnership(tempfile, QQmlEngine::CppOwnership);
                tempsplitter.clear();
            }
        }
    }
    std::sort(tempfiles->begin(),tempfiles->end(),MpdFileEntry::lessThan);
    emit ready();
    emit filesReady((QList<QObject*>*)tempfiles);
    //    return tempfiles;
}


void NetworkAccess::setUpdateInterval(int ms)
{
    mStatusInterval = ms;
    if (mStatusTimer->isActive())
    {
        mStatusTimer->stop();
        mStatusTimer->start(mStatusInterval);
    }
    if(ms==0){
        mStatusTimer->stop();
    }
}

bool NetworkAccess::connected()
{
    if (mTCPSocket && mTCPSocket->state() != QAbstractSocket::UnconnectedState)
    {
        return true;
    } else {
        return false;
    }
}

void NetworkAccess::onConnectionError()
{
    emit ready();
    mTCPSocket->disconnectFromHost();
}

void NetworkAccess::addArtist(QString artist)
{
    QList<MpdAlbum*> *albums = getArtistsAlbums_prv(artist);
    for(int i=0;i<albums->length();i++)
    {
        addArtistAlbumToPlaylist(artist,albums->at(i)->getTitle());
    }
}

void NetworkAccess::playArtist(QString artist)
{
    clearPlaylist();
    addArtist(artist);
    playTrackByNumber(0);
}

void NetworkAccess::setConnectParameters(QString hostname, int port, QString password)
{
    mHostname = hostname;
    mPassword = password;
    mPort = port;
}

void NetworkAccess::connectToHost()
{
    /* Invalidate current playlist */
    mPlaylistversion = 0;
    connectToHost(mHostname,mPort,mPassword);
}

QList<MpdTrack*>* NetworkAccess::parseMPDTracks(QString cartist)
{
    QList<MpdTrack*> *temptracks = new QList<MpdTrack*>();
    if (connected()) {
        QString response ="";

        MpdTrack *temptrack=nullptr;
        QString title;
        QString artist;
        QString albumartist;
        QString albumstring;
        QString datestring;
        int nr,albumnrs;
        nr = albumnrs = 0;
        QString file;
        QString trackMBID;
        QString albumMBID;
        QString artistMBID;
        quint32 length=0;
        MPD_WHILE_PARSE_LOOP
        {
            if (!mTCPSocket->waitForReadyRead(READYREAD))
            {
            }

            while (Q_LIKELY(mTCPSocket->canReadLine()))
            {
                response = QString::fromUtf8(mTCPSocket->readLine());
                // Remove new line
                response.chop(1);
                if (response.startsWith("file: ")) {
                    if (temptrack!=nullptr)
                    {
                        // Discard track if artist filter mismatches
                        if (albumartist==cartist||artist==cartist||cartist=="") {
                            temptracks->append(temptrack);
                            artistMBID = "";
                            temptrack->moveToThread(mQMLThread);
                            QQmlEngine::setObjectOwnership(temptrack, QQmlEngine::CppOwnership);
                        } else {
                            delete(temptrack);
                        }
                        temptrack=nullptr;
                    }
                    if (temptrack==nullptr)
                    {
                        temptrack = new MpdTrack(nullptr);
                    }
                    file = response.right(response.length()-6);
                    temptrack->setFileUri(file);
                }
                else if (response.startsWith("Title: ")) {
                    title = response.right(response.length()-7);
                    temptrack->setTitle(title);
                }
                else if (response.startsWith("Artist: ")) {
                    artist = response.right(response.length()-8);
                    temptrack->setArtist(artist);
                }
                else if (response.startsWith("AlbumArtist: ")) {
                    albumartist = response.right(response.length()-13);
                    temptrack->setAlbumArtist(albumartist);
                }
                else if (response.startsWith("Album: ")) {
                    albumstring = response.right(response.length()-7);
                    temptrack->setAlbum(albumstring);
                }

                else if (response.startsWith("Time: ")) {
                    albumstring = response.right(response.length()-6);
                    length = albumstring.toUInt();
                    temptrack->setLength(length);
                }
                else if (response.startsWith("Date: ")) {
                    datestring = response.right(response.length()-6);
                    temptrack->setYear(datestring);
                }
                else if (response.startsWith("MUSICBRAINZ_TRACKID: ")) {
                    trackMBID = response.right(response.length()-21);
                    temptrack->setTrackMBID(trackMBID);
                }
                else if (response.startsWith("MUSICBRAINZ_ALBUMID: ")) {
                    albumMBID = response.right(response.length()-21);
                    temptrack->setAlbumMBID(albumMBID);
                }
                else if (response.startsWith("MUSICBRAINZ_ARTISTID: ")) {
                    if ( artistMBID == "" ) {
                        artistMBID = response.right(response.length()-22);
                        temptrack->setArtistMBID(artistMBID);
                    }
                }
                else if (response.startsWith("Track: ")) {
                    albumstring = response.right(response.length()-7);
                    QStringList tracknrs;
                    tracknrs = albumstring.split('/');
                    if(tracknrs.length()>0)
                    {
                        nr = tracknrs.at(0).toInt();
                        if(tracknrs.length()>1) {
                            albumnrs = tracknrs.at(1).toInt();
                            temptrack->setAlbumTracks(albumnrs);
                        }
                    }
                    temptrack->setTrackNr(nr);
                }
            }

        }
        if (temptrack!=nullptr)
        {
            if (albumartist==cartist||artist==cartist||cartist=="") {
                temptrack->setPlaying(false);
                temptracks->append(temptrack);
                temptrack->moveToThread(mQMLThread);
                QQmlEngine::setObjectOwnership(temptrack, QQmlEngine::CppOwnership);
            }
            else {
                delete(temptrack);
                temptrack = nullptr;
            }
        }
    }
    return temptracks;
}

void NetworkAccess::exitRequest()
{
    this->disconnectFromServer();
    emit requestExit();
}

void NetworkAccess::getOutputs()
{
    if (connected()) {
        emit busy();
        QString response ="";
        QString tempstring;
        QList<MPDOutput*> *outputlist = new QList<MPDOutput*>();
        QString outputname;
        int outputid = 0;
        bool outputenabled = false;


        sendMPDCommand("outputs\n");
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine());
                response.chop(1);
                if (response.startsWith("outputname: ")) {
                    tempstring = response.right(response.length()-12);
                    outputname = tempstring;
                }
                if (response.startsWith("outputid: ")) {
                    tempstring = response.right(response.length()-10);
                    outputid = tempstring.toInt();
                }
                if (response.startsWith("outputenabled: ")) {
                    tempstring = response.right(response.length()-15);
                    outputenabled = ( tempstring=="1" ? true:false);
                    MPDOutput *tmpOutput = new MPDOutput(outputname,outputenabled,outputid);
                    outputlist->append(tmpOutput);
                    tmpOutput->moveToThread(mQMLThread);
                    QQmlEngine::setObjectOwnership(tmpOutput, QQmlEngine::CppOwnership);
                }


            }
        }
        emit outputsReady((QList<QObject*>*)outputlist);
        emit ready();
    }

}


void NetworkAccess::searchTracks(QVariant request)
{
    emit busy();
    // New qt 5.4 qml->c++ qvariant cast
    if (request.userType() == qMetaTypeId<QJSValue>()) {
        request = qvariant_cast<QJSValue>(request).toVariant();
    }
    QStringList searchrequest = request.toStringList();
    if (connected()) {
        //TODO escape request.at(1)??
        sendMPDCommand(QString("search ") + searchrequest.at(0) + " \"" + searchrequest.at(1) + "\"\n");
    }
    emit trackListReady(parseMPDTracks(""));
    emit ready();
}

void NetworkAccess::setQMLThread(QThread *thread)
{
    if (thread) {
        Q_ASSERT ( mQMLThread == nullptr );
        mQMLThread = thread;
    }
}

void NetworkAccess::getArtistAlbumMap()
{
    emit busy();
    emit artistsAlbumsMapReady(getArtistsAlbumsMap_prv());
    emit ready();
}

QMap<MpdArtist*, QList<MpdAlbum*>* > *NetworkAccess::getArtistsAlbumsMap_prv()
{
    QMap<MpdArtist*, QList<MpdAlbum*>* > *resMap = new QMap<MpdArtist*, QList<MpdAlbum*>* >();
    QList<MpdArtist*> *artists = getArtists_prv();
    for ( int i = 0; i < artists->length(); i++ ) {
        QList<MpdAlbum*> *albums = getArtistsAlbums_prv(artists->at(i)->getName());
        MpdArtist *tmpArtist = artists->at(i);
        (*resMap)[tmpArtist] = albums;
    }
    return resMap;
}


void NetworkAccess::checkServerCapabilities() {
    MPD_version_t *version = mServerInfo->getVersion();
    /* Check server version */
    //qDebug() << version->mpdMajor1 << version->mpdMajor2 << version->mpdMinor;
    //grouping reimplemented and format of response changed for grouped lists with reimplemenation as of >= 0.21.x
    //https://github.com/MusicPlayerDaemon/MPD/issues/408
    mServerInfo->setListGroupSupported((version->mpdMajor2 >= 19 && version->mpdMajor1 == 0) || (version->mpdMajor1 > 0));
    mServerInfo->setListMultiGroupSupported((version->mpdMinor >= 11 && version->mpdMajor2 >= 21 && version->mpdMajor1 == 0)
                                            || (version->mpdMajor1 > 0));
    mServerInfo->setListGroupFormatOld(!(version->mpdMajor2 >= 21 && version->mpdMajor1 == 0) || (version->mpdMajor1 > 0));



    /*
     * Get allowed commands
     */
    if (connected()) {
        sendMPDCommand("commands\n");
        QString response = "";
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine()).trimmed();
                //response.chop(1);
                //qDebug() << response;
                QString command = response.right(response.length()-9);
                if (command == "idle") {
                    mServerInfo->setIdleSupported(true);
                }
                if (command == "albumart") {
                    mServerInfo->setAlbumartSupported(true);
                }
            }
        }
        /*
         * Get allowed tags
         */
        sendMPDCommand("tagtypes\n");
        response = "";
        bool mbTrackId = false, mbArtistId = false, mbAlbumId = false;
        MPD_WHILE_PARSE_LOOP
        {
            mTCPSocket->waitForReadyRead(READYREAD);
            while (mTCPSocket->canReadLine())
            {
                response = QString::fromUtf8(mTCPSocket->readLine()).trimmed();
                //qDebug() << response;
                if (response.contains("MUSICBRAINZ_TRACKID")) {
                    mbTrackId = true;
                }
                if (response.contains("MUSICBRAINZ_ARTISTID")) {
                    mbArtistId = true;
                }
                if (response.contains("MUSICBRAINZ_ALBUMID")) {
                    mbAlbumId = true;
                }
            }
        }
        mServerInfo->setMBIDTagsSupported(mbTrackId && mbArtistId && mbAlbumId);
    }
}

MPDPlaybackStatus *NetworkAccess::getMPDPlaybackStatus() {
    return mPlaybackStatus;
}

void NetworkAccess::setSortAlbumsByYear(int state)
{
    mSortAlbumsByYear = (state == 1);
}

int NetworkAccess::sortAlbumsByYear()
{
    return mSortAlbumsByYear*1;
}

void NetworkAccess::setUseAlbumArtist(int state)
{
    mUseAlbumArtist = (state == 1);
}

int NetworkAccess::useAlbumArtist()
{
    return mUseAlbumArtist*1;
}

MPD_PLAYBACK_STATE NetworkAccess::getPlaybackState()
{
    //FIXME fooxl: what for???

//    MPD_PLAYBACK_STATE playbackState = MPD_STOP;
//    if (connected()) {
//        sendMPDCommand("status\n");
//        QString response;
//        MPD_WHILE_PARSE_LOOP
//        {
//            mTCPSocket->waitForReadyRead(READYREAD);
//            while (mTCPSocket->canReadLine())
//            {
//                response = QString::fromUtf8(mTCPSocket->readLine()).trimmed();
//                if (response.startsWith("state: ")) {
//                    {
//                        response = response.right(response.length()-7);
//                        if (response == "play")
//                        {
//                            playbackState = MPD_PLAYING;
//                        }
//                        else if (response == "pause") {
//                            playbackState = MPD_PAUSE;
//                        }
//                        else if (response == "stop") {
//                            playbackState = MPD_STOP;
//                        }
//                    }
//                }
//            }
//        }
//    }
//    return playbackState;
    return mPlaybackStatus->getPlaybackStatus();
}

quint32 NetworkAccess::getPlaybackID()
{
    //FIXME fooxl: what for???
    // qDebug() << "::getPlaybackID";
//    quint32 playbackID = 0;
//    if (connected()) {
//        sendMPDCommand("status\n");
//        QString response = "";
//        MPD_WHILE_PARSE_LOOP
//        {
//            // qDebug() << response;
//            mTCPSocket->waitForReadyRead(READYREAD);
//            while (mTCPSocket->canReadLine())
//            {
//                response = QString::fromUtf8(mTCPSocket->readLine()).trimmed();
//                if (response.startsWith("song: ")) {
//                    playbackID = response.right(response.length()-6).toUInt();
//                }
//            }
//        }
//    }
//    // qDebug() << "ID: " << playbackID;
//    return playbackID;
    return mPlaybackStatus->getID();
}

quint32 NetworkAccess::getPlaylistLength()
{
    //FIXME fooxl: what for???
//    quint32 playlistLength = 0;
//    if (connected()) {
//        sendMPDCommand("status\n");
//        QString response = "";
//        MPD_WHILE_PARSE_LOOP
//        {
//            mTCPSocket->waitForReadyRead(READYREAD);
//            while (mTCPSocket->canReadLine())
//            {
//                response = QString::fromUtf8(mTCPSocket->readLine()).trimmed();
//                if (response.startsWith("playlistlength: ")) {
//                    playlistLength = response.right(response.length()-16).toUInt();
//                }
//            }
//        }
//    }
//    return playlistLength;
    return mPlaybackStatus->getLength();
}


void NetworkAccess::interpolateStatus()
{
    if ( mIdling ) {
        /* Interpolate status here */
        if (mPlaybackStatus->getPlaybackStatus() == MPD_PLAYING &&
                mPlaybackStatus->getLength() > mPlaybackStatus->getCurrentTime()) {
            mPlaybackStatus->setCurrentTime(mLastSyncElapsedTime + mLastStatusTimestamp.elapsed()/1000  );
        }
        if (mLastSyncTime.elapsed() >= RESYNC_TIME) {
            // qDebug() << "resyncing mpd status for time drift";
            getStatus();
            goIdle();
        }
    } else {
        // qDebug() << "Not idling, polling status";
        getStatus();
        if (!mIdleCountdown->isActive() && connected() && mServerInfo->getIdleSupported()) {
            // qDebug() << "Idle counter is starting";
            mIdleCountdown->start();
        }
    }
}

void NetworkAccess::goIdle()
{
    if (mIdleCountdown->isActive()) {
        mIdleCountdown->stop();
    }
    // qDebug() << "Start idling";
    /* Start the idling and connect newData signal to slot */
    connect(mTCPSocket,SIGNAL(readyRead()),this,SLOT(onNewNetworkData()));
    if (connected()) {
        QTextStream outstream(mTCPSocket);
        outstream.setCodec("UTF-8");
        outstream << "idle mixer player options playlist" << "\n";
        outstream.flush();
    }
    mIdling = true;
    mLastSyncTime.start();
}

void NetworkAccess::cancelIdling()
{
    if ( !mIdling ) {
        return;
    }
    disconnect(mTCPSocket,SIGNAL(readyRead()),this,SLOT(onNewNetworkData()));
    mIdling = false;
    // qDebug() << "Stop idling";
    /* Start the idling and connect newData signal to slot */
    if (connected()) {
        //Do host authentication
        QTextStream outstream(mTCPSocket);
        outstream.setCodec("UTF-8");
        outstream << "noidle" << "\n";
        outstream.flush();
    }
    QString response;
    mTCPSocket->waitForReadyRead(READYREAD);
    while (mTCPSocket->canReadLine())
    {
        response += mTCPSocket->readLine();
    }
    // qDebug() << response;

}

void NetworkAccess::onNewNetworkData()
{
    QString response;
    while (mTCPSocket->canReadLine())
    {
        response += mTCPSocket->readLine();
        if ( mIdling && response.contains("changed") ) {
            disconnect(mTCPSocket,SIGNAL(readyRead()),this,SLOT(onNewNetworkData()));
            // qDebug() << "Idle seems to be over";
            mIdling = false;
            getStatus();
        }
        response = "";
    }
}

/*
 * React on changes of sockets connection state. This is required to get notified
 * about connection timeouts for example. This controls the busy indication */
void NetworkAccess::onConnectionStateChanged(QAbstractSocket::SocketState socketState)
{
    // qDebug() << "New connection state: " << socketState;
    switch ( socketState ) {
        case QAbstractSocket::UnconnectedState: {
        if ( mTimeoutTimer ) {
            mTimeoutTimer->stop();
            delete(mTimeoutTimer);
            mTimeoutTimer = nullptr;
        }
        emit ready();
        break;
    }
    case QAbstractSocket::HostLookupState: {
        if ( mTimeoutTimer == nullptr ) {
            mTimeoutTimer = new QTimer(this);
            mTimeoutTimer->setInterval(CONNECTION_TIMEOUT);
            connect(mTimeoutTimer,SIGNAL(timeout()),this,SLOT(onConnectionTimeout()));
            mTimeoutTimer->setSingleShot(true);
            mTimeoutTimer->start();
        } else {
            mTimeoutTimer->stop();
            mTimeoutTimer->start();
        }
        emit busy();
        break;
    }
    case QAbstractSocket::ConnectingState : {
        if ( mTimeoutTimer == nullptr ) {
            mTimeoutTimer = new QTimer(this);
            mTimeoutTimer->setInterval(CONNECTION_TIMEOUT);
            connect(mTimeoutTimer,SIGNAL(timeout()),this,SLOT(onConnectionTimeout()));
            mTimeoutTimer->setSingleShot(true);
            mTimeoutTimer->start();
        } else {
            mTimeoutTimer->stop();
            mTimeoutTimer->start();
        }
        emit busy();
        break;
    }
    case QAbstractSocket::ConnectedState : {
        if ( mTimeoutTimer ) {
            mTimeoutTimer->stop();
            delete(mTimeoutTimer);
            mTimeoutTimer = nullptr;
        }
        emit ready();
        break;
    }
    case QAbstractSocket::ClosingState:  {
        if ( mTimeoutTimer ) {
            mTimeoutTimer->stop();
            delete(mTimeoutTimer);
            mTimeoutTimer = nullptr;
        }
        emit busy();
        break;
    }
    default:
        emit ready();
    }
}

void NetworkAccess::onConnectionTimeout() {
    // qDebug() << "Connection attempt timeout";
    mTCPSocket->abort();
}

void NetworkAccess::sendMPDCommand(QString cmd)
{
    if (connected()) {
        /* It is important to cancel the idle command first
         * otherwise MPD disconnects the client */
        if (mIdling) {
            cancelIdling();
        }
        QTextStream outstream(mTCPSocket);
        outstream.setCodec("UTF-8");
        outstream << cmd;
        outstream.flush();
    }
}
