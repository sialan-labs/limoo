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

#include "pluginmanager.h"
#include "structures.h"
#include "limoo_macros.h"

#include <QSettings>
#include <QHash>
#include <QFileSystemWatcher>

class PluginManagerPrivate
{
public:
    QHash<QString,PluginMetaData> plugins;
    QFileSystemWatcher *watcher;
};

PluginManager::PluginManager(QObject *parent) :
    QObject(parent)
{
    p = new PluginManagerPrivate;

    QDir().mkpath(PLUGINS_LOCAL_PATH);
    QDir().mkpath(PLUGINS_PUBLIC_PATH);

    p->watcher = new QFileSystemWatcher();
    p->watcher->addPath( PLUGINS_LOCAL_PATH );
    p->watcher->addPath( PLUGINS_PUBLIC_PATH );

    connect( p->watcher, SIGNAL(directoryChanged(QString)), SLOT(watcher_dir_changed(QString)) );
}

void PluginManager::watcher_dir_changed(const QString &file)
{
    Q_UNUSED(file)
}

void PluginManager::init_list()
{

}

PluginManager::~PluginManager()
{
    delete p;
}
