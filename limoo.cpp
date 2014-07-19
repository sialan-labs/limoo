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

#define NORMALIZE_PATH( PATH ) \
    if( PATH.left(7) == "file://" ) \
        PATH = PATH.mid(7);

#include "limoo.h"
#include "limoo_macros.h"
#include "imagemetadata.h"
#include "mimeapps.h"
#include "iconprovider.h"
#include "thumbnailloader.h"
#include "enums.h"
#include "qtquick2applicationviewer.h"

#include <QQmlEngine>
#include <QQmlContext>
#include <QtQml>
#include <QGuiApplication>
#include <QDir>
#include <QFileInfo>
#include <QDesktopServices>
#include <QStringList>
#include <QDebug>
#include <QImageReader>
#include <QDir>
#include <QSettings>
#include <QClipboard>
#include <QMimeData>
#include <QProcess>
#include <QPalette>
#include <QScreen>

class LimooPrivate
{
public:
    QtQuick2ApplicationViewer *viewer;
    IconProvider *icon_provider;
    ThumbnailLoader *thumbnail_loader;

    bool fullscreen;
    bool initialized;
    bool thumbnailBar;

    QString homePath;
    QString confPath;

    QSettings *settings;
    MimeApps *mapp;
};

Limoo::Limoo(QObject *parent) :
    QObject(parent)
{
    p = new LimooPrivate;
    p->viewer = 0;
    p->fullscreen = false;
    p->initialized = false;
    p->homePath = HOME_PATH;
    p->confPath = CONF_PATH;

    QIcon::setThemeName("FaenzaFlattr");
    QDir().mkpath(p->homePath);

    p->settings = new QSettings(p->confPath,QSettings::IniFormat,this);
    p->thumbnailBar = p->settings->value("General/thumbnailBar",true).toBool();

    qmlRegisterType<Enums>("org.sialan.limoo", 1, 0, "Enums");
    qmlRegisterType<ImageMetaData>("org.sialan.limoo", 1, 0, "ImageMetaData");
}

QString Limoo::home() const
{
    return QDir::homePath();
}

QString Limoo::startDirectory() const
{
    const QStringList & args = QGuiApplication::arguments();
    if( args.count() <= 1 )
        return home();

    const QString & filePath = args.at(1);

    QFileInfo file(filePath);
    if( !file.exists() )
        return home();
    else
    if( file.isDir() )
        return filePath;
    else
        return file.dir().path();
}

QString Limoo::inputPath() const
{
    const QStringList & args = QGuiApplication::arguments();
    if( args.count() <= 1 )
        return QString();

    const QString & filePath = args.at(1);
    QFileInfo file(filePath);
    if( !file.exists() )
        return QString();

    return filePath;
}

bool Limoo::startViewMode() const
{
    const QString & path = inputPath();
    if( path.isEmpty() )
        return false;

    return QFileInfo(path).isFile();
}

bool Limoo::initialized() const
{
    return p->initialized;
}

qreal Limoo::lcdDpiX()
{
    if( QGuiApplication::screens().isEmpty() )
        return 0;

    QScreen *scr = QGuiApplication::screens().first();
    return scr->physicalDotsPerInchX();
}

qreal Limoo::lcdDpiY()
{
    if( QGuiApplication::screens().isEmpty() )
        return 0;

    QScreen *scr = QGuiApplication::screens().first();
    return scr->physicalDotsPerInchY();
}

int Limoo::densityDpi()
{
#ifdef Q_OS_ANDROID
    return p->java_layer->densityDpi();
#else
    return lcdDpiX();
#endif
}

qreal Limoo::density()
{
#ifdef Q_OS_ANDROID
    return p->java_layer->density()*ratio;
#else
#ifdef Q_OS_IOS
    return ratio*densityDpi()/180.0;
#else
    QScreen *scr = QGuiApplication::screens().first();
    qreal ratio = 1*scr->logicalDotsPerInch()/96;
    return ratio;
#endif
#endif
}

QString Limoo::aboutSialan() const
{
    return tr("Sialan Labs is a not-for-profit research and software development team launched in February 2014 focusing on development of products, technologies and solutions in order to publish them as open-source projects accessible to all people in the universe. Currently, we are focusing on design and development of software applications and tools which have direct connection with end users.") + "\n\n" +
            tr("By enabling innovative projects and distributing software to millions of users globally, the lab is working to accelerate the growth of high-impact open source software projects and promote an open source culture of accessibility and increased productivity around the world. The lab partners with industry leaders and policy makers to bring open source technologies to new sectors, including education, health and government.");
}

QString Limoo::aboutLimoo() const
{
    return tr("Limoo is a modern image viewer ,focused on user interface and user friendly.") + "\n"
            + tr("Limoo is Free software and released under GPLv3 License.");
}

