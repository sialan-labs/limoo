/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Kaqaz is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Kaqaz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package org.sialan.android;

import org.sialan.android.SialanApplication;
import org.sialan.android.SialanActivity;

import android.util.Log;
import android.content.Intent;
import android.content.Context;
import android.app.Activity;
import android.net.Uri;
import android.util.DisplayMetrics;
import android.provider.MediaStore;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.view.WindowManager;
import android.os.Build;
import android.content.res.Configuration;
import android.view.View;
import android.view.Window;
import android.graphics.Rect;

import java.io.File;
import java.io.InputStream;
import java.io.FileOutputStream;

public class SialanJavaLayer {

    private static native void _sendNote( String title, String msg );
    private static native void _sendImage( String path );
    private static native void _activityPaused();
    private static native void _activityStopped();
    private static native void _activityResumed();
    private static native void _activityStarted();
    private static native void _activityRestarted();
    private static native void _selectImageResult( String path );

    public SialanJavaLayer() {
    }

    public static void activityPaused(){
        _activityPaused();
    }

    public static void activityStopped(){
        _activityStopped();
    }

    public static void activityResumed(){
        _activityResumed();
    }

    public static void activityStarted(){
        _activityStarted();
    }

    public static void activityRestarted(){
        _activityRestarted();
    }

    public static void sendNote( String title, String msg ) {
        if( title == null )
            title = "";
        if( msg == null )
            msg = "";

        _sendNote(title,msg);
    }

    public static int menuHeight()
    {
        Rect r = new Rect();
        Window window = SialanActivity.getActivityInstance().getWindow();
        View rootview = window.getDecorView();
        rootview.getWindowVisibleDisplayFrame(r);

        return r.top;
    }

    public static void sendImage( Uri data ) {
        String imagePath = "/sdcard/Sialan/tmp_input_image.jpg";

        File file = new File(imagePath);
        file.delete();

        try {
            InputStream stream = SialanApplication.instance().getContentResolver().openInputStream(data);
            Bitmap bitmap = BitmapFactory.decodeStream(stream);
            stream.close();

            FileOutputStream out = new FileOutputStream(imagePath);
            bitmap.compress(Bitmap.CompressFormat.JPEG, 90, out);
            out.close();
        } catch(Exception e) {
            return;
        }

        _sendImage(imagePath);
    }

    public static void selectImageResult( String path ) {
        if( path == null )
            path = "";

        _selectImageResult(path);
    }

    boolean sharePaper( String title, String msg )
    {
        Context oContext;
        oContext = SialanApplication.getAppContext();

        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.setType("text/plain");
        intent.putExtra(Intent.EXTRA_TEXT, msg);
        intent.putExtra(Intent.EXTRA_SUBJECT, title);

        try {
            oContext.startActivity(intent);
        } catch(Exception e) {
            return false;
        }
        return true;
    }

    boolean openFile( String path, String type )
    {
        Context oContext;
        oContext = SialanApplication.getAppContext();

        Intent intent = new Intent(android.content.Intent.ACTION_VIEW);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.setType(type);
        intent.setDataAndType(Uri.parse(path),type);

        try {
            oContext.startActivity(intent);
        } catch(Exception e) {
            return false;
        }
        return true;
    }

    boolean isTablet()
    {
        Context context = SialanApplication.getAppContext();
        return (context.getResources().getConfiguration().screenLayout
                & Configuration.SCREENLAYOUT_SIZE_MASK)
                >= Configuration.SCREENLAYOUT_SIZE_LARGE;
    }

    int getSizeName()
    {
        Context context = SialanApplication.getAppContext();
        int screenLayout = context.getResources().getConfiguration().screenLayout;
        screenLayout &= Configuration.SCREENLAYOUT_SIZE_MASK;

        switch (screenLayout) {
        case Configuration.SCREENLAYOUT_SIZE_SMALL:
            return 0;
        case Configuration.SCREENLAYOUT_SIZE_NORMAL:
            return 1;
        case Configuration.SCREENLAYOUT_SIZE_LARGE:
            return 2;
        case 4: // Configuration.SCREENLAYOUT_SIZE_XLARGE is API >= 9
            return 3;
        default:
            return -1;
        }
    }

    boolean getOpenPictures()
    {
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType("image/*");

        try {
            SialanActivity.getActivityInstance().startActivityForResult(intent, SialanActivity.SELECT_IMAGE);
        } catch(Exception e) {
            return false;
        }

        return true;
    }

    boolean startCamera( String output )
    {
        Intent intent = new Intent("android.media.action.IMAGE_CAPTURE");
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(new File(output)));

        try {
            SialanActivity.getActivityInstance().startActivityForResult(intent, 0);
        } catch(Exception e) {
            return false;
        }
        return true;
    }

    boolean transparentStatusBar()
    {
        return SialanActivity.getActivityInstance().transparentStatusBar();
    }

    boolean transparentNavigationBar()
    {
        return SialanActivity.getActivityInstance().transparentNavigationBar();
    }

    int densityDpi()
    {
        DisplayMetrics metrics = new DisplayMetrics();
        SialanActivity.getActivityInstance().getWindowManager().getDefaultDisplay().getMetrics(metrics);
        return metrics.densityDpi;
    }

    float density()
    {
        DisplayMetrics metrics = new DisplayMetrics();
        SialanActivity.getActivityInstance().getWindowManager().getDefaultDisplay().getMetrics(metrics);
        return metrics.density;
    }

    boolean release()
    {
        return true;
    }
}
