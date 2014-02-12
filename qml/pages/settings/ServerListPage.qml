import QtQuick 2.0
import Sailfish.Silica 1.0


Page
{
    id: serverListPage
    allowedOrientations: bothOrientation
    SilicaListView {
            id : serverListView
            model: serverList;
            anchors.fill: parent
//            anchors.bottomMargin: quickControlPanel.visibleSize
            clip: true
            contentWidth: width
            header: PageHeader {
                title: qsTr("servers");
            }
            ScrollDecorator {}
            PullDownMenu {
             MenuItem {
                 text: qsTr("Add server")
                 onClicked: {
                     console.log("Clicked option add server")
                     pageStack.push(Qt.resolvedUrl("ServerEditPage.qml"),{newprofile:true});
                 }
             }
            }
            delegate: BackgroundItem {
                Label {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                        leftMargin: listPadding
                        rightMargin: listPadding
                    }
                    text: name
                }
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ServerEditPage.qml"),{hostname:hostname,port:port,name:name,password:password,index:index,autoconnect:autoconnect,newprofile:false});
                }
            }
    }
}