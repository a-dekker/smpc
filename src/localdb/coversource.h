#ifndef COVERSOURCE_H
#define COVERSOURCE_H

#include <QObject>
#include <QAtomicInt>
#include <QByteArray>

#include <mpd/mpdalbum.h>

/**
 * @brief Process wide switchboard between the image downloaders and the
 * NetworkAccess thread for album art stored on the MPD server (cover.jpg and
 * friends, retrieved with the "albumart" command), and holder of the
 * settings which decide where album art may come from.
 */
class CoverSource : public QObject
{
    Q_OBJECT
public:
    static CoverSource *instance();

    bool localEnabled() const { return mLocalEnabled.loadAcquire() != 0; }
    bool lastFmEnabled() const { return mLastFmEnabled.loadAcquire() != 0; }
    /** true if album art can be retrieved from any source */
    bool anyEnabled() const { return localEnabled() || lastFmEnabled(); }

public slots:
    void setLocalEnabled(bool enabled);
    void setLastFmEnabled(bool enabled);

signals:
    /** Ask the MPD connection to look for a cover of the given album */
    void localCoverRequested(MpdAlbum album);
    /** Answer of the MPD connection. Empty data means no cover was found. */
    void localCoverReady(MpdAlbum album, QByteArray data);
    /** Emitted when the local cover setting changed */
    void localEnabledChanged(bool enabled);

private:
    CoverSource();

    QAtomicInt mLocalEnabled;
    QAtomicInt mLastFmEnabled;
};

#endif // COVERSOURCE_H
