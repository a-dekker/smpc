import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../components"

Page {
    id: settingsPage
    SilicaFlickable {
        anchors.fill: parent
        Column {
            id: column
            width: settingsPage.width
            SilicaListView {
                id: settingsListView
                clip: true
                height: mDebugEnabled ? settingsPage.height - showDebug.height : settingsPage.height
                width: parent.width
                header: PageHeader {
                    title: qsTr("Settings")
                }
                VerticalScrollDecorator {}
                model: settingsMenuModel
                delegate: MouseArea {

                    width: parent.width
                    height: lbl.height + Theme.paddingLarge * 2

                    Image {
                        id: image
                        source: "image://theme/" + img
                        x: Theme.paddingLarge
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                        opacity: parent.enabled ? 1.0 : 0.4
                    }

                    Label {
                        id: lbl
                        clip: true
                        x: Theme.paddingLarge
                        anchors {
                            left: image.right
                            verticalCenter: parent.verticalCenter
                            leftMargin: listPadding
                            rightMargin: listPadding
                        }
                        color: parent.pressed ? Theme.highlightColor : Theme.primaryColor
                        text: name
                        width: parent.width - image.width - 2 * listPadding
                        truncationMode: TruncationMode.Fade
                    }
                    Rectangle {
                        width: parent.width
                        height: parent.height
                        color: Theme.secondaryHighlightColor
                        opacity: parent.pressed ? .25 : 0
                    }
                    onClicked: {
                        parseClickedSettings(ident)
                    }
                }
            }
            TextSwitch {
                id: showDebug
                visible: mDebugEnabled
                text: qsTr("Debuglog output to console")
                description: qsTr("for troubleshooting, requires restart")
                checked: showDebugLog
                onClicked: {
                    if (checked) {
                        newSettingKey(["showDebugLog", "true"])
                        resourceHandler.acquire()
                    } else {
                        newSettingKey(["showDebugLog", "false"])
                        resourceHandler.release()
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        settingsMenuModel.append({
                                     "name": qsTr("Server settings"),
                                     "ident": "servers",
                                     "img": "icon-m-computer"
                                 })
        settingsMenuModel.append({
                                     "name": qsTr("Database settings"),
                                     "ident": "database",
                                     "img": "icon-m-levels"
                                 })
        settingsMenuModel.append({
                                     "name": qsTr("Gui settings"),
                                     "ident": "guisettings",
                                     "img": "icon-m-display"
                                 })
        settingsMenuModel.append({
                                     "name": qsTr("Playback settings"),
                                     "ident": "playback",
                                     "img": "icon-m-music"
                                 })
        settingsMenuModel.append({
                                     "name": qsTr("Outputs"),
                                     "ident": "outputs",
                                     "img": "icon-m-accessory-speaker"
                                 })
        settingsMenuModel.append({
                                     "name": qsTr("Update server database"),
                                     "ident": "updatedb",
                                     "img": "icon-m-refresh"
                                 })
        // Debug-only
        if (mDebugEnabled) {
            settingsMenuModel.append({
                                         "name": qsTr("Garbage collection"),
                                         "ident": "gc",
                                         "img": "icon-m-diagnostic"
                                     })
        }
    }

    ListModel {
        id: settingsMenuModel
    }

    function parseClickedSettings(ident) {
        switch (ident) {
        case "about":
            pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            break
        case "servers":
            pageStack.push(Qt.resolvedUrl("ServerListPage.qml"))
            break
        case "updatedb":
            updateDB()
            break
        case "outputs":
            requestOutputs()
            pageStack.push(Qt.resolvedUrl("OutputsPage.qml"))
            break
        case "playback":
            pageStack.push(Qt.resolvedUrl("PlaybackSettings.qml"))
            break
        case "database":
            pageStack.push(Qt.resolvedUrl("DatabaseSettings.qml"))
            break
        case "guisettings":
            pageStack.push(Qt.resolvedUrl("GUISettings.qml"))
            break
        case "gc":
            console.debug("Calling garbage collection")
            gc()
            console.debug("Called garbage collection")
            break
        }
    }
}
