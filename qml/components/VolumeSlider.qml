import QtQuick 2.2
import Sailfish.Silica 1.0

Slider {
    id: volumeSlider

    stepSize: 1
    maximumValue: 100
    minimumValue: 0
    valueText: value + "%"
    label: qsTr("Volume")
    onPressedChanged: {
        if (!pressed) {
            ctl.player.setVolume(value)
        }
    }
    onValueChanged: {
        if (pressed)
            ctl.player.setVolume(value)
    }
    Binding {
        target: volumeSlider
        property: "value"
        value: ctl.player.playbackStatus.volume
    }
}
