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

    property int count: 3
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
        if( PasswordManager.dirHasPassword(path) && !PasswordManager.passwordEntered(path) )
            return

        var cover_path = path + "/.cover"
        var cover_exist = Limoo.fileExists(cover_path)
        if( cover_exist )
            preview_component.createObject(fpreview, {"path":cover_path,"index":files.length!=0?files.length-1:0} )

        var length = cover_exist? files.length-1 : files.length
        for( var i=0; i<length; i++ ) {
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
            verticalAlignment: Image.AlignTop
            z: index

            property int index: 0
            property real padd: count*singlePadd
            property real singlePadd: 10*physicalPlatformScale
        }
    }

    Image {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: -6*physicalPlatformScale
        width: 18
        height: 18
        sourceSize: Qt.size(width,height)
        source: visible?"files/locked.png":""
        visible: PasswordManager.dirHasPassword(fpreview.path)
        z: 100
    }
}
