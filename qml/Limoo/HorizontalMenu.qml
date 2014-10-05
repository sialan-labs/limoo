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
import SialanTools 1.0

Rectangle {
    id: hmenu
    width: 100
    height: 62
    color: blurBack? "#333333" : Desktop.titleBarColor
    visible: false

    property real menuHeight: 100
    property real menuY: 200
    property bool showMenu: false
    property variant source
    property variant item
    property real duration: 250

    onItemChanged: {
        if( !item )
            return

        item.parent = menu_frame
        item.anchors.fill = menu_frame
    }

    onShowMenuChanged: {
        hide_timer.stop()
        if( showMenu )
            visible = true
        else {
            destroy_timer.restart()
            hide_timer.start()
        }
    }

    Timer {
        id: destroy_timer
        interval: hmenu.duration
        repeat: false
        onTriggered: if(hmenu.item) hmenu.item.destroy()
    }

    MouseArea {
        hoverEnabled: true
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: hmenu.showMenu = false
    }

    Timer {
        id: hide_timer
        interval: hmenu.duration
        repeat: false
        onTriggered: hmenu.visible = false
    }

    Item {
        id: top_frame
        anchors.left: parent.left
        anchors.right: parent.right
        y: 0 + padd
        height: hmenu.menuY
        clip: true

        property real padd: hmenu.showMenu? -hmenu.menuHeight/2 : 0

        Desaturate {
            source: hmenu.source
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: hmenu.height
        }

        Behavior on padd {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: hmenu.duration }
        }
    }

    Item {
        id: menu_frame
        anchors.top: top_frame.bottom
        anchors.bottom: btm_frame.top
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true
    }

    Item {
        id: btm_frame
        anchors.left: parent.left
        anchors.right: parent.right
        y: hmenu.menuY + padd
        height: hmenu.height-hmenu.menuY
        clip: true

        property real padd: hmenu.showMenu? hmenu.menuHeight/2 : 0

        Desaturate {
            source: hmenu.source
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: hmenu.height
        }

        Behavior on padd {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: hmenu.duration }
        }
    }
}
