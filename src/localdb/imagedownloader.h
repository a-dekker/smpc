#ifndef IMAGEDOWNLOADER_H
#define IMAGEDOWNLOADER_H

#include <QObject>
#include <QByteArray>
#include <QThread>
#include <QMutex>
#include <QEventLoop>
#include <QQueue>

#include <mpd/mpdalbum.h>
#include <mpd/mpdartist.h>
#include <localdb/lastfmalbumprovider.h>
#include <localdb/artistinfoprovider.h>
#include <mpd/mpdartist.h>
#include <localdb/albuminformation.h>
#include <localdb/artistinformation.h>

class ImageDownloader : public QObject
{
    Q_OBJECT
public:

    ImageDownloader();
    ~ImageDownloader();

    int getArtistQueueSize();
    int getAlbumQueueSize();

    void setDownloadSize(QString size);


private:
    QThread *mWorkingThread;
    QMutex mDownloadCounterMutex;

    int mRunningAlbumDownloads;
    int mRunningArtistDownloads;

    QQueue<MpdAlbum> *mAlbumQueue;
    // Artists with the mode (ArtistInfoProvider::Mode) to download them with
    QQueue<QPair<MpdArtist,int> > *mArtistQueue;

    LastFMAlbumProvider *mAlbumProvider;
    ArtistInfoProvider *mArtistProvider;

    // Album waiting for an answer about its cover stored on the MPD server
    bool mLocalPending;
    QString mLocalTitle;
    QString mLocalArtist;

    void startAlbumDownload(MpdAlbum albumObj);



signals:
    void albumInformationReady(AlbumInformation *info);
    void artistInformationReady(ArtistInformation *info);
    void localCoverRequested(MpdAlbum album);

public slots:
    void requestAlbumArt(MpdAlbum albumObj);
    void albumInformationReceiver(AlbumInformation *info);
    void albumDownloadFailure();
    void localCoverReceiver(MpdAlbum album, QByteArray data);

    void requestArtistArt(MpdArtist artistObj, int mode = ArtistInfoProvider::ModeBoth);
    void artistInformationReceiver(ArtistInformation *info);
    void artistDownloadFailure();

    void clearDownloadQueue();


};

#endif // IMAGEDOWNLOADER_H
