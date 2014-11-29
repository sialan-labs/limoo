/*
    Copyright (C) 2014 Aseman
    http://aseman.co

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
import AsemanTools 1.0

Item {
    id: back_img
    width: 100
    height: 62

    property string source

    QtObject {
        id: privates
        property variant currentItem
    }

    Item {
        id: imgs_frame
        anchors.fill: parent
        clip: true
    }

    Component {
        id: img_cmpnt
        Image {
            id: img_item
            anchors.fill: parent
            onStatusChanged: if( status == Image.Ready ) show()
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            verticalAlignment: Image.AlignTop
            smooth: true
            sourceSize: Qt.size(width,height)
            opacity: 0
            cache: false

            signal imageIsReady()

            Behavior on opacity {
                NumberAnimation{ duration: destroy_timer.interval }
            }

            function show() {
                opacity = 1
                imageIsReady()
            }

            function hide() {
                if(destroy_timer) destroy_timer.restart()
            }

            function slowHide() {
                opacity = 0
                hide()
            }

            Timer {
                id: destroy_timer
                interval: 300
                repeat: false
                onTriggered: img_item.destroy()
            }
        }
    }

    function refreshImage() {
        if( source.length == 0 ) {
            if( privates.currentItem )
                privates.currentItem.slowHide()

            return
        }

        var item = img_cmpnt.createObject(imgs_frame)

        if( privates.currentItem )
            item.imageIsReady.connect(privates.currentItem.hide)

        item.source = source
        privates.currentItem = item
    }
}
