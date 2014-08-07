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
#include "SimpleQtCryptor/simpleqtcryptor.h"

#include <QUuid>
#include <QHash>
#include <QMutex>

QHash<QString,QString> pmanager_master_passwords;
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
    bool result = pmanager_master_passwords.contains(path);
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
    if( pmanager_master_passwords.contains(path) )
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

    const QByteArray & sdata = f.readAll();

    QSharedPointer<SimpleQtCryptor::Key> gKey = QSharedPointer<SimpleQtCryptor::Key>(new SimpleQtCryptor::Key(pass));
    SimpleQtCryptor::Decryptor dec( gKey, SimpleQtCryptor::SERPENT_32, SimpleQtCryptor::ModeCFB );
    QByteArray enc_code_dec;
    if( dec.decrypt(sdata,enc_code_dec,true) == SimpleQtCryptor::ErrorInvalidKey )
        return result;

    pmanager_mutex.lock();
    pmanager_master_passwords[path] = enc_code_dec;
    pmanager_passwords[path] = pass;
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

QString PasswordManager::masterPasswordOf(QString path)
{
    NORMALIZE_PATH(path);
    path = passwordFileOf(path);
    path = QFileInfo(path).path();

    pmanager_mutex.lock();
    QString result = pmanager_master_passwords.value(path);
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

    const QByteArray & data = QUuid::createUuid().toByteArray();

    QSharedPointer<SimpleQtCryptor::Key> gKey = QSharedPointer<SimpleQtCryptor::Key>(new SimpleQtCryptor::Key(pass));
    SimpleQtCryptor::Encryptor enc( gKey, SimpleQtCryptor::SERPENT_32, SimpleQtCryptor::ModeCFB, SimpleQtCryptor::NoChecksum );

    QByteArray enc_new_data;
    enc.encrypt( data, enc_new_data, true );

    file.write(enc_new_data);
    file.flush();
    file.close();
}

PasswordManager::~PasswordManager()
{
    delete p;
}
