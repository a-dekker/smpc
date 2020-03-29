# The name of your app
TARGET = harbour-smpc

QT += network gui sql multimedia svg

CONFIG += sailfishapp

INCLUDEPATH += src
QML_IMPORT_PATH += qml

# C++ sources
SOURCES += \
	src/localdb/albuminformation.cpp \
	src/localdb/artistinformation.cpp \
	src/localdb/databasefilljob.cpp \
	src/localdb/imagedatabase.cpp \
	src/localdb/imagedownloader.cpp \
	src/localdb/lastfmalbumprovider.cpp \
	src/localdb/lastfmartistprovider.cpp \
	src/localdb/qmlimageprovider.cpp \
	src/mpd/albummodel.cpp \
	src/mpd/artistmodel.cpp \
	src/mpd/filemodel.cpp \
	src/mpd/mpdalbum.cpp \
	src/mpd/mpdartist.cpp \
	src/mpd/mpdfileentry.cpp \
	src/mpd/mpdoutput.cpp \
	src/mpd/mpdplaybackstatus.cpp \
	src/mpd/mpdtrack.cpp \
	src/mpd/networkaccess.cpp \
	src/mpd/playlistmodel.cpp \
	src/mpd/serverinfo.cpp \
	src/mpd/serverprofile.cpp \
	src/mpd/serverprofilemodel.cpp \
	src/controller.cpp \
	src/main.cpp \
	src/streamplayer.cpp

# C++ headers
HEADERS += \
	src/localdb/albuminformation.h \
	src/localdb/artistinformation.h \
	src/localdb/databasefilljob.h \
	src/localdb/databasestatistic.h \
	src/localdb/imagedatabase.h \
	src/localdb/imagedownloader.h \
	src/localdb/lastfmalbumprovider.h \
	src/localdb/lastfmartistprovider.h \
	src/localdb/qmlimageprovider.h \
	src/mpd/albummodel.h \
	src/mpd/artistmodel.h \
	src/mpd/filemodel.h \
	src/mpd/mpdalbum.h \
	src/mpd/mpdartist.h \
	src/mpd/mpdcommon.h \
	src/mpd/mpdfileentry.h \
	src/mpd/mpdoutput.h \
	src/mpd/mpdplaybackstatus.h \
	src/mpd/mpdtrack.h \
	src/mpd/networkaccess.h \
	src/mpd/playlistmodel.h \
	src/mpd/serverinfo.h \
	src/mpd/serverprofile.h \
	src/mpd/serverprofilemodel.h \
	src/common.h \
	src/controller.h \
	src/streamplayer.h

DISTFILES += \
	qml/main.qml \
	rpm/harbour-smpc.changes \
	rpm/harbour-smpc.spec \
	rpm/harbour-smpc.yaml \
	harbour-smpc.desktop \
	translations/*.ts

RESOURCES += images.qrc

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172 256x256

#DEFINES += QT_USE_FAST_CONCATENATION QT_USE_FAST_OPERATOR_PLUS QT_NO_DEBUG_OUTPUT
DEFINES += QT_USE_FAST_CONCATENATION QT_USE_FAST_OPERATOR_PLUS

CONFIG += sailfishapp_i18n
#CONFIG += sailfishapp_i18n_idbased

TRANSLATIONS += \
	translations/$${TARGET}_de.ts \
	translations/$${TARGET}_fr.ts
