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

#ifndef PASSWORDMANAGER_H
#define PASSWORDMANAGER_H

#include <QObject>

class PasswordManagerPrivate;
class PasswordManager : public QObject
{
    Q_OBJECT
public:
    PasswordManager( QObject *parent = 0 );
    ~PasswordManager();

public slots:
    static bool passwordEntered(QString path);
    static bool fileIsEncrypted(QString path);
    static bool checkPassword(QString path, const QString & pass);
    static QString passwordFileOf( QString path );
    static bool dirHasPassword( QString path );
    static QString passwordOf(QString path);
    static void setPasswordOf(QString path , const QString &pass);

private:
    PasswordManagerPrivate *p;
};

#endif // PASSWORDMANAGER_H
