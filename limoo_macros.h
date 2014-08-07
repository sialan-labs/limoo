/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

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

#ifndef LIMOO_MACROS_H
#define LIMOO_MACROS_H

#include <QDir>
#include <QCoreApplication>
#include <QCryptographicHash>

#ifdef Q_OS_WIN
#define HOME_PATH QString(QDir::homePath() + "/AppData/Local/sialan/limoo")
#define LOCALES_PATH QString( QCoreApplication::applicationDirPath() + "/translations/" )
#else
#define HOME_PATH QString(QDir::homePath() + "/.config/sialan/limoo")
#define LOCALES_PATH QString( QCoreApplication::applicationDirPath() + "/translations/" )
#endif

#define CONF_PATH QString(HOME_PATH + "/config.ini")
#define PLUGINS_LOCAL_PATH  QString(HOME_PATH + "/plugins")
#define PLUGINS_PUBLIC_PATH QString(QCoreApplication::applicationDirPath() + "/plugins")

#define NORMALIZE_PATH( PATH ) \
    while( PATH.left(7) == "file://" ) \
        PATH = PATH.mid(7);

#define PASS_FILE_NAME ".dont_remove_me.password"

#define PATH_HANDLER_NAME  "pathhandler"
#define PATH_HANDLER_LLOCK "limoolock"
#define PATH_HANDLER_LLOCK_THUMB "limoolock_thumb"
#define PATH_HANDLER_LLOCK_SUFFIX "limlock"
#define PATH_HANDLER_LLOCK_SUFFIX_THUMB "limlockthumb"

#define ENCRYPTER_HEADER  QString("Limoo Encrypted File")
#define ENCRYPTER_VERSION 1.0

#define HASH_MD5( STRING ) QCryptographicHash::hash(STRING.toUtf8(),QCryptographicHash::Md5).toHex()

#endif // LIMOO_MACROS_H
