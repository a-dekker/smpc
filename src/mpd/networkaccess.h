#ifndef NETWORKACCESS_H
#define NETWORKACCESS_H

#include <QObject>
#include <QtNetwork>
#include <QQmlEngine>
#include <mpd/mpdalbum.h>
#include <mpd/mpdartist.h>
#include <mpd/mpdtrack.h>
#include <mpd/mpdfileentry.h>
#include <mpd/mpdoutput.h>
#include <common.h>

// Timeout value for network communication
#define READYREAD 15000

class MpdAlbum;
class MpdArtist;
class MpdTrack;
class MpdFileEntry;

struct status_struct {
    quint32 playlistversion;
    qint32 id;
    quint16 bitrate;
    int tracknr;
    int albumtrackcount;
    quint8 percent;
    quint8 volume;
    QString info;
    QString title;
    QString album;
    QString artist;
    QString fileuri;
    quint8 playing;
    bool repeat;
    bool shuffle;
    quint32 length;
    quint32 currentpositiontime;
    quint32 playlistlength;
    quint32 samplerate;
    quint8 channelcount;
    quint8 bitdepth;
};


class NetworkAccess : public QThread
{
    Q_OBJECT
    
public:
    enum State {PAUSE,PLAYING,STOP};
    explicit NetworkAccess(QObject *parent = 0);
    Q_INVOKABLE bool connectToHost(QString hostname, quint16 port,QString password);
    Q_INVOKABLE bool connected();

    bool authenticate(QString passwort);
    void suspendUpdates();
    void resumeUpdates();
    void setUpdateInterval(quint16 ms);
    void seekPosition(int id,int pos);
    status_struct getStatus();
    void setConnectParameters(QString hostname,int port, QString password);
    void setQmlThread(QThread *thread);

    struct MpdVersion {
        quint32 mpdMajor1;
        quint32 mpdMajor2;
        quint32 mpdMinor;
    };

    struct MpdServerInfo {
        /* Version of the server */
        MpdVersion version;
        /* Capabilities of the connected server */
        bool mpd_cmd_list_group_capabilites;
        bool mpd_cmd_list_filter_criteria;
    };


signals:
    void connectionestablished();
    void disconnected();
    void statusUpdate(status_struct status);
    void connectionError(QString);
    void currentPlayListReady(QList<QObject*>*);
    void artistsReady(QList<QObject*>*);
    void albumsReady(QList<QObject*>*);
    void filesReady(QList<QObject*>*);
    void artistAlbumsReady(QList<QObject*>*);
    void albumTracksReady(QList<QObject*>*);
    void savedPlaylistsReady(QStringList*);
    void savedplaylistTracksReady(QList<QObject*>*);
    void outputsReady(QList<QObject*>*);
    void searchedTracksReady(QList<QObject*>*);

    void artistsAlbumsMapReady(QMap<MpdArtist*, QList<MpdAlbum*>* > *);

    void startupdateplaylist();
    void finishupdateplaylist();
    void busy();
    void ready();
    void requestExit();
public slots:
    void addTrackToPlaylist(QString fileuri);
    void addTrackToSavedPlaylist(QVariant data);
    void removeTrackFromSavedPlaylist(QVariant data);
    void addTrackAfterCurrent(QString fileuri);
    void addAlbumToPlaylist(QString album);
    void playAlbum(QString album);
    void addArtistAlbumToPlaylist(QString artist,QString album);
    void addArtistAlbumToPlaylist(QVariant albuminfo);
    void playArtistAlbum(QString artist, QString album);
    void playArtistAlbum(QVariant albuminfo);
    void addArtist(QString artist);
    void playArtist(QString artist);
    void playFiles(QString fileuri);
    void playTrack(QString fileuri);
    void playTrackByNumber(int nr);
    void deleteTrackByNumer(int nr);
    void socketConnected();
    void pause();
    void next();
    void previous();
    void stop();
    void updateDB();
    void clearPlaylist();
    void setVolume(int volume);
    void setRandom(bool);
    void setRepeat(bool);
    void disconnect();
    void connectToHost();
    quint32 getPlayListVersion();
    void getAlbums();
    void getArtists();
    void getTracks();
    void getArtistsAlbums(QString artist);
    void getAlbumTracks(QString album);
    void getAlbumTracks(QString album, QString cartist);
    //Variant [Artist,Album]
    void getAlbumTracks(QVariant albuminfo);

    // Plays current playlist entry (index) next
    void playTrackNext(int index);

    void getArtistAlbumMap();

    void getCurrentPlaylistTracks();
    void getPlaylistTracks(QString name);
    void getDirectory(QString path);
    void getSavedPlaylists();
    void seek(int pos);
    void savePlaylist(QString name);
    void addPlaylist(QString name);
    void playPlaylist(QString name);
    void deletePlaylist(QString name);
    void setUpdateInterval(int ms);
    void exitRequest();
    void enableOutput(int nr);
    void disableOutput(int nr);
    void getOutputs();
    void searchTracks(QVariant request);


protected slots:
    void connectedtoServer();
    void disconnectedfromServer();
    void updateStatusInternal();
    void errorHandle();


    
protected:
    //   void run();


private:

    QString hostname;
    quint16 port;
    QString password;
    QTcpSocket* tcpsocket;
    QString mpdversion;
    QTimer *statusupdater;
    quint16 updateinterval;
    quint32 mPlaylistversion;
    QList<MpdTrack*>* parseMPDTracks(QString cartist);
    QList<MpdArtist*>* getArtists_prv();
    QList<MpdTrack*>* getAlbumTracks_prv(QString album);
    QList<MpdTrack*>* getAlbumTracks_prv(QString album, QString cartist);
    QList<MpdAlbum*>* getArtistsAlbums_prv(QString artist);
    QMap<MpdArtist*, QList<MpdAlbum*>* > *getArtistsAlbumsMap_prv();
    QThread *mQmlThread;

    MpdServerInfo pServerInfo;
    void checkServerCapabilities();
};

#endif // NETWORKACCESS_H
