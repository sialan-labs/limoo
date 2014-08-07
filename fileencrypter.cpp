/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

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

#define MAX_ENCRYPTER_THREAD 4
#define DECRYPT_IMAGE( DEST_DATA, SOURCE, FILE_PATH ) { \
    const QString & pass = PasswordManager::masterPasswordOf(FILE_PATH); \
    DEST_DATA = EncryptTools::decrypt(SOURCE,pass); \
    }

#include "fileencrypter.h"
#include "limoo_macros.h"
#include "limoo.h"
#include "passwordmanager.h"
#include "encrypttools.h"

#include <QThread>
#include <QQueue>
#include <QStringList>
#include <QImageReader>
#include <QFile>
#include <QCryptographicHash>
#include <QDataStream>
#include <QBuffer>

typedef QPair<QString,bool> FileEncrypterQueueItem;

class FileEncrypterPrivate
{
public:
    QQueue<FileEncrypterCore*> cores;
    QQueue<FileEncrypterQueueItem> queue;
};

FileEncrypter::FileEncrypter(QObject *parent) :
    QObject(parent)
{
    p = new FileEncrypterPrivate;
    init_cores();
}

QSize FileEncrypter::readSize(QString path)
{
    NORMALIZE_PATH(path);

    QString header;
    qreal version;
    QByteArray passHash;
    QSize size;
    QFile file(path);
    if( !file.open(QFile::ReadOnly) )
        return size;

    QDataStream stream(&file);
    stream >> header;       if( header   != ENCRYPTER_HEADER ) return size;
    stream >> version;      if( version   > ENCRYPTER_VERSION ) return size;
    stream >> passHash;
    stream >> size;

    file.close();
    return size;
}

QImage FileEncrypter::readThumbnail(QString path)
{
    NORMALIZE_PATH(path);

    QString header;
    qreal version;
    QByteArray passHash;
    QSize size;
    QImage thumb;
    QFile file(path);
    if( !file.open(QFile::ReadOnly) )
        return thumb;

    QByteArray enc_thumb;

    QDataStream stream(&file);
    stream >> header;       if( header   != ENCRYPTER_HEADER ) return thumb;
    stream >> version;      if( version   > ENCRYPTER_VERSION ) return thumb;
    stream >> passHash;
    stream >> size;
    stream >> enc_thumb;

    QByteArray dest;
    DECRYPT_IMAGE( dest, enc_thumb, path );

    QBuffer buffer(&dest);
    buffer.open(QBuffer::ReadOnly);
    QDataStream ostream(&buffer);
    ostream >> thumb;
    buffer.close();

    file.close();
    return thumb;
}

QImage FileEncrypter::readImage(QString path )
{
    NORMALIZE_PATH(path);

    QString header;
    qreal version;
    QByteArray passHash;
    QSize size;
    QImage img;
    QFile file(path);
    if( !file.open(QFile::ReadOnly) )
        return img;

    QByteArray enc_thumb;
    QByteArray enc_img;

    QDataStream stream(&file);
    stream >> header;       if( header   != ENCRYPTER_HEADER ) return img;
    stream >> version;      if( version   > ENCRYPTER_VERSION ) return img;
    stream >> passHash;
    stream >> size;
    stream >> enc_thumb;
    stream >> enc_img;

    QByteArray dest;
    DECRYPT_IMAGE( dest, enc_img, path );

    img = QImage::fromData(dest);

    file.close();
    return img;
}

void FileEncrypter::decryptAlongside(QString path)
{
    QFileInfo inf(path);
    decryptTo(path, inf.path()+"/"+inf.completeBaseName());
}

void FileEncrypter::decryptTo(QString path, QString dest)
{
    NORMALIZE_PATH(path)
    NORMALIZE_PATH(dest)
    readImage(path).save(dest);
}

void FileEncrypter::encyptFiles(const QStringList &files, bool delete_old_files )
{
    foreach( const QString & file, files )
        encypt(file, delete_old_files);
}

