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

Rectangle {
    id: viewer
    width: 100
    height: 62
    color: "#00000000"

    property bool viewMode: Limoo.startViewMode
    property real thumbnailBarWidth: Limoo.thumbnailBar? 100*physicalPlatformScale : 0

    property alias imageSlider: img_slider
    property alias thumbnailBar: tmb_bar

    property real headerHeight: 0

    property bool showHidden: false

    property bool anim: false

    signal addSelect( string filePath )

    onViewModeChanged: {
        anim = true
        anim_disabler.restart()
        show_btn.opacityAdded = 0.6
        glow_timer.restart()
    }

    Timer {
        id: anim_disabler
        interval: show_step_timer.interval
        repeat: false
        onTriggered: viewer.anim = false
    }

    QtObject {
        id: privates
        property bool hide_step: false
    }

    Rectangle {
        id: slider_frame
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: thumbnailbar_frame.left
        width: parent.width-thumbnailBarWidth
        opacity: viewer.viewMode? 1 : 0
        clip: true
        color: Limoo.titleBarColor

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        Rectangle {
            id: slider_back
            color: "#000000"
            anchors.fill: img_slider
        }

        ImageSlider {
            id: img_slider
            anchors.fill: parent
            anchors.topMargin: viewer.headerHeight
            showHidden: viewer.showHidden
            filters: tmb_bar.filters
            onCurrentItemChanged: {
                if( tmb_bar.currentPath == currentItem )
                    return

                tmb_bar.currentPath = currentItem
                tmb_bar.setCurrent(currentItem)
            }
        }
    }

    Button {
        id: show_btn
        anchors.verticalCenter: thumbnailbar_frame.verticalCenter
        anchors.right: thumbnailbar_frame.left
        height: 40*physicalPlatformScale
        width: 13*physicalPlatformScale
        onClicked: Limoo.thumbnailBar = !Limoo.thumbnailBar
        normalColor: "#88000000"
        highlightColor: "#880d80ec"
        opacity: opacityAdded + (enter? 0.8 : 0.2)
        radius: 0
        text: Limoo.thumbnailBar? ">" : "<"
        textColor: "#ffffff"
        cursorShape: Qt.PointingHandCursor

        property real opacityAdded: 0

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 800 }
        }

        Connections {
            target: Limoo
            onThumbnailBarChanged: {
                show_btn.opacityAdded = 0.4
                glow_timer.restart()
            }
        }

        Timer {
            id: glow_timer
            interval: 400
            repeat: false
            onTriggered: show_btn.opacityAdded = 0
        }
    }

    Rectangle {
        id: thumbnailbar_frame
        x: parent.width - width
        width: main.viewMode? thumbnailBarWidth : parent.width
        height: parent.height
        color: main.viewMode && Limoo.fullScreen? "#202020" : "#00000000"

        Behavior on width {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: viewer.anim? show_step_timer.interval : 0 }
        }
        Behavior on color {
            ColorAnimation{ easing.type: Easing.OutCubic; duration: viewer.anim? show_step_timer.interval : 0 }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            height: 40*physicalPlatformScale
            color: Limoo.titleBarColor
            opacity: viewMode? 1 : 0
            visible: !Limoo.fullScreen

            Behavior on opacity {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }
        }

        ThumbnailBar {
            id: tmb_bar
            width: visible? parent.width : thumbnailBarWidth
            height: parent.height
            opacity: privates.hide_step? 0 : 1
            visible: opacity != 0
            showHidden: viewer.showHidden
            onCurrentIndexChanged: img_slider.setCurrentImmedietly(currentPath)
            onAddSelect: viewer.addSelect(filePath)
            headerHeight: viewer.headerHeight
            onVisibleChanged: {
                if( visible )
                    return_timer.restart()
            }

            Timer {
                id: return_timer
                interval: 500
                repeat: false
                onTriggered: {
                    if( tmb_bar.visible )
                        tmb_bar.setCurrent(tmb_bar.currentPath)

                    tmb_bar.forceLayout()
                }
            }

            Behavior on opacity {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: hide_step_timer.interval }
            }

            onSelected: {
                var filePath = currentPath
                var folder = tmb_bar.folder()

                img_slider.source = folder
                img_slider.setCurrent( filePath )

                if( !viewer.viewMode ) {
                    privates.hide_step = true
                    hide_step_timer.back_step = false
                    hide_step_timer.restart()
                } else {
                    hide_step_timer.done()
                }
            }
        }
    }

    Timer {
        id: hide_step_timer
        interval: Limoo.initialized*150
        repeat: false
        onTriggered: done()

        function done() {
            if( back_step ) {
                viewer.viewMode = false
                show_step_timer.restart()
            } else {
                if( !viewer.viewMode )
                    show_step_timer.restart()
                viewer.viewMode = true
            }
        }

        property bool back_step: false
    }

    Timer {
        id: show_step_timer
        interval: Limoo.initialized*400
        repeat: false
        onTriggered: {
            privates.hide_step = false
            tmb_bar.setCurrent( tmb_bar.currentPath )
        }
    }

    function back() {
        if( viewer.viewMode ) {
            hide_step_timer.back_step = true
            privates.hide_step = true
            hide_step_timer.restart()
        }
        else
        if( tmb_bar.back() )
            ;
        else
            return false
        return true
    }

    Timer {
        id: cunstruct_timer
        interval: 300
        repeat: false
        onTriggered: {
            img_slider.setCurrent( Limoo.inputPath )
            tmb_bar.setCurrent( Limoo.inputPath )
        }
    }

    Component.onCompleted: {
        if( Limoo.startViewMode ) {
            img_slider.source = Limoo.startDirectory
            img_slider.setCurrent( Limoo.inputPath )
            cunstruct_timer.restart()
        }
    }
}
