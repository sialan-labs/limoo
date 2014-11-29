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
import QtGraphicalEffects 1.0
import AsemanTools 1.0

Item {
    id: limoo_blur
    width: source.width
    height: source.height

    property alias source: desat.source
    property alias radius: blur.radius

    Rectangle {
        id: mask
        clip: true
        anchors.fill: parent
        visible: false

        Desaturate {
            id: desat
            width: source.width
            height: source.height
            cached: false
        }
    }

    FastBlur {
        id: blur
        source: mask
        anchors.fill: parent
        radius: blurBack? 64 : 0
        cached: false
//        visible: false
    }
}
