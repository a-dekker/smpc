#include <localdb/imagedownloader.h>
#include <localdb/coversource.h>

#include <localdb/imageutil.h>

ImageDownloader::ImageDownloader()
{
    mRunningAlbumDownloads = 0;
    mRunningArtistDownloads = 0;
    mLocalPending = false;
    mAlbumProvider = new LastFMAlbumProvider("","",this);
    mArtistProvider = new ArtistInfoProvider("",this);
    mAlbumQueue = new QQueue<MpdAlbum>();
    mArtistQueue = new QQueue<QPair<MpdArtist,int> >();

//    mWorkingThread = new QThread(this);
//    moveToThread(mWorkingThread);
//    mWorkingThread->start();

    connect(mAlbumProvider,SIGNAL(ready(AlbumInformation*)),this,SIGNAL(albumInformationReady(AlbumInformation*)));
    connect(mAlbumProvider,SIGNAL(ready(AlbumInformation*)),this,SLOT(albumInformationReceiver(AlbumInformation*)));
    connect(mAlbumProvider,SIGNAL(failed()),this,SLOT(albumDownloadFailure()));

    connect(CoverSource::instance(),SIGNAL(localCoverReady(MpdAlbum,QByteArray)),this,SLOT(localCoverReceiver(MpdAlbum,QByteArray)));
    connect(this,SIGNAL(localCoverRequested(MpdAlbum)),CoverSource::instance(),SIGNAL(localCoverRequested(MpdAlbum)));

    connect(mArtistProvider,SIGNAL(ready(ArtistInformation*)),this,SIGNAL(artistInformationReady(ArtistInformation*)));
    connect(mArtistProvider,SIGNAL(ready(ArtistInformation*)),this,SLOT(artistInformationReceiver(ArtistInformation*)));
    connect(mArtistProvider,SIGNAL(failed()),this,SLOT(artistDownloadFailure()));

//    connect(mWorkingThread, &QThread::finished, mWorkingThread, &QObject::deleteLater);
}

ImageDownloader::~ImageDownloader()
{
    disconnect(mAlbumProvider);
    disconnect(this);
    mAlbumProvider->deleteLater();
    mAlbumProvider = 0;
    delete (mAlbumQueue);


//    mWorkingThread->quit();
//    mWorkingThread->wait();
}


void ImageDownloader::requestAlbumArt(MpdAlbum albumObj)
{
    // qDebug() << "Art requested for: " << albumObj.getTitle();
    // No running download, start downloading right away
    mDownloadCounterMutex.lock();
    int running = mRunningAlbumDownloads;
    mDownloadCounterMutex.unlock();
    if( running == 0 ) {
        // qDebug() << "No download running, start now";
        mDownloadCounterMutex.lock();
        mRunningAlbumDownloads++;
        startAlbumDownload(albumObj);
        mDownloadCounterMutex.unlock();
    } else {
        // Download already running, enqueue
        mAlbumQueue->enqueue(albumObj);
    }
}

void ImageDownloader::requestArtistArt(MpdArtist artistObj, int mode)
{
//    qDebug() << "Art requested for: " << artistObj.getName();
    // No running download, start downloading right away
    mDownloadCounterMutex.lock();
    int running = mRunningArtistDownloads;
    mDownloadCounterMutex.unlock();
    if( running == 0 ) {
//        qDebug() << "No download running, start now";
        mDownloadCounterMutex.lock();
        mRunningArtistDownloads++;
        mArtistProvider->requestDownload(artistObj,mode);
        mDownloadCounterMutex.unlock();
    } else {
        // Download already running, enqueue
        mArtistQueue->enqueue(qMakePair(artistObj,mode));
    }
}

void ImageDownloader::albumInformationReceiver(AlbumInformation *info)
{
//    qDebug() << "Album: " << info->getName() << " downloaded";
    mDownloadCounterMutex.lock();
    mRunningAlbumDownloads--;
    int running = mRunningAlbumDownloads;
    mDownloadCounterMutex.unlock();
    if ( running == 0 && ( mAlbumQueue->size() >0 ) ) {
        mDownloadCounterMutex.lock();
        mRunningAlbumDownloads++;
        MpdAlbum albumObj = mAlbumQueue->dequeue();
//        qDebug() << "Start downloading from queue item: " << albumObj.getTitle();
        startAlbumDownload(albumObj);
        mDownloadCounterMutex.unlock();
    } else {
//        qDebug() << "finished";
    }
}

