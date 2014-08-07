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

#include "pathhandler.h"
#include "limoo_macros.h"

#include <QHash>
#include <QMutex>
#include <QFileInfo>
#include <QMimeDatabase>

QHash<quint64,QString> path_handler_inputs;
QHash<quint64,QByteArray> path_handler_datas;
quint64 path_handler_unique_id = 0;
QMutex path_handler_mutex;

class PathHandlerPrivate
{
public:
    QString input;
    QString output;

    QThread *thread;
    quint64 id;
};

PathHandler::PathHandler(QObject *parent) :
    QObject(parent)
{
    p = new PathHandlerPrivate;

    path_handler_mutex.lock();
    p->id = path_handler_unique_id;
    path_handler_unique_id++;
    path_handler_mutex.unlock();
}

void PathHandler::setInput(QString input)
{
    NORMALIZE_PATH(input)
    if( p->input == input )
        return;

    p->input = input;
    path_handler_mutex.lock();
    path_handler_inputs[p->id] = p->input;
    path_handler_mutex.unlock();

    emit inputChanged();
    refresh_output();
}

QString PathHandler::input() const
{
    return p->input;
}

QString PathHandler::output() const
{
    return p->output;
}

QByteArray PathHandler::readData(qint64 id)
{
    QByteArray result;
    path_handler_mutex.lock();
    if( path_handler_datas.contains(id) )
    {
        result = path_handler_datas.value(id);
        path_handler_mutex.unlock();
        return result;

    }

    const QString path = path_handler_inputs.value(id);
    path_handler_mutex.unlock();

    if( path.isEmpty() )
        return result;

    QFile file(path);
    if( !file.open(QFile::ReadOnly) )
        return result;

    result = file.readAll();
    path_handler_mutex.lock();
    path_handler_datas[id] = result;
    path_handler_mutex.unlock();

    return result;
}

QString PathHandler::readPathOf(qint64 id)
{
    path_handler_mutex.lock();
    const QString path = path_handler_inputs.value(id);
    path_handler_mutex.unlock();
    return path;
}

void PathHandler::refresh_output()
{
    QFileInfo file(p->input);
    if( file.suffix() == PATH_HANDLER_LLOCK_SUFFIX )
    {
        p->output = "image://"PATH_HANDLER_NAME"/"PATH_HANDLER_LLOCK"/" + QString::number(p->id);
    }
    else
    if( file.suffix() == PATH_HANDLER_LLOCK_SUFFIX_THUMB )
    {
        p->output = "image://"PATH_HANDLER_NAME"/"PATH_HANDLER_LLOCK_THUMB"/" + QString::number(p->id);
    }
    else
        p->output = "file://" + p->input;

    emit outputChanged();
}

PathHandler::~PathHandler()
{
    path_handler_mutex.lock();
    path_handler_inputs.remove(p->id);
    path_handler_datas.remove(p->id);
    path_handler_mutex.unlock();

    delete p;
}
