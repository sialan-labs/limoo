/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Limoo is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Limoo is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "imagemetadata.h"

#ifndef Q_OS_ANDROID
#include <exiv2/image.hpp>
#endif

#include <QFileInfo>
#include <QImageReader>
#include <QDebug>
#include <QSet>
#include <QHash>

typedef QPair<ImageMetaData::Orientation,ImageMetaData::Mirror> OriMirror;
QHash<int,OriMirror> oriHash()
{
    static QHash<int,OriMirror> res;
    if( !res.isEmpty() )
        return res;

    res[1].first  = ImageMetaData::Normal;
    res[1].second = ImageMetaData::NoMirror;

    res[2].first  = ImageMetaData::Normal;
    res[2].second = ImageMetaData::Mirrored;

    res[3].first  = ImageMetaData::Full;
    res[3].second = ImageMetaData::NoMirror;

    res[4].first  = ImageMetaData::Full;
    res[4].second = ImageMetaData::Mirrored;

    res[5].first  = ImageMetaData::Right;
    res[5].second = ImageMetaData::Mirrored;

    res[6].first  = ImageMetaData::Left;
    res[6].second = ImageMetaData::NoMirror;

    res[7].first  = ImageMetaData::Left;
    res[7].second = ImageMetaData::Mirrored;

    res[8].first  = ImageMetaData::Right;
    res[8].second = ImageMetaData::NoMirror;

    return res;
}

QSet<ImageMetaData*> image_mdata_objs;

class ImageMetaDataPrivate
{
public:
    int ori_exiv;
    QString source;
    QString nsource;
};

ImageMetaData::ImageMetaData(QObject *parent) :
    QObject(parent)
{
    p = new ImageMetaDataPrivate;
    p->ori_exiv = 1;
    image_mdata_objs.insert(this);
}

bool ImageMetaData::init_exif()
{
    p->ori_exiv = 1;

    QFileInfo file( p->nsource );
    if( !file.exists() )
        return false;

    QImageReader image( p->nsource );
    if( !image.canRead() )
        return false;
    if( image.format() ==  "svgz" || image.format() == "svg" )
        return false;
    if( image.size().width() <= 0 || image.size().height() <= 0 )
        return false;

    Exiv2::Image::AutoPtr exiv = Exiv2::ImageFactory::open( p->nsource.toUtf8().constData() );
        exiv->readMetadata();

    Exiv2::ExifData data = exiv->exifData();
    for(Exiv2::ExifData::const_iterator i = data.begin();i != data.end();++i)
    {
        if( i->key() == "Exif.Image.Orientation" )
            p->ori_exiv = i->value().toLong();
    }

    emit orientationChanged();
    return true;
}

void ImageMetaData::refresh()
{
    init_exif();
}

bool ImageMetaData::setOriExif(int ori)
{
    QFileInfo file( p->nsource );
    if( !file.isWritable() )
        return false;
    if( ori == p->ori_exiv )
        return false;

    Exiv2::Image::AutoPtr image = Exiv2::ImageFactory::open( p->nsource.toUtf8().constData() );
        image->readMetadata();

    Exiv2::ExifData & exifData = image->exifData();
    if (exifData.empty()) {
        exifData["Exif.Image.Orientation"] = uint16_t(1);
        qDebug() << "Orientation added to Exif Data";
    }

    Exiv2::ExifKey key = Exiv2::ExifKey("Exif.Image.Orientation");
    Exiv2::ExifData::iterator pos = exifData.findKey(key);
    if (pos == exifData.end() || pos->count() == 0) {
        exifData["Exif.Image.Orientation"] = uint16_t(1);
        pos = exifData.findKey(key);
        qDebug() << "Orientation added to Exif Data";
    }

    Exiv2::Value::AutoPtr v = pos->getValue();
    Exiv2::UShortValue* prv = dynamic_cast<Exiv2::UShortValue*>(v.release());
    Exiv2::UShortValue::AutoPtr rv = Exiv2::UShortValue::AutoPtr(prv);

    rv->value_[0] = (unsigned short)ori;
    pos->setValue(rv.get());

    image->setExifData(exifData);
    image->writeMetadata();

    p->ori_exiv = ori;
    return true;
}

int ImageMetaData::oriExif() const
{
    return p->ori_exiv;
}

void ImageMetaData::setSource(const QString &src)
{
    if( p->source == src )
        return;

    p->source = src;

    p->nsource = src;
    if( p->nsource.left(7) == "file://" ) \
        p->nsource = p->nsource.mid(7);

    refresh();

    emit sourceChanged();
}

QString ImageMetaData::source() const
{
    return p->source;
}

void ImageMetaData::setOrientation(int ori)
{
    int mr = oriHash().value(p->ori_exiv).second;
    OriMirror om(static_cast<ImageMetaData::Orientation>(ori) ,static_cast<ImageMetaData::Mirror>(mr) );
    int ori_exif = oriHash().key(om);
    if( !setOriExif(ori_exif) )
        return;

    emit orientationChanged();
}

int ImageMetaData::orientation() const
{
    return oriHash().value(p->ori_exiv).first;
}

void ImageMetaData::setMirror(int mr)
{
    int ori = oriHash().value(p->ori_exiv).first;
    OriMirror om(static_cast<ImageMetaData::Orientation>(ori) ,static_cast<ImageMetaData::Mirror>(mr) );
    int ori_exif = oriHash().key(om);
    if( !setOriExif(ori_exif) )
        return;

    emit mirrorChanged();
}

int ImageMetaData::mirror() const
{
    return oriHash().value(p->ori_exiv).second;
}

ImageMetaData::~ImageMetaData()
{
    image_mdata_objs.remove(this);
    delete p;
}
