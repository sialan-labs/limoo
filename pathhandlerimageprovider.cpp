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

#include "pathhandlerimageprovider.h"
#include "pathhandler.h"
#include "passwordmanager.h"
#include "fileencrypter.h"

PathHandlerImageProvider::PathHandlerImageProvider() :
    QQuickImageProvider(QQuickImageProvider::Image,QQmlImageProviderBase::ForceAsynchronousImageLoading)
{
}

QImage PathHandlerImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    QImage result;

    const QStringList & parts = id.split("/",QString::SkipEmptyParts);
    if( parts.count() != 2 )
        return result;

    const QString & type = parts.at(0);
    const quint64 pid = parts.at(1).toULongLong();
    const QString & path = PathHandler::readPathOf(pid);
    QFileInfo inf(path);

    if( type == PATH_HANDLER_LLOCK )
    {
        result = FileEncrypter::readImage(path);
        result = result.scaled(requestedSize,Qt::KeepAspectRatio, Qt::SmoothTransformation);
    }
    else
    if( type == PATH_HANDLER_LLOCK_THUMB )
    {
        QString fpath = inf.path() + "/" + inf.completeBaseName() + "." + PATH_HANDLER_LLOCK_SUFFIX;
        result = FileEncrypter::readThumbnail(fpath);
        if( result.isNull() )
            result = QImage(QCoreApplication::applicationDirPath()+"/qml/Limoo/files/locked-file.png");
        result = result.scaled(requestedSize,Qt::KeepAspectRatio, Qt::SmoothTransformation);
    }

    if (size)
        *size = QSize(result.width(), result.height());

    return result;
}

PathHandlerImageProvider::~PathHandlerImageProvider()
{
}
