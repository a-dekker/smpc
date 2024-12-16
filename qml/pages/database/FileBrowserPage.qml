import QtQuick 2.2
import Sailfish.Silica 1.0
import "../../components"

Page {
    id: filePage
    property string filepath
    property var listmodel
    property int lastContentPosY: 0

    RemorsePopup {
        id: timerRemorse
    }

    SilicaListView {
        id: fileListView
        model: listmodel
        quickScroll: jollaQuickscroll
        highlightFollowsCurrentItem: true
        SpeedScroller {
            listview: fileListView
            scrollenabled: fastscrollenabled
            visible: !pulleyTop.active
        }
        clip: true
        ScrollDecorator {}

        anchors {
            fill: parent
            //                bottomMargin: quickControlPanel.visibleSize
        }
        contentWidth: width
        header: PageHeader {
            title: qsTr("Filebrowser") //(filepath===""? "Files:" : filepath)
        }
        PullDownMenu {
            id: pulleyTop
            MenuItem {
                text: qsTr("Home")
                onClicked: {
                    pageStack.clear()
                    pageStack.push(initialPage)
                }
            }
            MenuItem {
                text: qsTr("Replace folder")
                enabled: ctl.player.playbackStatus.title === ""
                         && mArtist === ""
                onClicked: {
                    timerRemorse.execute(qsTr("Replacing folder"), function () {
                        ctl.player.playlist.clear()
                        ctl.player.playlist.addTrack(filepath)
                    }, remorseTimerSecs * 1000)
                }
            }
            MenuItem {
                text: qsTr("Add folder")
                onClicked: {
                    timerRemorse.execute(qsTr("Adding folder"), function () {
                        ctl.player.playlist.addTrack(filepath)
                    }, remorseTimerSecs * 1000)
                }
            }
            MenuItem {
                text: qsTr("Play folder")
                onClicked: {
                    timerRemorse.execute(qsTr("Playing folder"), function () {
                        //FIXME does it work for paths??
                        ctl.player.playlist.playTrack(filepath)
                    }, remorseTimerSecs * 1000)
                }
            }
        }
        delegate: FileDelegate {}
    }

    onStatusChanged: {
        // Restore scroll position
        if (status === PageStatus.Activating && lastContentPosY) {
            fileListView.cancelFlick()
            fileListView.positionViewAtIndex(lastContentPosY, ListView.Center)
        }
    }

    Component.onDestruction: {
        fastscrollenabled = false
        popfilemodelstack()
    }
}
