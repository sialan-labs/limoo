folder_01.source = qml/Limoo
folder_01.target = $${DESTDIR}/qml
translations.source = translations
translations.target = $${DESTDIR}
DEPLOYMENTFOLDERS = folder_01 translations

QML_IMPORT_PATH =

QT += widgets script

unix:!macx {
    LIBS = -lexiv2
}
win32 {
    LIBS += exiv/lib/libexiv2.dll
    INCLUDEPATH += exiv/include
    QT += winextras
}

SOURCES += main.cpp \
    limoo.cpp \
    iconprovider.cpp \
    thumbnailloaderitem.cpp \
    thumbnailloader.cpp \
    imagemetadata.cpp \
    pluginmanager.cpp \
    structures.cpp \
    pathhandler.cpp \
    pathhandlerimageprovider.cpp \
    SimpleQtCryptor/simpleqtcryptor.cpp \
    fileencrypter.cpp \
    passwordmanager.cpp \
    encrypttools.cpp

include(sialantools/sialantools.pri)
include(qtquick2applicationviewer/qtquick2applicationviewer.pri)
qtcAddDeployment()

HEADERS += \
    limoo.h \
    iconprovider.h \
    limoo_macros.h \
    thumbnailloaderitem.h \
    thumbnailloader.h \
    imagemetadata.h \
    pluginmanager.h \
    structures.h \
    pathhandler.h \
    pathhandlerimageprovider.h \
    SimpleQtCryptor/serpent_sbox.h \
    SimpleQtCryptor/simpleqtcryptor.h \
    fileencrypter.h \
    passwordmanager.h \
    encrypttools.h

OTHER_FILES += \
    qml/Limoo/Basket.qml \
    qml/Limoo/files/background.png \
    qml/Limoo/files/edit-copy.png \
    qml/Limoo/files/edit-clear.png
