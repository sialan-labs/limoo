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
#include "fileencrypter.h"

#include <QHash>
#include <QMutex>
#include <QCryptographicHash>

QByteArray passHash(QString path);

QHash<QByteArray,QString> pmanager_pass_hashes;
QHash<QString,QString> pmanager_passwords;
QHash<QString,QByteArray> pmanager_hashes;
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

    if( !result )
    {
        const QByteArray & pHash = passHash(path);

        pmanager_mutex.lock();
        result = pmanager_pass_hashes.contains(pHash);
        if( result )
            pmanager_passwords[path] = pmanager_pass_hashes.value(pHash);

        pmanager_mutex.unlock();
    }

    return result;
}

bool PasswordManager::fileIsEncrypted(QString path)
{
    QFileInfo file(path);
    if( file.isDir() )
        return QFile::exists(path+"/"PASS_FILE_NAME);
    else
        return file.suffix() == PATH_HANDLER_LLOCK_SUFFIX;
}

bool PasswordManager::checkPassword(QString path, const QString &pass)
{
    NORMALIZE_PATH(path);

    QFileInfo inf(path);
    if( inf.fileName() == PASS_FILE_NAME )
        path = inf.path();

    pmanager_mutex.lock();
    if( pmanager_passwords.contains(path) )
    {
        const QString ps = pmanager_passwords.value(path);
        pmanager_mutex.unlock();
        return ps == pass;
    }
    pmanager_mutex.unlock();

    const QByteArray & ph = HASH_MD5(pass);
    const QByteArray & pHash = passHash(path);
    if( pHash != ph )
        return false;

    pmanager_mutex.lock();
    pmanager_pass_hashes[pHash] = pass;
    pmanager_passwords[path] = pass;
    pmanager_hashes[path] = pHash;
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

bool PasswordManager::dirHasPassword(QString path)
{
    return QFile::exists(path+"/"PASS_FILE_NAME);
}

QString PasswordManager::passwordOf(QString path)
{
    const QByteArray & phash = passHash(path);
    QString pass;

    pmanager_mutex.lock();
    if( pmanager_pass_hashes.contains(phash) )
        pass = pmanager_pass_hashes.value(phash);
    else
    {
        pmanager_mutex.unlock();
        const QString & passFile = passwordFileOf(path);
        pass = pmanager_passwords.value(QFileInfo(passFile).path());
        pmanager_mutex.lock();
    }
    pmanager_mutex.unlock();

    return pass;
}

void PasswordManager::setPasswordOf(QString path, const QString & pass)
{
    NORMALIZE_PATH(path);
    const QByteArray & passHash = HASH_MD5(pass);

    QFileInfo inf(path);
    if( inf.isDir() )
    {
        QString pass_file = passwordFileOf(path);
        if( pass_file.isEmpty() )
            pass_file = (inf.isDir()?inf.filePath():inf.dir().path()) + "/" + PASS_FILE_NAME;

        QFile file(pass_file);
        if( file.exists() )
            return;
        if( !file.open(QFile::WriteOnly) )
            return;

        file.write(passHash);
        file.flush();
        file.close();
    }

    pmanager_mutex.lock();
    pmanager_passwords[inf.filePath()] = pass;
    pmanager_pass_hashes[passHash] = pass;
    pmanager_hashes[inf.filePath()] = passHash;
    pmanager_mutex.unlock();
}

QByteArray passHash(QString path)
{
    NORMALIZE_PATH(path);
    pmanager_mutex.lock();
    if( pmanager_hashes.contains(path) )
    {
        QByteArray result = pmanager_hashes.value(path);
        pmanager_mutex.unlock();
        return result;
    }
    pmanager_mutex.unlock();

    QByteArray result;
    if( QFileInfo(path).isDir() )
    {
        QFile file(path+"/"PASS_FILE_NAME);
        if( !file.exists() || !file.open(QFile::ReadOnly) )
            return QByteArray();

        result = file.readAll();
    }
    else
        result = FileEncrypter::readPassHash(path);

    pmanager_mutex.lock();
    pmanager_hashes[path] = result;
    pmanager_mutex.unlock();

    return result;
}

PasswordManager::~PasswordManager()
{
    delete p;
}
