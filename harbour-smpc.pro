# The name of your app
TARGET = harbour-smpc

QT += network gui sql multimedia svg

CONFIG += sailfishapp

INCLUDEPATH += src
QML_IMPORT_PATH += qml

#DEFINES += QT_USE_FAST_CONCATENATION QT_USE_FAST_OPERATOR_PLUS QT_NO_DEBUG_OUTPUT
DEFINES += QT_USE_FAST_CONCATENATION QT_USE_FAST_OPERATOR_PLUS

# C++ sources
SOURCES += main.cpp \
    src/localdb/qmlimageprovider.cpp \
    src/localdb/lastfmartistprovider.cpp \
    src/localdb/lastfmalbumprovider.cpp \
    src/localdb/imagedownloader.cpp \
    src/localdb/imagedatabase.cpp \
    src/localdb/databasefilljob.cpp \
    src/localdb/artistinformation.cpp \
    src/localdb/albuminformation.cpp \
    src/mpd/serverprofile.cpp \
    src/mpd/playlistmodel.cpp \
    src/mpd/networkaccess.cpp \
    src/mpd/mpdtrack.cpp \
    src/mpd/mpdoutput.cpp \
    src/mpd/mpdfileentry.cpp \
    src/mpd/mpdartist.cpp \
    src/mpd/mpdalbum.cpp \
    src/mpd/filemodel.cpp \
    src/mpd/artistmodel.cpp \
    src/mpd/albummodel.cpp \
    src/controller.cpp \
    src/player.cpp \
    src/mpd/serverprofilemodel.cpp \
    src/mpd/mpdplaybackstatus.cpp \
    src/mpd/serverinfo.cpp \
    src/playlist.cpp

# C++ headers
HEADERS += \
    src/controller.h \
    src/localdb/qmlimageprovider.h \
    src/localdb/lastfmartistprovider.h \
    src/localdb/lastfmalbumprovider.h \
    src/localdb/imagedownloader.h \
    src/localdb/imagedatabase.h \
    src/localdb/databasestatistic.h \
    src/localdb/databasefilljob.h \
    src/localdb/artistinformation.h \
    src/localdb/albuminformation.h \
    src/mpd/serverprofile.h \
    src/mpd/playlistmodel.h \
    src/mpd/networkaccess.h \
    src/mpd/mpdtrack.h \
    src/mpd/mpdoutput.h \
    src/mpd/mpdfileentry.h \
    src/mpd/mpdartist.h \
    src/mpd/mpdalbum.h \
    src/mpd/filemodel.h \
    src/mpd/artistmodel.h \
    src/mpd/albummodel.h \
    src/common.h \
    src/player.h \
    src/mpd/serverprofilemodel.h \
    src/mpd/mpdplaybackstatus.h \
    src/mpd/mpdcommon.h \
    src/mpd/serverinfo.h \
    src/playlist.h

DISTFILES += \
    harbour-smpc.desktop \
    qml/components/ConsumeSwitch.qml \
    qml/components/MainMenuItem.qml \
    qml/components/SingleSwitch.qml \
    rpm/harbour-smpc.changes \
    rpm/harbour-smpc.spec \
    translations/*.ts

RESOURCES += \
    miscresources.qrc

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

TRANSLATIONS += \
    translations/$${TARGET}-de.ts \
    translations/$${TARGET}-es.ts \
    translations/$${TARGET}-sv.ts \
    translations/$${TARGET}-fr.ts