void FileEncrypter::encyptDir(QString path, bool delete_old_files )
{
    NORMALIZE_PATH(path);
    QStringList list = QDir(path).entryList(QStringList()<<"*.jpg" << "*.PNG"
                                            << "*.jpeg" << "*.JPG" << "*.JPEG" << "*.png"
                                            << "*.bmp" << "*.BMP" << ".SVG" << "*.svg"
                                            << "*.SVGZ" << "*.svg", QDir::Files);

    for( int i=0; i<list.count(); i++ )
        list[i] = QFileInfo(path + "/" + list.at(i)).filePath();

    encyptFiles(list,delete_old_files);

    QStringList dirs = QDir(path).entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    for( int i=0; i<dirs.count(); i++ )
        encyptDir( QFileInfo(path + "/" + dirs.at(i)).filePath(), delete_old_files );
}

void FileEncrypter::encypt(QString path, bool delete_old_files)
{
    NORMALIZE_PATH(path);
    QFileInfo inf(path);
    if( inf.isDir() )
    {
        encyptDir(path,delete_old_files);
        return;
    }

    FileEncrypterQueueItem item;
    item.first = path;
    item.second = delete_old_files;

    if( p->queue.isEmpty() && p->cores.count() == MAX_ENCRYPTER_THREAD )
        emit started();

    p->queue << item;
    next();
}

void FileEncrypter::next()
{
    if( p->queue.isEmpty() )
    {
        emit done();
        return;
    }
    if( p->cores.isEmpty() )
        return;
    if( p->queue.isEmpty() )
        return;

    const FileEncrypterQueueItem & item = p->queue.takeFirst();
    FileEncrypterCore *core = p->cores.takeFirst();

    QMetaObject::invokeMethod( core, "encypt", Qt::QueuedConnection, Q_ARG(QString,item.first), Q_ARG(bool,item.second) );
}

void FileEncrypter::done_slt()
{
    FileEncrypterCore *core = static_cast<FileEncrypterCore*>(sender());
    p->cores << core;

    next();
}

void FileEncrypter::init_cores()
{
    for( int i=0; i<MAX_ENCRYPTER_THREAD; i++ )
    {
        FileEncrypterCore *core = new FileEncrypterCore();
        QThread *thread = new QThread();
        core->moveToThread(thread);
        thread->start();

        p->cores << core;

        connect( thread, SIGNAL(finished()), core, SLOT(deleteLater()) );
        connect( core  , SIGNAL(done())    , this, SLOT(done_slt())    , Qt::QueuedConnection );
    }
}

FileEncrypter::~FileEncrypter()
{
    foreach( FileEncrypterCore *core, p->cores )
    {
        QThread *thread = core->thread();
        thread->quit();
        thread->wait();
        thread->deleteLater();
    }

    delete p;
}


void FileEncrypterCore::encypt(QString path, bool delete_old_files)
{
    const QString & masterPass = PasswordManager::masterPasswordOf(path);
    const QString & pass = PasswordManager::passwordOf(path);

    QFileInfo file(path);
    QString opath = file.dir().path() + "/" + file.fileName() + "." PATH_HANDLER_LLOCK_SUFFIX;

    QFile input(path);
    QFile output(opath);

    if( !input.open(QFile::ReadOnly) )
        return;
    if( !output.open(QFile::WriteOnly) )
        return;

    const QByteArray image_data = input.readAll();
    input.close();

    const QImage img = QImage::fromData(image_data);
    const QImage thumb = img.scaled( QSize(256,256), Qt::KeepAspectRatio, Qt::SmoothTransformation );

    QByteArray thumb_data;
    QBuffer thumb_buffer(&thumb_data);
    thumb_buffer.open(QBuffer::WriteOnly);
    QDataStream thumb_stream(&thumb_buffer);
    thumb_stream << thumb;
    thumb_buffer.close();

    const QByteArray & enc_img_data = EncryptTools::encrypt(image_data,masterPass);
    const QByteArray & enc_thumb_data = EncryptTools::encrypt(thumb_data,masterPass);

    QDataStream stream(&output);
    stream << ENCRYPTER_HEADER;
    stream << ENCRYPTER_VERSION;
    stream << QCryptographicHash::hash(pass.toUtf8(),QCryptographicHash::Md5).toHex();
    stream << img.size();
    stream << enc_thumb_data;
    stream << enc_img_data;

    output.flush();
    output.close();

    if( delete_old_files )
        input.remove();

    emit done();
}
