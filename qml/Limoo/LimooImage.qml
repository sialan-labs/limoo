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
import org.sialan.limoo 1.0
import SialanTools 1.0

Item {
    id: lm_img
    width: 100
    height: 62

    property size sourceSize: img.fakeSourceSize
    property real paintedHeight
    property real paintedWidth

    property alias asynchronous: img.asynchronous
    property alias cache: img.cache
    property alias fillMode: img.fillMode
    property alias horizontalAlignment: img.horizontalAlignment
    property alias mirror: img.mirror
    property alias progress: img.progress
    property alias smooth: img.smooth
    property alias source: path_handler.input
    property alias status: img.status
    property alias verticalAlignment: img.verticalAlignment

    property alias metaData: meta_data

    onSourceSizeChanged: refreshRootSourceSize()

    PathHandler {
        id: path_handler
    }

    Image {
        id: img
        width: unnormal? parent.height : parent.width
        height: unnormal? parent.width : parent.height
        anchors.centerIn: parent
        transformOrigin: Item.Center
        rotation: meta_data.orientationDegree(meta_data.orientation)
        source: path_handler.output

        onSourceSizeChanged: refreshSourceSize()
        onPaintedHeightChanged: refreshPaintedHeight()
        onPaintedWidthChanged: refreshPaintedWidth()

        property size fakeSourceSize: sourceSize
        property bool unnormal: meta_data.orientation == ImageMetaData.Left ||
                                meta_data.orientation == ImageMetaData.Right

        function refreshSourceSize() {
            switch( meta_data.orientation )
            {
            case ImageMetaData.Left:
            case ImageMetaData.Right:
                fakeSourceSize.width  = sourceSize.height
                fakeSourceSize.height = sourceSize.width
                break;

            case ImageMetaData.Normal:
            case ImageMetaData.Full:
                fakeSourceSize = sourceSize
                break;
            }
        }

        function refreshPaintedHeight() {
            switch( meta_data.orientation )
            {
            case ImageMetaData.Left:
            case ImageMetaData.Right:
                lm_img.paintedWidth = paintedHeight
                break;

            case ImageMetaData.Normal:
            case ImageMetaData.Full:
                lm_img.paintedHeight = paintedHeight
                break;
            }
        }

        function refreshPaintedWidth() {
            switch( meta_data.orientation )
            {
            case ImageMetaData.Left:
            case ImageMetaData.Right:
                lm_img.paintedHeight = paintedWidth
                break;

            case ImageMetaData.Normal:
            case ImageMetaData.Full:
                lm_img.paintedWidth = paintedWidth
                break;
            }
        }
    }

    ImageMetaData {
        id: meta_data
        source: img.source
        onOrientationChanged: {
            refreshRootSourceSize()
            img.refreshPaintedHeight()
            img.refreshPaintedWidth()
        }

        function orientationDegree( ori ) {
            switch( ori )
            {
            case ImageMetaData.Left:
                return 90
                break;
            case ImageMetaData.Right:
                return -90
                break;
            case ImageMetaData.Normal:
                return 0
                break;
            case ImageMetaData.Full:
                return 180
                break;
            }

            return 0
        }
    }

    function refreshRootSourceSize() {
        switch( meta_data.orientation )
        {
        case ImageMetaData.Left:
        case ImageMetaData.Right:
            img.sourceSize.width  = sourceSize.height
            img.sourceSize.height = sourceSize.width
            break;

        case ImageMetaData.Normal:
        case ImageMetaData.Full:
            img.sourceSize = sourceSize
            break;
        }
    }

    function rotateLeft() {
        switch( meta_data.orientation )
        {
        case ImageMetaData.Left:
            meta_data.orientation = ImageMetaData.Full
            break;

        case ImageMetaData.Right:
            meta_data.orientation = ImageMetaData.Normal
            break;

        case ImageMetaData.Normal:
            meta_data.orientation = ImageMetaData.Left
            break;

        case ImageMetaData.Full:
            meta_data.orientation = ImageMetaData.Right
            break;
        }
    }

    function rotateRight() {
        switch( meta_data.orientation )
        {
        case ImageMetaData.Left:
            meta_data.orientation = ImageMetaData.Normal
            break;

        case ImageMetaData.Right:
            meta_data.orientation = ImageMetaData.Full
            break;

        case ImageMetaData.Normal:
            meta_data.orientation = ImageMetaData.Right
            break;

        case ImageMetaData.Full:
            meta_data.orientation = ImageMetaData.Left
            break;
        }
    }
}
