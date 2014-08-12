# Add more folders to ship with the application, here
folder_01.source = qml/Limoo
folder_01.target = $${DESTDIR}/qml
translations.source = translations
translations.target = $${DESTDIR}
DEPLOYMENTFOLDERS = folder_01 translations

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

QT += widgets script

unix:!macx {
    LIBS = -lexiv2
}
win32 {
    LIBS = C:/Users/Bardia/Projects/exiv/libexiv2.dll
    INCLUDEPATH = C:/Users/Bardia/Projects/exiv
    QT += winextras
}

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    limoo.cpp \
    iconprovider.cpp \
    enums.cpp \
    thumbnailloaderitem.cpp \
    thumbnailloader.cpp \
    imagemetadata.cpp \
    pluginmanager.cpp \
    structures.cpp \
    mimeapps.cpp \
    pathhandler.cpp \
    pathhandlerimageprovider.cpp \
    SimpleQtCryptor/simpleqtcryptor.cpp \
    fileencrypter.cpp \
    passwordmanager.cpp \
    encrypttools.cpp

# Installation path
# target.path =

# Please do not modify the following two lines. Required for deployment.
include(qtquick2applicationviewer/qtquick2applicationviewer.pri)
qtcAddDeployment()

HEADERS += \
    limoo.h \
    iconprovider.h \
    limoo_macros.h \
    enums.h \
    thumbnailloaderitem.h \
    thumbnailloader.h \
    imagemetadata.h \
    pluginmanager.h \
    structures.h \
    mimeapps.h \
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
