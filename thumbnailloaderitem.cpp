/*
    Copyright (C) 2014 Aseman
    http://aseman.co

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

#include "thumbnailloaderitem.h"

#include <QImageReader>
#include <QImageWriter>
#include <QFileInfo>
#include <QMutex>
#include <QString>
#include <QSize>

class ThumbnailLoaderItemPrivate
{
public:
    QString path;
    QString thumbnail;
};

ThumbnailLoaderItem::ThumbnailLoaderItem(QObject *parent) :
    QThread(parent)
{
    p = new ThumbnailLoaderItemPrivate;

    connect( this, SIGNAL(finished()), SLOT(finished_prev()), Qt::QueuedConnection );
}

void ThumbnailLoaderItem::start(const QString &path, const QString & thumb)
{
    p->path = path;
    p->thumbnail = thumb;

    QThread::start();
}

void ThumbnailLoaderItem::finished_prev()
{
    emit completed( this, p->thumbnail );
}

void ThumbnailLoaderItem::run()
{
    QImageReader reader( p->path );
    const QSize & image_size = reader.size();
    qreal image_size_ratio = (qreal)image_size.width() / image_size.height();

    QSize read_size;
    if( image_size_ratio > 1 )
    {
        read_size.setWidth( 256 );
        read_size.setHeight( 256 / image_size_ratio );
    }
    else
    {
        read_size.setHeight( 256 );
        read_size.setWidth( 256 * image_size_ratio );
    }

    reader.setScaledSize( read_size );

    const QImage & image = reader.read();
    QImageWriter writer( p->thumbnail );
    writer.write( image );
}

ThumbnailLoaderItem::~ThumbnailLoaderItem()
{
    delete p;
}
