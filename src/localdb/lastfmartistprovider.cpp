#include <localdb/lastfmartistprovider.h>

LastFMArtistProvider::LastFMArtistProvider(QString artistName,QObject *parent) : QObject(parent) {
    mArtistName = artistName;

    mXMLNetAccess = 0;
    mArtistArtAccess = 0;
    mDeezerNetAccess = 0;
    mImageData = 0;
    mImageURL = "";
    mArtistInfo = "";
    mLastInformation = 0;
    mDownloadSize = LASTFMDEFAULTSIZE;
}

LastFMArtistProvider::~LastFMArtistProvider() {
    if ( mXMLNetAccess ) {
        disconnect(mXMLNetAccess);
        mXMLNetAccess->deleteLater();
        mXMLNetAccess = 0;
    }
    if ( mArtistArtAccess ) {
        disconnect(mArtistArtAccess);
        mArtistArtAccess->deleteLater();
        mArtistArtAccess = 0;
    }
    if ( mDeezerNetAccess ) {
        disconnect(mDeezerNetAccess);
        mDeezerNetAccess->deleteLater();
        mDeezerNetAccess = 0;
    }
    if ( mLastInformation ) {
        delete ( mLastInformation );
    }
}


void LastFMArtistProvider::downloadImageData(QUrl imageURL) {
    if(!mArtistArtAccess)
    {
        mArtistArtAccess = new QNetworkAccessManager();
        connect(mArtistArtAccess,SIGNAL(finished(QNetworkReply*)),this,SLOT(imageDownloaded(QNetworkReply*)));
    }
    QNetworkRequest downloadRequest(imageURL);
    mArtistArtAccess->get(downloadRequest);
}

void LastFMArtistProvider::xmlDownloaded(QNetworkReply *reply) {
    // Last.fm only provides the biography, the image comes from Deezer.
    // A missing biography must not prevent getting the image.
    QByteArray data = reply->readAll();
    reply->deleteLater();
    // qDebug() << "XML received";

    // netaccess not needed anymore
    //    delete(mXMLNetAccess);
    //    mXMLNetAccess = 0;

    //    QString outString(data);

    QXmlStreamReader xmlReader(data);
    bool firstArtistparsed = false;
    while ( !xmlReader.atEnd() ) {
        QXmlStreamReader::TokenType token = xmlReader.readNext();
        if ( token == QXmlStreamReader::StartDocument) {
            // nothing important, skip
            continue;
        }
        else if ( token == QXmlStreamReader::StartElement ) {
            // Found some data
            if ( xmlReader.name() == "lfm" ) {
                continue;
            }

            if ( xmlReader.name() == "artist" && !firstArtistparsed ) {
                parseArtist(xmlReader);
                firstArtistparsed = true;
            }
        }
    }
    searchArtistImage();
}

void LastFMArtistProvider::searchArtistImage() {
    QUrl requestURL("https://api.deezer.com/search/artist");
    QUrlQuery query;
    query.addQueryItem("q", mArtistName);
    query.addQueryItem("limit", "5");
    requestURL.setQuery(query);

    if( !mDeezerNetAccess )
    {
        mDeezerNetAccess = new QNetworkAccessManager(this);
        connect(mDeezerNetAccess,SIGNAL(finished(QNetworkReply*)),this,SLOT(deezerSearchDone(QNetworkReply*)));
    }
    mDeezerNetAccess->get(QNetworkRequest(requestURL));
}

void LastFMArtistProvider::deezerSearchDone(QNetworkReply *reply) {
    QByteArray data = reply->readAll();
    bool networkError = reply->error() != QNetworkReply::NoError;
    reply->deleteLater();
    if ( networkError ) {
        emit failed();
        return;
    }

    // Only accept an exact name match, a wrong picture is worse than none
    mImageURL = "";
    QJsonArray results = QJsonDocument::fromJson(data).object().value("data").toArray();
    for ( int i = 0; i < results.size(); i++ ) {
        QJsonObject artist = results.at(i).toObject();
        if ( artist.value("name").toString().compare(mArtistName, Qt::CaseInsensitive) != 0 ) {
            continue;
        }
        QString url = artist.value("picture_xl").toString();
        // Artists without a picture get a url with an empty image id
        if ( !url.isEmpty() && !url.contains("/artist//") ) {
            mImageURL = url;
            break;
        }
    }

    if ( mImageURL != "" ) {
        downloadImageData(mImageURL);
    } else {
        if ( mLastInformation ) {
            delete mLastInformation;
            mLastInformation = 0;
        }
        mLastInformation = new ArtistInformation(mArtistName,mArtistInfo,mImageURL,0,this);
        emit ready(getLastInformation());
    }
}

