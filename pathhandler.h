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

#ifndef PATHHANDLER_H
#define PATHHANDLER_H

#include "limoo_macros.h"
#include <QObject>

class PathHandlerPrivate;
class PathHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString input READ input WRITE setInput NOTIFY inputChanged)
    Q_PROPERTY(QString output READ output NOTIFY outputChanged)
public:
    PathHandler(QObject *parent = 0);
    ~PathHandler();

    void setInput( QString input );
    QString input() const;

    QString output() const;

    static QByteArray readData( qint64 id );
    static QString readPathOf( qint64 id );

signals:
    void inputChanged();
    void outputChanged();

private:
    void refresh_output();

private:
    PathHandlerPrivate *p;
};

#endif // PATHHANDLER_H
