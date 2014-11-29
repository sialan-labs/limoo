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

#ifndef THUMBNAILLOADERITEM_H
#define THUMBNAILLOADERITEM_H

#include <QThread>

class ThumbnailLoaderItemPrivate;
class ThumbnailLoaderItem : public QThread
{
    Q_OBJECT
public:
    ThumbnailLoaderItem(QObject *parent = 0);
    ~ThumbnailLoaderItem();

public slots:
    void start(const QString & file , const QString &thumb);

signals:
    void completed( ThumbnailLoaderItem *item, const QString & path );
    void finished( ThumbnailLoaderItem *item );

private slots:
    void finished_prev();

protected:
    void run();

private:
    ThumbnailLoaderItemPrivate *p;
};

#endif // THUMBNAILLOADERITEM_H
