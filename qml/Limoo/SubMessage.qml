/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Limoo is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Limoo is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: submsg
    anchors.fill: parent
    opacity: 0
    visible: opacity != 0

    property variant item
    property alias source: desaturate.source

    Behavior on opacity {
        NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
    }

    Timer {
        id: destroy_timer
        interval: 400
        repeat: false
        onTriggered: submsg.destroy()
    }

    onItemChanged: {
        if( !item ) {
            opacity = 0
            destroy_timer.restart()
        } else {
            item.parent = submsg
            opacity = 1
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
    }

    Desaturate {
        id: desaturate
        anchors.fill: parent
        desaturation: 0
        visible: false
        cached: true
    }

    FastBlur {
        id: blur
        anchors.fill: parent
        source: desaturate
        radius: 64*physicalPlatformScale
        cached: true
    }

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        opacity: 0.4
    }

    function hide() {
        if( item && item.hide )
            item.hide()

        opacity = 0
        destroy_timer.restart()
    }

    Component.onCompleted: subMessage = submsg
    Component.onDestruction: if( item ) item.destroy()
}
