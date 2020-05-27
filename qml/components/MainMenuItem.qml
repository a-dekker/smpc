import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: gridItem
    property alias text: itemLabel.text
    property alias iconSource: itemIcon.source
    width: Theme.itemSizeHuge
    height: width
    Rectangle {
        anchors.fill: parent
        anchors.margins: Theme.paddingSmall
        color: Theme.rgba(
                   Theme.highlightBackgroundColor,
                   Theme.highlightBackgroundOpacity)
    }
    Column {
        anchors.centerIn: parent
        Image {
            id: itemIcon
            //source: icon
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
