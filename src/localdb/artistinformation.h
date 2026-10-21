#ifndef ArtistInformation_H
#define ArtistInformation_H

#include <QObject>
#include <QCryptographicHash>


class ArtistInformation : public QObject
{
    Q_OBJECT
public:
    explicit ArtistInformation(QString artist, QString artistInfo, QString url, QByteArray *imgData, QObject *parent= 0);
    ArtistInformation(const ArtistInformation&);
    ~ArtistInformation();

    QString getArtist() { return mArtistName; }
    QString getURL() { return mImageURL; }
    QString getArtistInfo() { return mArtistInfo; }
    QByteArray *getImageData() { return mImageData; }
    QString getImageHash() { return mImgHash; }

    /** Whether the biography / the image were looked up for this artist */
    bool infoFetched() { return mInfoFetched; }
    bool imageFetched() { return mImageFetched; }
    void setFetched(bool info, bool image) { mInfoFetched = info; mImageFetched = image; }

private:
    QString mArtistName;
    QString mArtistInfo;
    QString mImageURL;
    QString mImgHash;
    QByteArray *mImageData;
    bool mInfoFetched;
    bool mImageFetched;

    QString createImageHash(QByteArray *imgData);

signals:

public slots:

};

#endif // ArtistInformation_H
