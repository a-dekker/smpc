import QtQuick 2.2
import Sailfish.Silica 1.0

Component {
	ListItem {
		layer.enabled: true
		layer.effect: ShaderEffect {
			blending: highlighted
		}

		width: GridView.view.cellWidth
		height: width
		contentHeight: width

		Rectangle {
			anchors.fill: parent
			anchors.margins: Theme.paddingSmall
			color: Theme.rgba(Theme.highlightBackgroundColor, 0.2)

			Image {
				id: artistImage
				anchors.fill: parent
				source: artistGridView.scrolling ? "" : imageURL
				cache: false
				asynchronous: true
				fillMode: Image.PreserveAspectFit
				onSourceSizeChanged: {
					console.debug("Source size: " + sourceSize.width + ":" + sourceSize.height)
				}
			}

			Rectangle {
				id: gradientRect
				visible: true //artistImage.source!=""
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

			Label {
				anchors {
					bottom: artistImage.bottom
					horizontalCenter: artistImage.horizontalCenter
				}
				height: parent.height * 0.5
				width: parent.width
				wrapMode: "WordWrap"
				elide: Text.ElideRight
				font.pixelSize: Theme.fontSizeSmall
				style: Text.Raised
				styleColor: Theme.secondaryColor
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignBottom
				text: artist === "" ? qsTr("No Artist Tag") : artist
			}
		}

		onClicked: {
			artistGridView.currentIndex = index
			artistClicked(artist)
			pageStack.push(Qt.resolvedUrl("../pages/database/AlbumListPage.qml"), {artistname: artistname})
		}
	}
}
