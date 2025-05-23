#ifndef MPDTRACK_H
#define MPDTRACK_H

#include <QObject>
#include <QStringList>
#include <QDebug>
#include <mpd/mpdalbum.h>
#include <mpd/mpdartist.h>

class MpdArtist;
class MpdAlbum;

class MpdTrack : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString title READ getTitle NOTIFY changed )
    Q_PROPERTY(QString uri READ getFileUri NOTIFY changed )
    Q_PROPERTY(QString lengthformatted READ getLengthFormated NOTIFY changed )
    Q_PROPERTY(int length READ getLength NOTIFY changed )
    Q_PROPERTY(QString artist READ getArtist NOTIFY changed )
    Q_PROPERTY(QString album READ getAlbum NOTIFY changed )
    Q_PROPERTY(bool playing READ getPlaying NOTIFY playingchanged )
    Q_PROPERTY(int tracknr READ getTrackNr NOTIFY changed )
    Q_PROPERTY(int discnr READ getDiscNr NOTIFY changed )
    Q_PROPERTY(QString year READ getYear NOTIFY changed )
    Q_PROPERTY(QString filename READ getFileName NOTIFY changed )
    Q_PROPERTY(QString trackmbid READ getTrackMBID NOTIFY changed )
    Q_PROPERTY(QString albummbid READ getAlbumMBID NOTIFY changed )
    Q_PROPERTY(QString artistmbid READ getArtistMBID NOTIFY changed )
    Q_PROPERTY(QString genre READ getGenre NOTIFY changed )
public:
    explicit MpdTrack(QObject *parent = 0);
    MpdTrack(QObject *parent,QString file,QString mTitle, quint32 mLength);
    MpdTrack(QObject *parent,QString file,QString mTitle, quint32 mLength,bool mPlaying);
    MpdTrack(QObject *parent,QString file,QString mTitle,QString mArtist, QString mAlbum, quint32 mLength);

    QString getName() const;
    QString getTitle() const;
    QString getFileUri() const;
    quint32 getLength() const;
    QString getAlbum() const;
    QString getArtist() const;
    QString getAlbumArtist() const;
    QString getLengthFormated() const;
    QString getYear() const;
    QString getFileName() const;

    int getTrackNr() const;
    int getDiscNr() const;
    int getAlbumTracks() const;

    QString getTrackMBID() const;
    QString getAlbumMBID() const;
    QString getArtistMBID() const;
    QString getGenre() const;

    void setTitle(QString);
    void setFileUri(QString);
    void setLength(quint32 mLength);
    void setAlbum(QString);
    void setArtist(QString);
    void setAlbumArtist(QString);
    void setYear(QString mYear);
    void setTrackNr(int nr);
    void setDiscNr(int nr);
    void setAlbumTracks(int nr);

    void setTrackMBID(QString mbid);
    void setAlbumMBID(QString mbid);
    void setArtistMBID(QString mbid);
    void setGenre(QString mbid);

    bool getPlaying() const;
    void setPlaying(bool mPlaying);

    static bool lessThanTrackNr(const MpdTrack *lhs, const MpdTrack* rhs);
private:
    QString mTitle;
    QString mFileURI;
    quint32 mLength;
    QString mArtist;
    QString mAlbumArtist;
    QString mAlbum;
    int mTrackNR;
    int mDiscNR;
    int mAlbumTracks;
    QString mYear;

    QString mTrackMBID;
    QString mArtistMBID;
    QString mAlbumMBID;
    QString mGenre;

    bool mPlaying;

signals:
    void playingchanged();
    void changed();

public slots:

};

#endif // MPDTRACK_H
