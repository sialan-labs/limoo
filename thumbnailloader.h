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

#ifndef THUMBNAILLOADER_H
#define THUMBNAILLOADER_H

#include <QObject>

class ThumbnailLoaderItem;
class ThumbnailLoaderPrivate;
class ThumbnailLoader : public QObject
{
    Q_OBJECT
public:
    ThumbnailLoader(QObject *parent = 0);
    ~ThumbnailLoader();

public slots:
    void load( const QString & path );
    void reset();

signals:
    void loaded( const QString & path, const QString & thumbnail );

private slots:
    void loaded_private( ThumbnailLoaderItem *item, const QString & thumbnail );
    void next();

private:
    ThumbnailLoaderPrivate *p;
};

#endif // THUMBNAILLOADER_H
