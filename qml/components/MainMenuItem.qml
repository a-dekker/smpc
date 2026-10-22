import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: gridItem
    property alias text: itemLabel.text
    property alias iconSource: itemIcon.source
    width: GridView.view ? GridView.view.cellWidth : Theme.itemSizeHuge
    height: width
    Rectangle {
        anchors.fill: parent
        anchors.margins: Theme.paddingSmall
        color: Theme.rgba(Theme.highlightBackgroundColor,
                          Theme.highlightBackgroundOpacity)
    }
    Column {
        anchors.centerIn: parent
        Image {
            id: itemIcon
            // scale the icon along with the button size
            property real size: Theme.iconSizeMedium * gridItem.width / Theme.itemSizeHuge
            width: size
            height: size
            sourceSize: Qt.size(size, size)
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            id: itemLabel
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            font.pixelSize: Theme.fontSizeMedium
            width: gridItem.width - (2 * Theme.paddingSmall)
            horizontalAlignment: "AlignHCenter"
            scale: paintedWidth > width ? (width / paintedWidth) : 1
            //text: name
        }
    }
}
