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

AsemanMain {
    id: main
    width: 960
    height: 600
    focus: true
    mainFrame: main_frame

    property alias viewMode: main_frame.viewMode

    property alias imageViewer: main_frame.imageViewer
    property alias basket: main_frame.basket
    property variant editView

    property bool blurBack: true

    property bool about: false
    property bool aboutAseman: false
    property bool configure: false

    AboutAseman {
        anchors.fill: parent
        start: aboutAseman
    }

    Configure {
        id: conf
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 300*physicalPlatformScale
        visible: main_scene.y == 0
    }

    Item {
        id: main_scene
        y: aboutAseman? parent.height : 0
        x: configure? -conf.width : 0
        width: parent.width
        height: parent.height
        clip: true

        Behavior on y {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }
        Behavior on x {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        AboutPage {
            anchors.fill: parent
        }

        ViewerFrame {
            id: main_frame
            x: about? parent.width : 0
            width: parent.width
            height: parent.height
            clip: true

            Behavior on x {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }
        }
    }

    Connections {
        target: Encypter
        onStarted: showSubMessageFile("PleaseWait.qml")
        onDone: hideSubMessage()
    }

    MouseArea {
        id: click_back
        hoverEnabled: true
        anchors.fill: main_scene
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onWheel: wheel.accepted = true
        visible: configure
        onClicked: back()
    }

    HorizontalMenu {
        id: hmenu
        anchors.fill: parent
        source: main_frame
    }

    Component {
        id: edit_view_cmpnt
        EditView{
            anchors.fill: parent
        }
    }

    Keys.onEscapePressed: back()
    Keys.onRightPressed: imageViewer.thumbnailBar.next()
    Keys.onLeftPressed: imageViewer.thumbnailBar.prev()
    Keys.onUpPressed: imageViewer.thumbnailBar.prev()
    Keys.onDownPressed: imageViewer.thumbnailBar.next()
    Keys.onPressed: {
        if( event.key == Qt.Key_Backspace && event.modifiers == Qt.NoModifier )
            imageViewer.thumbnailBar.prev()
        else
        if( event.key == Qt.Key_Space && event.modifiers == Qt.NoModifier )
            imageViewer.thumbnailBar.next()
        else
        if( event.key == Qt.Key_H && event.modifiers == Qt.ControlModifier )
            imageViewer.showHidden = !imageViewer.showHidden
        else
        if( event.key == Qt.Key_C && event.modifiers == Qt.ControlModifier ) {
            if( !viewMode )
                return

            Limoo.setCopyClipboardUrl( imageViewer.thumbnailBar.currentPath )
        }
        else
        if( event.key == Qt.Key_X && event.modifiers == Qt.ControlModifier ) {
            if( !viewMode )
                return

            Limoo.setCutClipboardUrl( imageViewer.thumbnailBar.currentPath )
        }
        else
        if( event.key == Qt.Key_V ) {
            if( viewMode )
                return

            Limoo.pasteClipboardFiles(imageViewer.thumbnailBar.model.folder)
        }
        else
        if( event.key == Qt.Key_Delete && event.modifiers == Qt.ShiftModifier ) {
            var item = showSubMessageFile("ImageDeleteDialog.qml")
            item.sources = [imageViewer.thumbnailBar.currentPath]
        }
    }

    function showSubMessageFile( file_path ){
        var component = Qt.createComponent(file_path);
        return showSubMessage(component)
    }

    function showMenu( fileName, itemY, itemHeight ) {
        var component = Qt.createComponent(fileName)
        var object = component.createObject(hmenu)
        hmenu.item = object
        hmenu.menuY = itemY
        hmenu.menuHeight = itemHeight
        hmenu.showMenu = true
        return object
    }

    function hideMenu() {
        hmenu.showMenu = false
    }

    function editCurrent() {
        var path = mainFrame.imageViewer.thumbnailBar.currentPath
        if( path.length == 0 || !viewMode )
            return

        edit(path)
    }

    function edit( paths ) {
        closeEdit()
        editView = edit_view_cmpnt.createObject(main)
        editView.sources = paths
    }

    function closeEdit() {
        if( !editView )
            return

        editView.destroy()
    }

    function back() {
        if( configure )
            configure = false
        else
        if( aboutAseman )
            aboutAseman = false
        else
        if( about )
            about = false
        else
        if( editView )
            closeEdit()
        else
        if( hmenu.showMenu )
            hmenu.showMenu = false
        else
        if( subMessage )
            hideSubMessage()
        else
        if( main_frame.basketSliderFrame.visible ) {
            main_frame.basketSliderFrame.visible = false
            main_frame.basketSlider.source = ""
        }
        else
        if( !imageViewer.back() )
            return
    }
}
