#include <localdb/artistinfoprovider.h>
#include <localdb/imageutil.h>

// Minimum time between two requests to Wikipedia
#define WIKIPEDIA_INTERVAL 1000
// How often a request refused by Wikipedia is repeated, and the wait if it did not say how long
#define WIKIPEDIA_MAXRETRIES 3
#define WIKIPEDIA_DEFAULTWAIT 30

ArtistInfoProvider::ArtistInfoProvider(QString artistName,QObject *parent) : QObject(parent) {
    mArtistName = artistName;

    mNetAccess = 0;
    mImageURL = "";
    mArtistInfo = "";
    mLastInformation = 0;
    mStage = StageWikipedia;
    mMode = ModeBoth;
    mWikipediaRetries = 0;
}

ArtistInfoProvider::~ArtistInfoProvider() {
    if ( mNetAccess ) {
        disconnect(mNetAccess);
        mNetAccess->deleteLater();
        mNetAccess = 0;
    }
    if ( mLastInformation ) {
        delete ( mLastInformation );
    }
}

void ArtistInfoProvider::request(Stage stage, const QUrl &url) {
    if ( !mNetAccess ) {
        mNetAccess = new QNetworkAccessManager(this);
        connect(mNetAccess,SIGNAL(finished(QNetworkReply*)),this,SLOT(replyFinished(QNetworkReply*)));
    }
    mStage = stage;
    QNetworkRequest downloadRequest(url);
    // Wikipedia requires an identifying user agent
    downloadRequest.setHeader(QNetworkRequest::UserAgentHeader,"harbour-smpc (Sailfish MPD client)");
    mNetAccess->get(downloadRequest);
}

void ArtistInfoProvider::replyFinished(QNetworkReply *reply) {
    QByteArray data = reply->readAll();
    bool networkError = reply->error() != QNetworkReply::NoError;
    reply->deleteLater();

    switch ( mStage ) {
    case StageWikipedia: {
        // Wikipedia answers too many requests with 429 (or 503) and says how long to wait
        int httpStatus = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        if ( (httpStatus == 429 || httpStatus == 503) && mWikipediaRetries < WIKIPEDIA_MAXRETRIES ) {
            mWikipediaRetries++;
            int wait = reply->rawHeader("Retry-After").toInt();
            if ( wait <= 0 ) {
                wait = WIKIPEDIA_DEFAULTWAIT;
            }
            sendWikipediaRequest(qMin(wait, 120) * 1000);
            break;
        }
        // Biography is optional, continue on errors
        wikipediaDone(networkError ? QByteArray() : data);
        break;
    }
    case StageDeezer:
        if ( networkError ) {
            emit failed();
            return;
        }
        deezerDone(data);
        break;
    case StageImage: {
        QByteArray image = networkError ? QByteArray() : ImageUtil::squareJpeg(data);
        if ( image.isEmpty() ) {
            emit failed();
            return;
        }
        finish(new QByteArray(image));
        break;
    }
    }
}

// Words which show that a Wikipedia page is about a musical act
static const char *musicWords[] = { "band", "musician", "singer", "rapper", "group",
    "duo", "trio", "composer", "dj", "producer", "songwriter", "vocalist",
    "guitarist", "pianist", "orchestra", "ensemble", "rock", "hip hop", "pop" };

static const char *titleSuffixes[] = { " (band)", " (musician)", " (singer)",
    " (rapper)", " (group)", " (duo)", "" };

void ArtistInfoProvider::searchWikipedia() {
    // Ask for the page of the artist itself instead of searching, a search
    // ranks band members and albums above the page of the band.
    QString name = mArtistName;
    name.replace('|', ' ');
    QStringList titles;
    for ( unsigned int i = 0; i < sizeof(titleSuffixes) / sizeof(titleSuffixes[0]); i++ ) {
        titles.append(name + titleSuffixes[i]);
    }

    QUrl requestURL("https://en.wikipedia.org/w/api.php");
    QUrlQuery query;
    query.addQueryItem("action", "query");
    query.addQueryItem("format", "json");
    query.addQueryItem("redirects", "1");
    query.addQueryItem("titles", titles.join(QString("|")));
    query.addQueryItem("prop", "extracts|pageprops");
    query.addQueryItem("ppprop", "disambiguation");
    query.addQueryItem("exintro", "1");
    query.addQueryItem("explaintext", "1");
    query.addQueryItem("exlimit", "max");
    requestURL.setQuery(query);
    mWikipediaUrl = requestURL;
    mWikipediaRetries = 0;
    sendWikipediaRequest(0);
}

