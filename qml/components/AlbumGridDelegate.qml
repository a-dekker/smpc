import QtQuick 2.2
import Sailfish.Silica 1.0

ListItem {
    property alias title: titleLbl.text
    property alias artist: artistLbl.text
    property alias cover: albumImage.source

    width: GridView.view.cellWidth
    contentHeight: GridView.view.cellHeight

    layer.enabled: true
    layer.effect: ShaderEffect {
        blending: highlighted
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: Theme.paddingSmall
        color: Theme.rgba(Theme.highlightBackgroundColor, 0.2)
        Image {
            id: albumImage
            anchors.fill: parent
            //source: GridView.view.scrolling ? "" : coverURL
            cache: false
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
        }
        Rectangle {
            id: gradientRect
            anchors {
                bottom: parent.bottom
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width

            gradient: Gradient {
                GradientStop {
                    position: 0.5
                    color: Qt.rgba(0.0, 0.0, 0.0, 0.0)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(0.0, 0.0, 0.0, 0.8)
                }
            }
        }
        Rectangle {
            id: gradientRectTop
            visible: showArtistOnCover
            anchors {
                bottom: parent.bottom
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(0.0, 0.0, 0.0, 0.8)
                }
                GradientStop {
                    position: 0.5
                    color: Qt.rgba(0.0, 0.0, 0.0, 0.0)
                }
            }
        }
        Label {
            id: artistLbl
            visible: showArtistOnCover
            anchors {
                top: albumImage.top
                horizontalCenter: albumImage.horizontalCenter
            }
            height: parent.height * 0.5
            width: parent.width
            wrapMode: "WordWrap"
            elide: Text.ElideRight
            font.pixelSize: Theme.fontSizeSmall
            style: isLightTheme ? Text.Outline : Text.Raised
            styleColor: isLightTheme ? "#CCCCCC" : Theme.darkSecondaryColor
            color: Theme.secondaryColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
        }
        Label {
            id: titleLbl
            anchors {
                bottom: albumImage.bottom
                horizontalCenter: albumImage.horizontalCenter
            }
            height: parent.height * 0.5
            width: parent.width
            wrapMode: "WordWrap"
            elide: Text.ElideRight
            font.pixelSize: Theme.fontSizeSmall
            style: isLightTheme ? Text.Outline : Text.Raised
            color: Theme.primaryColor
            styleColor: isLightTheme ? "#FFFFFF" : Theme.primaryColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignBottom
            //text: title === "" ? qsTr("No album tag") : title
        }
    }
}
