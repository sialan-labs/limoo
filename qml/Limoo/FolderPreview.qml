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
    id: fpreview
    width: 100
    height: 62
    radius: 3*physicalPlatformScale
    color: "#66ffffff"

    property int count: 4
    property string path
    property variant filter
    property variant files: path.length==0? new Array : Limoo.folderEntry(path,filter,count)

    QtObject {
        id: privates

        property variant items: new Array
    }

    onFilesChanged: {
        for( var i=0; i<privates.items.length; i++ )
            privates.items[i].destroy()

        for( var i=0; i<files.length; i++ ) {
            var obj = preview_component.createObject(fpreview, {"path":path+"/"+files[i],"index":i} )
        }
    }

    Component{
        id: preview_component
        ThumbnailImage {
            id: img_prv
            width: fpreview.width - padd
            height: fpreview.height - padd
            x: index*singlePadd + singlePadd/2
            y: index*singlePadd + singlePadd/2
            sourceSize: Qt.size(width*2,height*2)
            asynchronous: true
            fillMode: Image.PreserveAspectCrop

            property int index: 0
            property real padd: count*singlePadd
            property real singlePadd: 10*physicalPlatformScale
        }
    }
}
