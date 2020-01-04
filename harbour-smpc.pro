# The name of your app
TARGET = harbour-smpc

QT += network gui sql multimedia svg

CONFIG += sailfishapp

INCLUDEPATH += src

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
	qml/components/AlbumDelegate.qml \
	qml/components/AlbumListDelegate.qml \
	qml/components/AlbumShowDelegate.qml \
	qml/components/ArtistDelegate.qml \
	qml/components/ArtistListDelegate.qml \
	qml/components/ArtistShowDelegate.qml \
	qml/components/ControlPanel.qml \
	qml/components/DeletePlaylistDialog.qml \
	qml/components/FileDelegate.qml \
	qml/components/Heading.qml \
	qml/components/InfoBanner.qml \
	qml/components/MainGridItem.qml \
	qml/components/PlaylistSectionDelegate.qml \
	qml/components/SavePlaylistDialog.qml \
	qml/components/ScrollLabel.qml \
	qml/components/SectionScroller.js \
	qml/components/SectionScroller.qml \
	qml/components/SongDialog.qml \
	qml/components/SpeedScroller.js \
	qml/components/SpeedScroller.qml \
	qml/components/ToggleImage.qml \
	qml/components/URLInputDialog.qml \
	qml/components/qmldir \
	qml/cover/CoverPage.qml \
	qml/pages/MainPage.qml \
	qml/pages/database/AddToPlaylistDialog.qml \
	qml/pages/database/AlbumInfoPage.qml \
	qml/pages/database/AlbumListPage.qml \
	qml/pages/database/AlbumTracksPage.qml \
	qml/pages/database/ArtistInfoPage.qml \
	qml/pages/database/ArtistInformationPage.qml \
	qml/pages/database/ArtistListPage.qml \
	qml/pages/database/CurrentPlaylistPage.qml \
	qml/pages/database/CurrentPlaylistPage_large.qml \
	qml/pages/database/CurrentPlaylistPage_large.qml \
	qml/pages/database/CurrentSong.qml \
	qml/pages/database/CurrentSong_large.qml \
	qml/pages/database/FileBrowserPage.qml \
	qml/pages/database/PlaylistTracksPage.qml \
	qml/pages/database/SavedPlaylistsPage.qml \
	qml/pages/database/SearchPage.qml \
	qml/pages/database/SongPage.qml \
	qml/pages/settings/AboutPage.qml \
	qml/pages/settings/ConnectServerPage.qml \
	qml/pages/settings/DatabaseSettings.qml \
	qml/pages/settings/GUISettings.qml \
	qml/pages/settings/OutputsPage.qml \
	qml/pages/settings/ServerEditPage.qml \
	qml/pages/settings/ServerListPage.qml \
	qml/pages/settings/SettingsPage.qml \
	qml/main.qml \
	rpm/harbour-smpc.changes.in \
	rpm/harbour-smpc.changes.run.in \
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

#lupdate_only {
#SOURCES += \
#	qml/components/AlbumDelegate.qml \
#	qml/components/AlbumListDelegate.qml \
#	qml/components/AlbumShowDelegate.qml \
#	qml/components/ArtistDelegate.qml \
#	qml/components/ArtistListDelegate.qml \
#	qml/components/ArtistShowDelegate.qml \
#	qml/components/ControlPanel.qml \
#	qml/components/FileDelegate.qml \
#	qml/components/Heading.qml \
#	qml/components/MainGridItem.qml \
#	qml/components/ScrollLabel.qml \
#	qml/components/SectionScroller.js \
#	qml/components/SectionScroller.qml \
#	qml/components/SongDialog.qml \
#	qml/components/SpeedScroller.js \
#	qml/components/SpeedScroller.qml \
#	qml/components/ToggleImage.qml \
#	qml/cover/CoverPage.qml \
#	qml/pages/MainPage.qml \
#	qml/pages/database/AddToPlaylistDialog.qml \
#	qml/pages/database/AlbumInfoPage.qml \
#	qml/pages/database/AlbumListPage.qml \
#	qml/pages/database/AlbumTracksPage.qml \
#	qml/pages/database/ArtistInfoPage.qml \
#	qml/pages/database/ArtistInformationPage.qml \
#	qml/pages/database/ArtistListPage.qml \
#	qml/pages/database/CurrentPlaylistPage.qml \
#	qml/pages/database/CurrentPlaylistPage_large.qml \
#	qml/pages/database/CurrentSong.qml \
#	qml/pages/database/FileBrowserPage.qml \
#	qml/pages/database/PlaylistTracksPage.qml \
#	qml/pages/database/SavedPlaylistsPage.qml \
#	qml/pages/database/SearchPage.qml \
#	qml/pages/database/SongPage.qml \
#	qml/pages/settings/AboutPage.qml \
#	qml/pages/settings/ConnectServerPage.qml \
#	qml/pages/settings/DatabaseSettings.qml \
#	qml/pages/settings/GUISettings.qml \
#	qml/pages/settings/OutputsPage.qml \
#	qml/pages/settings/ServerEditPage.qml \
#	qml/pages/settings/ServerListPage.qml \
#	qml/pages/settings/SettingsPage.qml \
#	qml/main.qml
#}
