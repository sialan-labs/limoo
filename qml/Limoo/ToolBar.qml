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
import org.aseman.limoo 1.0
import AsemanTools 1.0

Rectangle {
    id: toolbar
    height: 40*physicalPlatformScale
    clip: true
    color: blurBack && Desktop.desktopSession != AsemanDesktopTools.Unity? Desktop.titleBarTransparentColor : Desktop.titleBarColor

    Rectangle {
        anchors.fill: parent
        opacity: Desktop.desktopSession != AsemanDesktopTools.Unity && Desktop.desktopSession != AsemanDesktopTools.Gnome && Desktop.desktopSession != AsemanDesktopTools.Mac? 0 : 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#20000000" }
            GradientStop { position: 0.7; color: "#00000000" }
            GradientStop { position: 1.0; color: "#05000000" }
        }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1*physicalPlatformScale
        opacity: Desktop.desktopSession != AsemanDesktopTools.Unity && Desktop.desktopSession != AsemanDesktopTools.Gnome && Desktop.desktopSession != AsemanDesktopTools.Mac? 0 : 1
        color: "#22000000"
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
    }

    Row {
        anchors.top: parent.top
        anchors.topMargin: 1*physicalPlatformScale
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        spacing: 6*physicalPlatformScale

        Button {
            id: back_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: Desktop.titleBarIsDark? "files/go-previous-light.png" : "files/go-previous.png"
            textColor: Desktop.titleBarTextColor
            highlightColor: "#22000000"
            onClicked: main.back()
        }

        Button {
            id: openw_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: Desktop.titleBarIsDark? "files/openwidth.png" : "files/openwidth-dark.png"
            textColor: Desktop.titleBarTextColor
            highlightColor: "#22000000"
            visible: viewMode
            onClicked: main.edit([main.mainFrame.imageViewer.thumbnailBar.currentPath])
        }

        Button {
            id: rleft_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: Desktop.titleBarIsDark? "files/rotate-left-light.png" : "files/rotate-left.png"
            textColor: Desktop.titleBarTextColor
            highlightColor: "#22000000"
            visible: viewMode
            onClicked: main.mainFrame.imageViewer.imageSlider.rotateRight()
        }

        Button {
            id: rright_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: Desktop.titleBarIsDark? "files/rotate-right-light.png" : "files/rotate-right.png"
            textColor: Desktop.titleBarTextColor
            highlightColor: "#22000000"
            visible: viewMode
            onClicked: main.mainFrame.imageViewer.imageSlider.rotateLeft()
        }

        Button {
            id: fcr_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: Desktop.titleBarIsDark? "files/view-fullscreen-light.png" : "files/view-fullscreen.png"
            textColor: Desktop.titleBarTextColor
            highlightColor: "#22000000"
            onClicked: Limoo.fullScreen = !Limoo.fullScreen
        }

        Button {
            id: limoo_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: Desktop.titleBarIsDark? "files/help-about-light.png" : "files/help-about.png"
            textColor: Desktop.titleBarTextColor
            highlightColor: "#22000000"
            onClicked: main.about = true
        }

        Button {
            id: aseman_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: Desktop.titleBarIsDark? "files/aseman-light.png" : "files/aseman-black.png"
            iconHeight: 20
            textColor: Desktop.titleBarTextColor
            highlightColor: "#22000000"
            onClicked: main.aboutAseman = true
        }
    }

    Button {
        id: conf_btn
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.topMargin: 1*physicalPlatformScale
        icon: Desktop.titleBarIsDark? "files/configure_light.png" : "files/configure.png"
        iconHeight: 20
        textColor: Desktop.titleBarTextColor
        highlightColor: "#22000000"
        onClicked: configure = !configure
    }

    LanguageSwitcher {
        onRefresh: {
            back_btn.text = qsTr("Back")
            openw_btn.text = qsTr("Open With")
            rleft_btn.text = qsTr("Rotate Left")
            rright_btn.text = qsTr("Rotate Right")
            fcr_btn.text = qsTr("Fullscreen")
            limoo_btn.text = qsTr("Limoo")
            aseman_btn.text = qsTr("Aseman")
            conf_btn.text = qsTr("Configure")
        }
    }
}
