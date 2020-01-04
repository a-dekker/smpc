import QtQuick 2.2
import Sailfish.Silica 1.0
import "../../components"

Page {
	id: connectPage
	allowedOrientations: Orientation.All

	SilicaListView {
		id: connectListView
		model: serverList
		anchors.fill: parent
		contentWidth: width
		header: PageHeader {
			title: qsTr("servers")
		}

		PullDownMenu {
			MenuItem {
				text: qsTr("Add server")
				onClicked: {
					pageStack.push(Qt.resolvedUrl("ServerEditPage.qml"), {newprofile: true})
				}
			}
		}

		ScrollDecorator {}
		delegate: ListItem {
			contentHeight: Theme.itemSizeSmall
			onClicked: {
				connectProfile(index)
				pageStack.pop()
			}

			Label {
				clip: true
				anchors {
					horizontalCenter: parent.horizontalCenter
					verticalCenter: parent.verticalCenter
					leftMargin: listPadding
					rightMargin: listPadding
				}
				text: name
			}

			function removeProfileRemorse() {
				remorseAction(qsTr("removing server profile"), function () {
					deleteProfile(index)
				}, 3000)
			}
			menu: ContextMenu {
				id: contextMenu
				MenuItem {
					id: editItem
					text: qsTr("edit server profile")
					onClicked: {
						pageStack.push(Qt.resolvedUrl("ServerEditPage.qml"), {
							hostname: hostname,
							port: port,
							name: name,
							password: password,
							index: index,
							autoconnect: autoconnect,
							macaddress: macaddress,
							newprofile: false
						})
					}
				}
				MenuItem {
					id: removeItem
					text: qsTr("remove server profile")
					onClicked: {
						removeProfileRemorse()
					}
				}
				MenuItem {
					id: wakeItem
					text: qsTr("wake server")
					onClicked: {
						wakeUpServer(index)
					}
				}
			}
		}
	}
}
