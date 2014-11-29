/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef FILEENCRYPTER_H
#define FILEENCRYPTER_H

#include <QObject>
#include <QStringList>
#include <QSize>
#include <QImage>

class FileEncrypterPrivate;
class FileEncrypter : public QObject
{
    Q_OBJECT
public:
    FileEncrypter(QObject *parent = 0);
    ~FileEncrypter();

public slots:
    static QSize readSize( QString path );
    static QByteArray readPassHash( QString path );
    static QImage readThumbnail( QString path );
    static QImage readImage( QString path );
    static void decryptTo(QString path, QString dest);
    static void decryptAlongside(QString path);

    void encyptFiles(const QStringList &files, bool delete_old_files = false );
    void encyptDir( QString path, bool delete_old_files = false );
    void encypt(QString path, bool delete_old_files = false );

signals:
    void started();
    void done();

private slots:
    void next();
    void done_slt();

private:
    void init_cores();

private:
    FileEncrypterPrivate *p;
};

class FileEncrypterCore : public QObject
{
    Q_OBJECT
public:
    FileEncrypterCore(){}
    ~FileEncrypterCore(){}

public slots:
    void encypt(QString path, bool delete_old_files);

signals:
    void done();
};

#endif // FILEENCRYPTER_H
