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

#include "passwordmanager.h"
#include "limoo_macros.h"
#include "encrypttools.h"

#include <QHash>
#include <QMutex>
#include <QCryptographicHash>

QHash<QString,QString> pmanager_hashes;
QHash<QString,QString> pmanager_passwords;
QMutex pmanager_mutex;

class PasswordManagerPrivate
{
public:
};

PasswordManager::PasswordManager(QObject *parent) :
    QObject(parent)
{
    p = new PasswordManagerPrivate;
}

bool PasswordManager::passwordEntered(QString path)
{
    NORMALIZE_PATH(path);
    pmanager_mutex.lock();
    bool result = pmanager_passwords.contains(path);
    pmanager_mutex.unlock();

    return result;
}

bool PasswordManager::fileIsEncrypted(QString path)
{
    return QFileInfo(path).suffix() == PATH_HANDLER_LLOCK_SUFFIX;
}

bool PasswordManager::checkPassword(QString path, const QString &pass)
{
    NORMALIZE_PATH(path);
    bool result = false;

    path = passwordFileOf(path);
    if( path.isEmpty() )
        return result;

    path = QFileInfo(path).path();

    pmanager_mutex.lock();
    if( pmanager_passwords.contains(path) )
    {
        result = pmanager_passwords.value(path) == pass;
        pmanager_mutex.unlock();
        return result;
    }
    pmanager_mutex.unlock();

    const QString & pass_file = passwordFileOf(path);
    if( pass_file.isEmpty() )
        return result;

    QFile f(pass_file);
    if( !f.open(QFile::ReadOnly) )
        return result;

    const QString hash = f.readAll();
    if( hash != HASH_MD5(pass) )
        return false;

    pmanager_mutex.lock();
    pmanager_passwords[path] = pass;
    pmanager_hashes[hash] = pass;
    pmanager_mutex.unlock();

    return true;
}

QString PasswordManager::passwordFileOf(QString path)
{
    if( path.isEmpty() )
        return QString();

    NORMALIZE_PATH(path);
    QFileInfo file(path);
    if( file.isRoot() )
        return QString();

    QString pass_file = path + "/"PASS_FILE_NAME;
    if( !QFile::exists(pass_file) )
        return passwordFileOf(file.dir().path());
    else
        return pass_file;
}

bool PasswordManager::hasPassword(QString path)
{
    return QFile::exists(path+"/"PASS_FILE_NAME);
}

QString PasswordManager::passwordOf(QString path)
{
    NORMALIZE_PATH(path);
    path = passwordFileOf(path);
    path = QFileInfo(path).path();

    pmanager_mutex.lock();
    QString result = pmanager_passwords.value(path);
    pmanager_mutex.unlock();

    return result;
}

void PasswordManager::setPasswordOf(QString path, const QString & pass)
{
    NORMALIZE_PATH(path);
    QFileInfo inf(path);
    QString pass_file = passwordFileOf(path);
    if( pass_file.isEmpty() )
        pass_file = (inf.isDir()?inf.filePath():inf.dir().path()) + "/" + PASS_FILE_NAME;

    QFile file(pass_file);
    if( file.exists() )
        return;
    if( !file.open(QFile::WriteOnly) )
        return;

    file.write( HASH_MD5(pass) );
    file.flush();
    file.close();
}

bool PasswordManager::hashHasPassword(const QString & hash)
{
    pmanager_mutex.lock();
    bool result = pmanager_hashes.contains(hash);
    pmanager_mutex.unlock();

    return result;
}

PasswordManager::~PasswordManager()
{
    delete p;
}