void ArtistInfoProvider::sendWikipediaRequest(int delayMs) {
    // Keep a distance to the previous request
    if ( mLastWikipediaRequest.isValid() ) {
        delayMs = qMax(delayMs, WIKIPEDIA_INTERVAL - (int)qMin(mLastWikipediaRequest.elapsed(), (qint64)WIKIPEDIA_INTERVAL));
    }
    mStage = StageWikipedia;
    QTimer::singleShot(delayMs, this, SLOT(doWikipediaRequest()));
}

void ArtistInfoProvider::doWikipediaRequest() {
    mLastWikipediaRequest.start();
    request(StageWikipedia, mWikipediaUrl);
}

void ArtistInfoProvider::wikipediaDone(const QByteArray &data) {
    QJsonObject result = QJsonDocument::fromJson(data).object().value("query").toObject();

    // Follow title normalisation and redirects of the requested titles
    QHash<QString, QString> renamed;
    foreach ( QJsonValue value, result.value("normalized").toArray() ) {
        renamed.insert(value.toObject().value("from").toString(), value.toObject().value("to").toString());
    }
    QHash<QString, QString> redirected;
    foreach ( QJsonValue value, result.value("redirects").toArray() ) {
        redirected.insert(value.toObject().value("from").toString(), value.toObject().value("to").toString());
    }
    QHash<QString, QJsonObject> pages;
    foreach ( QJsonValue value, result.value("pages").toObject() ) {
        pages.insert(value.toObject().value("title").toString(), value.toObject());
    }

    QString name = mArtistName;
    name.replace('|', ' ');
    for ( unsigned int i = 0; i < sizeof(titleSuffixes) / sizeof(titleSuffixes[0]); i++ ) {
        QString title = name + titleSuffixes[i];
        title = renamed.value(title, title);
        title = redirected.value(title, title);
        if ( !pages.contains(title) ) {
            continue;
        }
        QJsonObject page = pages.value(title);
        // Skip missing pages, disambiguation pages and redirects to unrelated pages
        if ( page.contains("missing") || page.value("pageprops").toObject().contains("disambiguation") ||
             !title.contains(name, Qt::CaseInsensitive) ) {
            continue;
        }
        QString extract = page.value("extract").toString().trimmed();
        if ( extract.isEmpty() ) {
            continue;
        }
        // A page without qualifier in the title might be about anything
        if ( titleSuffixes[i][0] == '\0' ) {
            bool aboutMusic = false;
            QString start = extract.left(400).toLower();
            for ( unsigned int w = 0; w < sizeof(musicWords) / sizeof(musicWords[0]); w++ ) {
                if ( start.contains(musicWords[w]) ) {
                    aboutMusic = true;
                    break;
                }
            }
            if ( !aboutMusic ) {
                continue;
            }
        }
        mArtistInfo = extract;
        break;
    }
    searchImageOrFinish();
}

void ArtistInfoProvider::searchImageOrFinish() {
    if ( mMode == ModeInfoOnly ) {
        finish(0);
    } else {
        searchDeezer();
    }
}

void ArtistInfoProvider::searchDeezer() {
    QUrl requestURL("https://api.deezer.com/search/artist");
    QUrlQuery query;
    query.addQueryItem("q", mArtistName);
    query.addQueryItem("limit", "5");
    requestURL.setQuery(query);
    request(StageDeezer, requestURL);
}

void ArtistInfoProvider::deezerDone(const QByteArray &data) {
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
        request(StageImage, QUrl(mImageURL));
    } else {
        finish(0);
    }
}

void ArtistInfoProvider::finish(QByteArray *imgData) {
    if ( mLastInformation ) {
        delete mLastInformation;
        mLastInformation = 0;
    }
    mLastInformation = new ArtistInformation(mArtistName,mArtistInfo,mImageURL,imgData,this);
    mLastInformation->setFetched(mMode != ModeImageOnly, mMode != ModeInfoOnly);
    emit ready(getLastInformation());
}

ArtistInformation *ArtistInfoProvider::getLastInformation()
{
    return new ArtistInformation(*mLastInformation);
}

void ArtistInfoProvider::setArtist(QString artist)
{
    mArtistName = artist;
}

void ArtistInfoProvider::requestDownload(MpdArtist artist, int mode)
{
    mArtistName = artist.getName();
    mMode = mode;
    mImageURL = "";
    mArtistInfo = "";
    if ( mMode == ModeImageOnly ) {
        searchDeezer();
    } else {
        searchWikipedia();
    }
}