QString Limoo::version() const
{
    return "1.0.0";
}

QSize Limoo::imageSize(const QString &path) const
{
    if( path.isEmpty() )
        return QSize();

    ImageMetaData mdata;
    mdata.setSource(path);

    QSize res = QImageReader(path).size();
    if( mdata.orientation() == ImageMetaData::Left || mdata.orientation() == ImageMetaData::Right )
        res = QSize(res.height(),res.width());

    return res;
}

quint64 Limoo::fileSize(const QString &path) const
{
    return QFileInfo(path).size();
}

QString Limoo::fileName(const QString &path) const
{
    return QFileInfo(path).fileName();
}

QStringList Limoo::folderEntry(const QString & path, const QStringList & filter, int count) const
{
    const QStringList & result = QDir(path).entryList(filter,QDir::Files,QDir::Name);
    if( count == -1 )
        return result;
    else
        return result.mid(0,count);
}

void Limoo::deleteFiles(const QStringList &files)
{
    foreach( const QString & file, files )
        deleteFile(file);
}

bool Limoo::deleteFile(const QString &file)
{
    return QFile(file).remove();
}

bool Limoo::openDirectory(const QString &path)
{
    QString dir = path;

    QFileInfo inf(path);
    if( inf.isFile() )
        dir = inf.dir().path();

    return QDesktopServices::openUrl( QUrl::fromLocalFile(dir) );
}

QString Limoo::directoryOf(QString path)
{
    NORMALIZE_PATH(path)
    return QFileInfo(path).dir().path();
}

bool Limoo::isDirectory(const QString &path)
{
    return QFileInfo(path).isDir();
}

bool Limoo::fileExists(QString path)
{
    NORMALIZE_PATH(path)
    return QFile::exists(path);
}

bool Limoo::copyFile(QString src, QString dst, bool allow_delete)
{
    NORMALIZE_PATH(src)
    NORMALIZE_PATH(dst)
    if( fileExists(dst) )
    {
        if( allow_delete )
            QFile::remove(dst);
        else
            return false;
    }

    return QFile::copy(src,dst);
}

void Limoo::setWallpaper(const QString &file)
{
    switch( desktopSession() )
    {
    case Enums::Mac:
        break;

    case Enums::Windows:
        break;

    case Enums::Kde:
        break;

    case Enums::Unity:
    case Enums::GnomeFallBack:
    case Enums::Gnome:
    {
        QString command = "dconf";
        QStringList args;
        args << "write" << "/org/gnome/desktop/background/picture-uri" << QString("'file://%1'").arg(file);

        QProcess::startDetached(command,args);
    }
        break;
    }
}

void Limoo::setClipboardText(const QString &text)
{
    QGuiApplication::clipboard()->setText(text);
}

void Limoo::setCopyClipboardUrl(const QStringList &paths)
{
    QList<QUrl> urls;
    QString data = "copy";

    foreach( const QString & p, paths ) {
        QUrl url = QUrl::fromLocalFile(p);
        urls << url;
        data += "\nfile://" + url.toLocalFile();
    }

    QMimeData *mimeData = new QMimeData();
    mimeData->setUrls( urls );
    mimeData->setData( "x-special/gnome-copied-files", data.toUtf8() );

    QGuiApplication::clipboard()->setMimeData(mimeData);
}

void Limoo::setCutClipboardUrl(const QStringList &paths)
{
    QList<QUrl> urls;

    QString data;
    foreach( const QString & p, paths ) {
        QUrl url = QUrl::fromLocalFile(p);
        urls << url;
        data += "\nfile://" + url.toLocalFile();
    }
    data.remove(0,1);

    QMimeData *mimeData = new QMimeData();
//    mimeData->setUrls( urls );
    mimeData->setData( "x-special/gnome-copied-files", QString("cut\n" + data).toUtf8() );
    mimeData->setData( "text/uri-list", data.toUtf8());
    mimeData->setData( "application/x-kde-cutselection", "1");

    QGuiApplication::clipboard()->setMimeData(mimeData);
}

void Limoo::setFullScreen(bool stt)
{
    if( p->fullscreen == stt )
        return;

    p->fullscreen = stt;
    if( p->fullscreen )
        p->viewer->showFullScreen();
    else
        p->viewer->showNormal();

    emit fullScreenChanged();
}

bool Limoo::fullScreen() const
{
    return p->fullscreen;
}

void Limoo::setThumbnailBar(bool stt)
{
    if( p->thumbnailBar == stt )
        return;

    p->thumbnailBar = stt;
    p->settings->setValue("General/thumbnailBar",stt);
    emit thumbnailBarChanged();
}

bool Limoo::thumbnailBar() const
{
    return p->thumbnailBar;
}

