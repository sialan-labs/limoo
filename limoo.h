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

#ifndef LIMOO_H
#define LIMOO_H

#include <QObject>
#include <QSize>
#include <QStringList>
#include <QColor>

class LimooPrivate;
class Limoo : public QObject
{
    Q_PROPERTY(QString home READ home NOTIFY homeChanged)
    Q_PROPERTY(QString startDirectory READ startDirectory NOTIFY startDirectoryChanged)
    Q_PROPERTY(QString inputPath READ inputPath NOTIFY inputPathChanged)
    Q_PROPERTY(bool startViewMode READ startViewMode NOTIFY startViewModeChanged)
    Q_PROPERTY(bool fullScreen READ fullScreen WRITE setFullScreen NOTIFY fullScreenChanged)
    Q_PROPERTY(bool highContrast READ highContrast WRITE setHighContrast NOTIFY highContrastChanged)
    Q_PROPERTY(bool highGamma READ highGamma WRITE setHighGamma NOTIFY highGammaChanged)
    Q_PROPERTY(bool highBright READ highBright WRITE setHighBright NOTIFY highBrightChanged)
    Q_PROPERTY(bool initialized READ initialized NOTIFY initializedChanged)
    Q_PROPERTY(bool fcrThumbnailBar READ fcrThumbnailBar WRITE setFcrThumbnailBar NOTIFY fcrThumbnailBarChanged)
    Q_PROPERTY(bool thumbnailBar READ thumbnailBar WRITE setThumbnailBar NOTIFY thumbnailBarChanged)
    Q_PROPERTY(bool nrmlThumbnailBar READ nrmlThumbnailBar WRITE setNrmlThumbnailBar NOTIFY nrmlThumbnailBarChanged)
    Q_PROPERTY(QStringList languages READ languages NOTIFY languagesChanged)
    Q_PROPERTY(QString currentLanguage READ currentLanguage WRITE setCurrentLanguage NOTIFY currentLanguageChanged)

    Q_OBJECT
public:
    Limoo(QObject *parent = 0);
    ~Limoo();

    QString home() const;
    QString startDirectory() const;
    QString inputPath() const;
    bool startViewMode() const;
    bool initialized() const;

    Q_INVOKABLE QString aboutSialan() const;
    Q_INVOKABLE QString aboutLimoo() const;
    Q_INVOKABLE QString version() const;

    void setFullScreen( bool stt );
    bool fullScreen() const;

    void setHighContrast( bool stt );
    bool highContrast() const;

    void setHighGamma( bool stt );
    bool highGamma() const;

    void setHighBright( bool stt );
    bool highBright() const;

    void setThumbnailBar( bool stt );
    bool thumbnailBar() const;

    void setFcrThumbnailBar( bool stt );
    bool fcrThumbnailBar() const;

    void setNrmlThumbnailBar( bool stt );
    bool nrmlThumbnailBar() const;

    void setCurrentLanguage( const QString & lang );
    QString currentLanguage() const;

    QStringList languages() const;

    Q_INVOKABLE QSize imageSize(QString path ) const;
    Q_INVOKABLE quint64 fileSize(QString path ) const;
    Q_INVOKABLE QString fileName(QString path ) const;
    Q_INVOKABLE bool isSVG(QString path) const;

    Q_INVOKABLE QStringList folderEntry(QString path, const QStringList &filter, int count = -1 ) const;

    Q_INVOKABLE void deleteFiles( const QStringList & files );
    Q_INVOKABLE bool deleteFile(QString file );
    Q_INVOKABLE bool openDirectory(QString path );
    Q_INVOKABLE QString directoryOf(QString path );
    Q_INVOKABLE bool isDirectory(QString path );
    Q_INVOKABLE bool createDirectory(QString path);
    Q_INVOKABLE bool renameFile(QString path, const QString & newName);
    Q_INVOKABLE bool fileExists(QString path );
    Q_INVOKABLE bool copyFile( QString src, QString dst, bool allow_delete = false );
    Q_INVOKABLE void pasteClipboardFiles( QString dst );

    Q_INVOKABLE void setWallpaper(QString file );

    Q_INVOKABLE void setClipboardText( const QString & text );
    Q_INVOKABLE void setCopyClipboardUrl(const QStringList &path );
    Q_INVOKABLE void setCutClipboardUrl(const QStringList &path );

public slots:
    void start();

signals:
    void homeChanged();
    void startDirectoryChanged();
    void languagesChanged();
    void currentLanguageChanged();
    void inputPathChanged();
    void startViewModeChanged();
    void fullScreenChanged();
    void highContrastChanged();
    void highGammaChanged();
    void highBrightChanged();
    void initializedChanged();
    void thumbnailBarChanged();
    void fcrThumbnailBarChanged();
    void nrmlThumbnailBarChanged();

private slots:
    void windowSizeChanged();

private:
    void init_languages();

protected:
    bool eventFilter(QObject *o, QEvent *e);

private:
    LimooPrivate *p;
};

#endif // LIMOO_H
