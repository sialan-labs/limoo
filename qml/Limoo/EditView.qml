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
import SialanTools 1.0

Item {
    id: edit_View
    anchors.fill: parent
    opacity: 0

    Behavior on opacity {
        NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
    }

    MimeApps {
        id: mime_apps
    }

    Component.onCompleted: opacity = 1

    property variant sources

    onSourcesChanged: apps_list.refresh()

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        hoverEnabled: true
        onWheel: wheel.accepted = true
        onClicked: closeEdit()
    }

    LimooBlur {
        source: mainFrame
        visible: blurBack
    }

    Rectangle {
        anchors.fill: parent
        color: "#66ffffff"
    }

    Text {
        id: title
        x: 100
        y: 100
        font.pixelSize: 30
        font.weight: Font.Light
        font.family: SApp.globalFontFamily
        color: "#333333"
    }

    ListView {
        id: apps_list
        anchors.left: title.left
        anchors.top: title.bottom
        anchors.bottom: parent.bottom
        anchors.leftMargin: 60
        anchors.topMargin: 20
        orientation: Qt.Vertical
        width: 400
        model: ListModel{}
        clip: true
        delegate: Rectangle {
            id: item
            height: 48
            width: apps_list.width
            color: marea.pressed? "#880d80ec" : "#00000000"

            Image {
                id: img
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 4
                height: 36
                width: height
                sourceSize: Qt.size(width,height)
                source: "image://icon/" + mime_apps.appIcon(appId)
            }

            Text {
                id: txt
                anchors.left: img.right
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                font.family: SApp.globalFontFamily
                text: mime_apps.appName(appId)
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: {
                    mime_apps.openFiles(appId,edit_View.sources)
                    closeEdit()
                }
            }
        }

        function refresh() {
            model.clear()
            if( !edit_View.sources || edit_View.sources.length == 0 )
                return

            var apps = mime_apps.appsOfFile(edit_View.sources[0])
            for( var i=0; i<apps.length; i++ )
                model.append({"appId":apps[i]})
        }

        Component.onCompleted: refresh()
    }

    NormalWheelScroll {
        anchors.fill: apps_list
        flick: apps_list
    }

    PhysicalScrollBar {
        scrollArea: apps_list; height: apps_list.height; width: 8
        anchors.right: apps_list.right; anchors.top: apps_list.top; color: "#333333"
    }

    LanguageSwitcher {
        onRefresh: {
            title.text = qsTr("Select Application")
        }
    }
}
