#ifndef FILEMODEL_H
#define FILEMODEL_H

#include <QAbstractListModel>
#include <QQmlEngine>

#include <mpd/mpdfileentry.h>
#include <localdb/imagedatabase.h>

#define DUMMY_ALBUMIMAGE "image://theme/icon-l-music"

class FileModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount)
public:
    explicit FileModel(QObject *parent = 0);
    ~FileModel();

    FileModel(QList<MpdFileEntry*>* list,ImageDatabase *db,QObject *parent = 0);

    Q_INVOKABLE MpdFileEntry* get(int index);
    Q_INVOKABLE int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role) const;
    Q_INVOKABLE QHash<int, QByteArray> roleNames() const;

    enum EntryRoles {
        NameRole = Qt::UserRole + 1,
        SectionRole,
        isDirectoryRole,
        isFileRole,
        isPlaylistRole,
        prePathRole,
        pathRole,
        titleRole,
        artistRole,
        albumRole,
        lengthRole,
        tracknoRole,
        yearRole,
        imageURLRole,
        trackmbidRole,
        albummbidRole,
        artistmbidRole,
        genreRole,
        discoNoRole
    };

private:
    QList<MpdFileEntry*>* mEntries;
    ImageDatabase *mDB;

signals:

};

#endif // FILEMODEL_H