int Limoo::desktopSession() const
{
    static int result = -1;
    if( result != -1 )
        return result;

#ifdef Q_OS_MAC
    result = Enums::Mac;
#else
#ifdef Q_OS_WIN
    result = Enums::Windows;
#else
    static QString *desktop_session = 0;
    if( !desktop_session )
        desktop_session = new QString( qgetenv("DESKTOP_SESSION") );

    if( desktop_session->contains("kde",Qt::CaseInsensitive) )
        result = Enums::Kde;
    else
    if( desktop_session->contains("ubuntu",Qt::CaseInsensitive) )
        result = Enums::Unity;
    else
    if( desktop_session->contains("gnome-fallback",Qt::CaseInsensitive) )
        result = Enums::GnomeFallBack;
    else
        result = Enums::Gnome;
#endif
#endif

    if( result == -1 )
        result = Enums::Unknown;

    return result;
}

QColor Limoo::titleBarColor()
{
    switch( desktopSession() )
    {
    case Enums::Mac:
        return QColor("#3D3C38");
        break;

    case Enums::Windows:
        return QColor("#3D3C38");
        break;

    case Enums::Kde:
        return QPalette().window().color();
        break;

    case Enums::Unity:
    case Enums::GnomeFallBack:
    case Enums::Gnome:
    {
        static QColor *res = 0;
        if( !res )
        {
            QProcess prc;
            prc.start( "dconf", QStringList()<< "read"<< "/org/gnome/desktop/interface/gtk-theme" );
            prc.waitForStarted();
            prc.waitForFinished();
            QString sres = prc.readAll();
            sres.remove("\n").remove("'");
            sres = sres.toLower();

            if( sres == "ambiance" )
                res = new QColor("#403F3A");
            else
            if( sres == "radiance" )
                res = new QColor("#DFD7CF");
            else
            if( sres == "adwaita" )
                res = new QColor("#D7D3D2");
            else
                res = new QColor("#403F3A");
        }

        return *res;
    }
        break;
    }

    return QColor("#403F3A");
}

QColor Limoo::titleBarTransparentColor()
{
    QColor color = titleBarColor();
    color.setAlpha(128);
    return color;
}

QColor Limoo::titleBarTextColor()
{
    switch( desktopSession() )
    {
    case Enums::Mac:
        return QColor("#cccccc");
        break;

    case Enums::Windows:
        return QColor("#cccccc");
        break;

    case Enums::Kde:
        return QPalette().windowText().color();
        break;

    case Enums::Unity:
    case Enums::GnomeFallBack:
    case Enums::Gnome:
    {
        static QColor *res = 0;
        if( !res )
        {
            QProcess prc;
            prc.start( "dconf", QStringList()<< "read"<< "/org/gnome/desktop/interface/gtk-theme" );
            prc.waitForStarted();
            prc.waitForFinished();
            QString sres = prc.readAll();
            sres.remove("\n").remove("'");
            sres = sres.toLower();

            if( sres == "ambiance" )
                res = new QColor("#eeeeee");
            else
            if( sres == "radiance" )
                res = new QColor("#333333");
            else
            if( sres == "adwaita" )
                res = new QColor("#333333");
            else
                res = new QColor("#cccccc");
        }

        return *res;
    }
        break;
    }

    return QColor("#eeeeee");
}

void Limoo::start()
{
    p->icon_provider = new IconProvider();
    p->thumbnail_loader = new ThumbnailLoader(this);
    p->mapp = new MimeApps(this);

    p->viewer = new QtQuick2ApplicationViewer();
    p->viewer->engine()->rootContext()->setContextProperty( "Window", p->viewer );
    p->viewer->engine()->rootContext()->setContextProperty( "Limoo", this );
    p->viewer->engine()->rootContext()->setContextProperty( "MimeApps", p->mapp );
    p->viewer->engine()->rootContext()->setContextProperty( "ThumbnailLoader", p->thumbnail_loader );
    p->viewer->engine()->addImageProvider("icon",p->icon_provider);
    p->viewer->setMainQmlFile(QStringLiteral("qml/Limoo/main.qml"));
    p->viewer->resize( p->settings->value("window/size",QSize(960,600)).toSize() );
    p->viewer->showExpanded();

    connect( p->viewer, SIGNAL(heightChanged(int)), SLOT(windowSizeChanged()) );
    connect( p->viewer, SIGNAL(widthChanged(int)) , SLOT(windowSizeChanged()) );

    p->initialized = true;
    emit initializedChanged();
}

void Limoo::windowSizeChanged()
{
    p->settings->setValue("window/size",p->viewer->size());
}

Limoo::~Limoo()
{
    if( p->viewer )
        delete p->viewer;

    delete p;
}
