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

LimooImage {
    id: thmbnl
    metaData.source: path

    property string path
    property bool indicator: true

    onPathChanged: {
        path_changed_timer.restart()
    }
    onIndicatorChanged: {
        if( indicator && !privates.indict && source.length == 0 )
            privates.indict = indicatorComponent.createObject(thmbnl)
        else
        if( !indicator && privates.indict )
            privates.indict.destroy()
    }

    QtObject {
        id: privates
        property variant indict
    }

    Timer {
        id: path_changed_timer
        interval: 1
        onTriggered: {
            if( thmbnl.path.length == 0 ) {
                thmbnl.source = ""
                if( privates.indict )
                    privates.indict.destroy()
            } else {
                ThumbnailLoader.load(thmbnl.path)
                if( !privates.indict && thmbnl.indicator )
                    privates.indict = indicatorComponent.createObject(thmbnl)
            }
        }
    }

    Connections {
        target: ThumbnailLoader
        onLoaded: {
            if( path == thmbnl.path ) {
                thmbnl.source = thumbnail
                if( privates.indict )
                    privates.indict.destroy()
            }
        }
    }

    Component {
        id: indicatorComponent
        Image {
            id: indict_img
            width: 22
            height: width
            anchors.centerIn: parent
            source: "files/indicator.png"
            smooth: true
            transformOrigin: Item.Center

            Behavior on rotation {
                NumberAnimation{ easing.type: Easing.Linear; duration: indict_img_timer.interval }
            }

            Timer {
                id: indict_img_timer
                interval: 250
                repeat: true
                triggeredOnStart: true
                onTriggered: indict_img.rotation += 90
                Component.onCompleted: start()
            }
        }
    }

    Component.onCompleted: if( thmbnl.indicator ) privates.indict = indicatorComponent.createObject(thmbnl)
}
