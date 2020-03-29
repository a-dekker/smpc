import QtQuick 2.2
import Sailfish.Silica 1.0

Dialog {
	id: serverEditPage
	allowedOrientations: Orientation.All

	property alias name: profilenameInputField.text
	property alias hostname: hostnameInputField.text
	property alias password: passwordInputField.text
	property alias port: portInputField.text
	property alias streamingport: streamingPortInputField.text
	property alias autoconnect: autoconnectSwitch.checked
	property alias macaddress: macAddressField.text
	property int index
	property bool newprofile

	SilicaFlickable {
		id: serverSettingFlickable
		anchors.fill: parent
		clip: true
		contentHeight: settingsContent.height + 20

		PullDownMenu {
			MenuItem {
				text: qsTr("Remove server profile")
				onClicked: {
					pageStack.pop()
					deleteProfile(index)
				}
			}
		}

		VerticalScrollDecorator {}
		Column {
			id: settingsContent
			clip: true
			anchors {
				right: parent.right
				left: parent.left
				verticalCenter: parent.verticalCenter
				leftMargin: listPadding
				rightMargin: listPadding
			}

			DialogHeader {
				title: qsTr("Edit profile")
			}

			Label {
				anchors.right: parent.right
				anchors.left: parent.left
				text: qsTr("Profilename:")
			}
			TextField {
				anchors.right: parent.right
				anchors.left: parent.left
				id: profilenameInputField
				placeholderText: qsTr("Input profilename")
				inputMethodHints: Qt.ImhNoPredictiveText
			}

			Label {
				anchors.right: parent.right
				anchors.left: parent.left
				text: qsTr("Hostname:")
			}
			TextField {
				anchors.right: parent.right
				anchors.left: parent.left
				id: hostnameInputField
				placeholderText: qsTr("Input hostname or IP")
				inputMethodHints: Qt.ImhNoPredictiveText
			}

			Label {
				anchors.right: parent.right
				anchors.left: parent.left
				text: qsTr("Port:")
			}
			TextField {
				anchors.right: parent.right
				anchors.left: parent.left
				id: portInputField
				text: "6600"
				inputMethodHints: Qt.ImhFormattedNumbersOnly
				validator: portvalidator
			}

			Label {
				anchors.right: parent.right
				anchors.left: parent.left
				text: qsTr("Password:")
			}
			TextField {
				anchors.right: parent.right
				anchors.left: parent.left
				id: passwordInputField
				inputMethodHints: Qt.ImhNoPredictiveText
				echoMode: TextInput.Password
			}

			Label {
				visible: false
				anchors.right: parent.right
				anchors.left: parent.left
				text: qsTr("Streaming port:")
			}
			TextField {
				anchors.right: parent.right
				anchors.left: parent.left
				id: streamingPortInputField
				text: "8081"
				inputMethodHints: Qt.ImhFormattedNumbersOnly
				validator: portvalidator
				visible: false
			}

			Label {
				anchors.right: parent.right
				anchors.left: parent.left
				text:qsTr("MAC Address:")
			}
			TextField {
				anchors.right: parent.right
				anchors.left: parent.left
				id: macAddressField
				placeholderText: "Optional for wake on lan"
				labelVisible: true
				inputMethodHints: Qt.ImhPreferLowercase | Qt.ImhNoPredictiveText
				validator: macValidator
				visible: true
			}

			TextSwitch {
				anchors.right: parent.right
				anchors.left: parent.left
				id: autoconnectSwitch
				text: qsTr("Autoconnect")
			}
		}
	}

	onAccepted: {
		if (newprofile) {
			newProfile([index, name, hostname, password, port, autoconnect ? 1 : 0, macAddressField.text])
		} else {
			changeProfile([index, name, hostname, password, port, autoconnect ? 1 : 0, macAddressField.text])
		}
	}

	IntValidator {
		id: portvalidator
		top: 65536
		bottom: 1
	}

	RegExpValidator {
		id: macValidator
		regExp: /[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}/
	}
}
