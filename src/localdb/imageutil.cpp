#include <localdb/imageutil.h>

#include <QBuffer>
#include <QImage>
#include <QImageReader>

QByteArray ImageUtil::squareJpeg(const QByteArray &data)
{
    if ( data.isEmpty() ) {
        return QByteArray();
    }
    QByteArray copy(data);
    QBuffer buffer(&copy);
    buffer.open(QIODevice::ReadOnly);
    QImageReader reader(&buffer);
    QSize size = reader.size();
    if ( !size.isValid() ) {
        // Not an image
        return QByteArray();
    }
    reader.setScaledSize(size.scaled(COVER_IMAGE_SIZE,COVER_IMAGE_SIZE,Qt::KeepAspectRatioByExpanding));
    QImage image = reader.read();
    if ( image.isNull() ) {
        return QByteArray();
    }
    image = image.copy((image.width() - COVER_IMAGE_SIZE) / 2,
                       (image.height() - COVER_IMAGE_SIZE) / 2,
                       COVER_IMAGE_SIZE, COVER_IMAGE_SIZE);
    QByteArray scaled;
    QBuffer out(&scaled);
    out.open(QIODevice::WriteOnly);
    image.save(&out,"JPG",90);
    return scaled;
}
