import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
	id: serverListPage
	allowedOrientations: Orientation.All

	SilicaListView {
		id: serverListView
		model: serverList
		anchors.fill: parent
		clip: true
		contentWidth: width

		PullDownMenu {
			MenuItem {
				text: qsTr("Add server")
				onClicked: {
					console.log("Clicked option add server")
					pageStack.push(Qt.resolvedUrl("ServerEditPage.qml"), {newprofile: true})
				}
			}
		}

		ScrollDecorator {}
		header: PageHeader {
			title: qsTr("Servers")
		}
		delegate: ListItem {
			contentHeight: Theme.itemSizeSmall

			Label {
				x: Theme.paddingLarge
				anchors {
					//horizontalCenter: parent.horizontalCenter
					verticalCenter: parent.verticalCenter
					leftMargin: listPadding
					rightMargin: listPadding
				}
				text: name
			}

			function removeProfileRemorse() {
				remorseAction(qsTr("Removing server profile"), function () {
					deleteProfile(index)
				}, 3000)
			}
			menu: ContextMenu {
				MenuItem {
					text: qsTr("Remove server profile")
					onClicked: {
						removeProfileRemorse()
					}
				}
			}

			onClicked: {
				pageStack.push(Qt.resolvedUrl("ServerEditPage.qml"), {
					hostname: hostname,
					port: port,
					name: name,
					password: password,
					index: index,
					autoconnect: autoconnect,
					macaddress: macaddress,
					newprofile: false,
				})
			}
		}
	}
}
