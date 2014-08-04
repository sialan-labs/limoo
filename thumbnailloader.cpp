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

#define THUMBNAILS_PATH QDir::homePath() + "/.thumbnails/limoo"
#define CACHE_COUNT 10

#include "thumbnailloader.h"
#include "thumbnailloaderitem.h"

#include <QSet>
#include <QQueue>
#include <QHash>
#include <QTimerEvent>
#include <QDebug>
#include <QFileInfo>
#include <QCryptographicHash>
#include <QMimeDatabase>
#include <QDateTime>
#include <QDir>

typedef QPair<QString,QString> QueueItem;

class ThumbnailLoaderPrivate
{
public:
    QSet<ThumbnailLoaderItem*> items;
    QList<ThumbnailLoaderItem*> inactiveItems;

    QQueue<QueueItem> queue;
    QMimeDatabase db;

    QHash<ThumbnailLoaderItem*,QString> paths;
};

ThumbnailLoader::ThumbnailLoader(QObject *parent) :
    QObject(parent)
{
    p = new ThumbnailLoaderPrivate;
    QDir().mkpath(THUMBNAILS_PATH);

    reset();
}

void ThumbnailLoader::load(const QString &path)
{
    QFileInfo file( path );

    QString suffix = p->db.mimeTypeForFile(path).preferredSuffix();
    if( suffix == "svg" || suffix == "svgz" )
    {
        emit loaded( path, file.filePath() );
        return;
    }

    QString hidden_text = file.path() + " " +
                          QString::number(file.size()) +  " " +
                          file.created().toString("yyyy/MM/dd hh:mm:ss:zzz") + " " +
                          file.lastModified().toString("yyyy/MM/dd hh:mm:ss:zzz");
    QString md5 = QCryptographicHash::hash(hidden_text.toStdString().c_str(),QCryptographicHash::Md5).toHex();
    QString thumbnail = THUMBNAILS_PATH + "/" + md5 + "." + suffix;

    if( QFileInfo(thumbnail).exists() )
    {
        emit loaded( path, thumbnail );
        return;
    }

    const QueueItem item = QueueItem(path,thumbnail);
    if( p->queue.contains(item) ) {
        p->queue.prepend( p->queue.takeAt(p->queue.indexOf(item)) );
        return;
    }

    p->queue.append( item );
    next();
}

void ThumbnailLoader::reset()
{
    foreach( ThumbnailLoaderItem *item, p->items ) {
        disconnect( item, SIGNAL(completed(ThumbnailLoaderItem*,QString)), this, SLOT(loaded_private(ThumbnailLoaderItem*,QString)) );
        connect( item, SIGNAL(finished()), item, SLOT(deleteLater()), Qt::QueuedConnection );
        if( item->isFinished() )
            item->deleteLater();
    }

    p->items.clear();
    p->queue.clear();
    p->inactiveItems.clear();
    p->paths.clear();

    for( int i=0; i<CACHE_COUNT; i++ )
    {
        ThumbnailLoaderItem *item = new ThumbnailLoaderItem(this);
        p->items.insert( item );
        p->inactiveItems.append( item );
        connect( item, SIGNAL(completed(ThumbnailLoaderItem*,QString)), this, SLOT(loaded_private(ThumbnailLoaderItem*,QString)) );
    }
}

void ThumbnailLoader::next()
{
    if( p->inactiveItems.isEmpty() )
        return;
    if( p->queue.isEmpty() )
        return;

    const QueueItem & path = p->queue.takeFirst();

    ThumbnailLoaderItem *item = p->inactiveItems.takeFirst();

    p->paths.insert(item,path.first);

    item->start( path.first, path.second );
}

void ThumbnailLoader::loaded_private(ThumbnailLoaderItem *item, const QString &thumbnail)
{
    if( !p->items.contains(item) )
        return;

    p->inactiveItems.append(item);

    const QString path = p->paths.value(item);
    p->paths.remove(item);

    emit loaded( path, thumbnail );
    next();
}

ThumbnailLoader::~ThumbnailLoader()
{
    delete p;
}