void LastFMArtistProvider::parseArtist(QXmlStreamReader &xmlReader) {
    // Security check
    if ( ( xmlReader.tokenType() != QXmlStreamReader::StartElement &&
           xmlReader.name() == "artist" )) {
        return;
    }

    while ( !(xmlReader.tokenType() == QXmlStreamReader::EndElement && xmlReader.name() == "artist") ) {
        if (xmlReader.tokenType() == QXmlStreamReader::Invalid) {
            return;
        }
        if ( xmlReader.tokenType() == QXmlStreamReader::StartElement &&
             xmlReader.name() == "bio" ) {
            parseWikiInformation(xmlReader);
        }


        xmlReader.readNext();
        // Skip similar artists
        if( xmlReader.tokenType() == QXmlStreamReader::StartElement && xmlReader.name() == "similar")
        {
            while ( !(xmlReader.tokenType() == QXmlStreamReader::EndElement && xmlReader.name() == "similar") )
            {
                xmlReader.readNext();
            }
        }
    }

}

void LastFMArtistProvider::parseWikiInformation(QXmlStreamReader &xmlReader) {
    // Security check
    // qDebug() << "Found wiki information";
    if ( ( xmlReader.tokenType() != QXmlStreamReader::StartElement &&
           xmlReader.name() == "bio" )) {
        return;
    }

    while ( !(xmlReader.tokenType() == QXmlStreamReader::EndElement && xmlReader.name() == "bio") ) {
        if ( xmlReader.tokenType() == QXmlStreamReader::StartElement &&
             xmlReader.name() == "content") {
            while ( !(xmlReader.tokenType() == QXmlStreamReader::EndElement && xmlReader.name() == "content") )  {
                if (xmlReader.tokenType() == QXmlStreamReader::Invalid) {
                    return;
                }
                if ( xmlReader.tokenType() == QXmlStreamReader::Characters ) {
                    // qDebug() << "Reached content block";
                    mArtistInfo.append(xmlReader.text().toString());
                    // qDebug() << mArtistInfo;
                }
                xmlReader.readNext();
            }
        }
        xmlReader.readNext();
    }

}

void LastFMArtistProvider::startDownload() {
    // Get last.fm artist info

    QString artistNameClean = mArtistName;
    artistNameClean.replace('#',"%23");
    artistNameClean = artistNameClean.replace('&',"%26");
    artistNameClean = artistNameClean.replace('+',"%2B");
    artistNameClean = artistNameClean.replace(' ',"+");


    QString lastfmXMLURL = QString("http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&api_key=")
            + LASTFMAPIKEY + QString("&artist=") + artistNameClean;
    QUrl requestURL(lastfmXMLURL);
    // qDebug() << "Start downloading artist: " << requestURL.toString();

    QNetworkRequest downloadRequest(requestURL);
    if( !mXMLNetAccess )
    {
        mXMLNetAccess = new QNetworkAccessManager(this);
        connect(mXMLNetAccess,SIGNAL(finished(QNetworkReply*)),this,SLOT(xmlDownloaded(QNetworkReply*)));
        if( !mXMLNetAccess->networkAccessible()) {
        }
        else {
        }
    }

    mXMLNetAccess->get(downloadRequest);
    // qDebug() << "Netreply get send";
}

void LastFMArtistProvider::imageDownloaded(QNetworkReply *reply) {
    QByteArray *imgData = new QByteArray(reply->readAll());
    if(imgData->size() == 0) {
        emit failed();
        return;
    }
    // qDebug() << "Artwork downloaded" << mArtistName;
    if ( mLastInformation ) {
        delete ( mLastInformation );
        mLastInformation = 0;
    }
    mLastInformation = new ArtistInformation(mArtistName,mArtistInfo,mImageURL,imgData,this);
    emit ready(getLastInformation());
}

QString LastFMArtistProvider::getImageURL() {
    return "";
}

ArtistInformation *LastFMArtistProvider::getLastInformation()
{
    return new ArtistInformation(*mLastInformation);
}

void LastFMArtistProvider::setArtist(QString artist)
{
    mArtistName = artist;
}

void LastFMArtistProvider::requestDownload(MpdArtist artist)
{
    mArtistName = artist.getName();
    // qDebug() << "Download requested: " << mArtistName;
    if ( mImageData ) {
        delete (mImageData);
        mImageData = 0;
    }
    if ( mImageURL != "" ) {
        mImageURL = "";
    }
    if ( mArtistInfo != "" ) {
        mArtistInfo = "";
    }
    startDownload();
}

void LastFMArtistProvider::setDownloadSize(QString size)
{
    mDownloadSize = size;
}