void ImageDownloader::albumDownloadFailure()
{
//    qDebug() << "Album download failure";
    mDownloadCounterMutex.lock();
    mRunningAlbumDownloads--;
    int running = mRunningAlbumDownloads;
    mDownloadCounterMutex.unlock();
    if ( running == 0 && ( mAlbumQueue->size() >0 ) ) {
        mDownloadCounterMutex.lock();
        mRunningAlbumDownloads++;
        MpdAlbum albumObj = mAlbumQueue->dequeue();
//        qDebug() << "Start downloading from queue item: " << albumObj.getTitle();
        startAlbumDownload(albumObj);
        mDownloadCounterMutex.unlock();
    } else {
//        qDebug() << "finished";
    }
}


void ImageDownloader::artistInformationReceiver(ArtistInformation *info)
{
//    qDebug() << "Artist: " << info->getArtist() << " downloaded";
    mDownloadCounterMutex.lock();
    mRunningArtistDownloads--;
    int running = mRunningArtistDownloads;
    mDownloadCounterMutex.unlock();
    if ( running == 0 && ( mArtistQueue->size() >0 ) ) {
        mDownloadCounterMutex.lock();
        mRunningArtistDownloads++;
        QPair<MpdArtist,int> queued = mArtistQueue->dequeue();
        // qDebug() << "Start downloading from queue item: " << artistObj.getName();
        mArtistProvider->requestDownload(queued.first,queued.second);
        mDownloadCounterMutex.unlock();
    } else {
        // qDebug() << "finished";
    }
}

void ImageDownloader::artistDownloadFailure()
{
    // qDebug() << "Artist download failed";
    mDownloadCounterMutex.lock();
    mRunningArtistDownloads--;
    int running = mRunningArtistDownloads;
    mDownloadCounterMutex.unlock();
    if ( running == 0 && ( mArtistQueue->size() >0 ) ) {
        mDownloadCounterMutex.lock();
        mRunningArtistDownloads++;
        QPair<MpdArtist,int> queued = mArtistQueue->dequeue();
        // qDebug() << "Start downloading from queue item: " << artistObj.getName();
        mArtistProvider->requestDownload(queued.first,queued.second);
        mDownloadCounterMutex.unlock();
    } else {
        // qDebug() << "finished";
    }
}

int ImageDownloader::getArtistQueueSize()
{
    return mArtistQueue->size();
}

int ImageDownloader::getAlbumQueueSize()
{
    return mAlbumQueue->size();
}

void ImageDownloader::setDownloadSize(QString size)
{
    mAlbumProvider->setDownloadSize(size);
}

void ImageDownloader::clearDownloadQueue()
{
    mArtistQueue->clear();
    mAlbumQueue->clear();
}

void ImageDownloader::startAlbumDownload(MpdAlbum albumObj)
{
    if ( CoverSource::instance()->localEnabled() ) {
        // Try the cover stored on the MPD server first
        mLocalPending = true;
        mLocalTitle = albumObj.getTitle();
        mLocalArtist = albumObj.getArtist();
        emit localCoverRequested(albumObj);
    } else {
        mAlbumProvider->requestDownload(albumObj);
    }
}

void ImageDownloader::localCoverReceiver(MpdAlbum album, QByteArray data)
{
    // The answer is broadcast to all downloaders, only handle our own request
    if ( !mLocalPending || album.getTitle() != mLocalTitle || album.getArtist() != mLocalArtist ) {
        return;
    }
    mLocalPending = false;

    QByteArray cover = ImageUtil::squareJpeg(data);
    if ( !cover.isEmpty() ) {
        AlbumInformation *info = new AlbumInformation(mLocalTitle,mLocalArtist,"","",new QByteArray(cover),0);
        emit albumInformationReady(info);
        albumInformationReceiver(info);
    } else if ( CoverSource::instance()->lastFmEnabled() ) {
        // No local cover, fall back to last.fm
        mAlbumProvider->requestDownload(MpdAlbum(this,mLocalTitle,mLocalArtist));
    } else {
        albumDownloadFailure();
    }
}
