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

Rectangle {
    id: viewer_frame_back
    width: 100
    height: 62
    clip: true

    property alias imageViewer: image_viewer
    property alias basket: basket_item
    property alias viewMode: image_viewer.viewMode
    property alias basketSliderFrame: basket_slider_frame
    property alias basketSlider: basket_slider

    Rectangle {
        id: viewer_frame
        anchors.fill: parent
        color: "#202020"

        Rectangle {
            id: back_img_frame
            color: Desktop.titleBarColor
            anchors.fill: parent

            BackImage {
                id: back_img
                anchors.fill: parent
                source: defaultSource

                property string defaultSource: "files/default-background.jpg"

                property string currentPath: image_viewer.thumbnailBar.model.folder
                onCurrentPathChanged: back_img.refresh()

                function refresh() {
                    if( !blurBack )
                        return

                    var cover_path = currentPath + "/.cover"
                    if( Limoo.fileExists(cover_path) ) {
                        source = cover_path
                        refreshImage()
                        return
                    }

                    var index = -1
                    for( var i=0; i<image_viewer.thumbnailBar.model.count; i++ )
                        if( !image_viewer.thumbnailBar.model.get(i,"fileIsDir") ) {
                            index = i
                            break
                        }

                    if( index == -1 ) {
                        source = defaultSource
                        refreshImage()
                        return
                    }

                    source = image_viewer.thumbnailBar.model.get(index,"filePath")
                    refreshImage()
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#44000000"
                }

                Timer {
                    id: refresh_timer
                    interval: 500
                    onTriggered: back_img.refresh()
                }

                Component.onCompleted: refresh_timer.restart()
            }
        }

        LimooBlur {
            source: back_img_frame
            visible: blurBack
        }

        ImageViewer {
            id: image_viewer
            anchors.fill: parent
            anchors.leftMargin: basket_item.visible? basket_item.width : 0
            headerHeight: toolbar_frame.height
            onAddSelect: basket_item.add(filePath)
        }
    }

    Basket {
        id: basket_item
        anchors.left: parent.left
        anchors.top: toolbar_frame.bottom
        anchors.bottom: parent.bottom
        onSelected: {
            basket_slider_frame.visible = true
            basket_slider.unzoom()
            basket_slider.source = filePath
        }
        onRemoved: {
            if( basket_slider.source != filePath )
                return

            basket_slider_frame.visible = false
            basket_slider.source = ""
        }
        onCleared: {
            basket_slider_frame.visible = false
            basket_slider.source = ""
        }

        Rectangle {
            id: basket_slider_frame
            color: "#000000"
            anchors.left: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: main_frame.width - parent.width
            visible: false
            clip: true

            ImageSliderItem {
                id: basket_slider
                anchors.fill: parent
            }
        }
    }

    Item {
        id: toolbar_frame
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Limoo.fullScreen && viewMode? 0 : 40*physicalPlatformScale
        clip: true

        LimooBlur {
            source: viewer_frame
            visible: blurBack
            anchors.fill: toolbar
        }

        ToolBar {
            id: toolbar
            anchors.fill: parent
        }
    }

    function refreshCover() {
        back_img.refresh()
    }
}
