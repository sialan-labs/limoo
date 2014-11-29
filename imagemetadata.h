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

#ifndef IMAGEMETADATA_H
#define IMAGEMETADATA_H

#include <QObject>

class ImageMetaDataPrivate;
class ImageMetaData : public QObject
{
    Q_PROPERTY(int orientation READ orientation WRITE setOrientation NOTIFY orientationChanged)
    Q_PROPERTY(int mirror READ mirror WRITE setMirror NOTIFY mirrorChanged)
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)

    Q_ENUMS(Orientation)
    Q_ENUMS(Mirror)

    Q_OBJECT
public:
    enum Orientation {
        Normal,
        Right,
        Left,
        Full
    };

    enum Mirror {
        NoMirror,
        Mirrored
    };

    ImageMetaData(QObject *parent = 0);
    ~ImageMetaData();

    void setSource( const QString & src );
    QString source() const;

    void setOrientation( int ori );
    int orientation() const;

    void setMirror( int mr );
    int mirror() const;

signals:
    void orientationChanged();
    void mirrorChanged();
    void sourceChanged();

private:
    bool init_exif();
    void refresh();

    bool setOriExif( int ori );
    int oriExif() const;

private:
    ImageMetaDataPrivate *p;
};

#endif // IMAGEMETADATA_H
