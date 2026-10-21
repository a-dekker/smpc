#ifndef IMAGEUTIL_H
#define IMAGEUTIL_H

#include <QByteArray>

// Width and height of album and artist images before they are cached
#define COVER_IMAGE_SIZE 500

namespace ImageUtil {

/**
 * @brief Scales an image so it fills a square of COVER_IMAGE_SIZE, cropping
 * the overhang of non square images evenly, and encodes it as JPEG.
 * @return the new image, empty if data is not a readable image
 */
QByteArray squareJpeg(const QByteArray &data);

}

#endif // IMAGEUTIL_H
