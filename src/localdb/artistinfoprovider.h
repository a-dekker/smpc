#ifndef ArtistInfoProvider_H
#define ArtistInfoProvider_H

#include <QObject>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrlQuery>
#include <QTimer>
#include <QElapsedTimer>

#include <mpd/mpdartist.h>
#include <common.h>
#include <localdb/artistinformation.h>

/**
 * @brief Retrieves the biography and the image of an artist.
 * The biography comes from Wikipedia, the image from Deezer.
 */
class ArtistInfoProvider : public QObject
{
    Q_OBJECT
public:
    /** What to look up for an artist */
    enum Mode {
        ModeBoth,
        ModeImageOnly,
        ModeInfoOnly
    };

    ArtistInfoProvider(QString artistName,QObject *parent=0);
    ~ArtistInfoProvider();

    void setArtist(QString artist);

    ArtistInformation* getLastInformation();

public slots:
    void requestDownload(MpdArtist artist, int mode = ModeBoth);

signals:
    void ready(ArtistInformation *artistInfo);
    void failed();

private:
    enum Stage {
        StageWikipedia,
        StageDeezer,
        StageImage
    };

    QString mArtistName;
    QString mImageURL;
    QString mArtistInfo;
    QNetworkAccessManager *mNetAccess;
    ArtistInformation *mLastInformation;
    Stage mStage;
    int mMode;

    // Wikipedia refuses clients which send many requests in a short time
    QUrl mWikipediaUrl;
    QElapsedTimer mLastWikipediaRequest;
    int mWikipediaRetries;
    void sendWikipediaRequest(int delayMs);

    void request(Stage stage, const QUrl &url);
    void searchWikipedia();
    void searchDeezer();
    void searchImageOrFinish();
    void finish(QByteArray *imgData);

    void wikipediaDone(const QByteArray &data);
    void deezerDone(const QByteArray &data);

private slots:
    void replyFinished(QNetworkReply *reply);
    void doWikipediaRequest();
};

#endif // ArtistInfoProvider_H
