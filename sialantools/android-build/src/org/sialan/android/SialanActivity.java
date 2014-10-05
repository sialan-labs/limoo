/*
    Copyright (c) 2012-2013, BogDan Vatra <bogdan@kde.org>
    Contact: http://www.qt-project.org/legal

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

    1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
    IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
    IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
    NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
    THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package org.sialan.android;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.io.InputStream;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;

import org.kde.necessitas.ministro.IMinistro;
import org.kde.necessitas.ministro.IMinistroCallback;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.res.Configuration;
import android.content.res.Resources.Theme;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.net.Uri;
import android.os.Bundle;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.AttributeSet;
import android.util.Log;
import android.view.ContextMenu;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager.LayoutParams;
import android.view.accessibility.AccessibilityEvent;
import android.media.AudioManager;
import android.view.WindowManager;
import android.os.Build;
import android.provider.MediaStore;
import android.database.Cursor;
import dalvik.system.DexClassLoader;

//@ANDROID-11
//QtCreator import android.app.Fragment;
//QtCreator import android.view.ActionMode;
//QtCreator import android.view.ActionMode.Callback;
//@ANDROID-11

public class SialanActivity extends Activity
{
    private final static int MINISTRO_INSTALL_REQUEST_CODE = 0xf3ee; // request code used to know when Ministro instalation is finished
    private static final int MINISTRO_API_LEVEL = 4; // Ministro api level (check IMinistro.aidl file)
    private static final int NECESSITAS_API_LEVEL = 2; // Necessitas api level used by platform plugin
    private static final int QT_VERSION = 0x050100; // This app requires at least Qt version 5.1.0

    private static final String ERROR_CODE_KEY = "error.code";
    private static final String ERROR_MESSAGE_KEY = "error.message";
    private static final String DEX_PATH_KEY = "dex.path";
    private static final String LIB_PATH_KEY = "lib.path";
    private static final String LOADER_CLASS_NAME_KEY = "loader.class.name";
    private static final String NATIVE_LIBRARIES_KEY = "native.libraries";
    private static final String ENVIRONMENT_VARIABLES_KEY = "environment.variables";
    private static final String APPLICATION_PARAMETERS_KEY = "application.parameters";
    private static final String BUNDLED_LIBRARIES_KEY = "bundled.libraries";
    private static final String BUNDLED_IN_LIB_RESOURCE_ID_KEY = "android.app.bundled_in_lib_resource_id";
    private static final String BUNDLED_IN_ASSETS_RESOURCE_ID_KEY = "android.app.bundled_in_assets_resource_id";
    private static final String MAIN_LIBRARY_KEY = "main.library";
    private static final String STATIC_INIT_CLASSES_KEY = "static.init.classes";
    private static final String NECESSITAS_API_LEVEL_KEY = "necessitas.api.level";

    /// Ministro server parameter keys
    private static final String REQUIRED_MODULES_KEY = "required.modules";
    private static final String APPLICATION_TITLE_KEY = "application.title";
    private static final String MINIMUM_MINISTRO_API_KEY = "minimum.ministro.api";
    private static final String MINIMUM_QT_VERSION_KEY = "minimum.qt.version";
    private static final String SOURCES_KEY = "sources";               // needs MINISTRO_API_LEVEL >=3 !!!
                                                                       // Use this key to specify any 3rd party sources urls
                                                                       // Ministro will download these repositories into their
                                                                       // own folders, check http://community.kde.org/Necessitas/Ministro
                                                                       // for more details.

    private static final String REPOSITORY_KEY = "repository";         // use this key to overwrite the default ministro repsitory

    private static final String APPLICATION_PARAMETERS = null; // use this variable to pass any parameters to your application,
                                                               // the parameters must not contain any white spaces
                                                               // and must be separated with "\t"
                                                               // e.g "-param1\t-param2=value2\t-param3\tvalue3"

    private String ENVIRONMENT_VARIABLES = "QT_USE_ANDROID_NATIVE_STYLE=1\t";
                                                               // use this variable to add any environment variables to your application.
                                                               // the env vars must be separated with "\t"
                                                               // e.g. "ENV_VAR1=1\tENV_VAR2=2\t"
                                                               // Currently the following vars are used by the android plugin:
                                                               // * QT_USE_ANDROID_NATIVE_STYLE - 1 to use the android widget style if available,
                                                               //   note that the android style plugin in Qt 5.1 is not fully functional.

    private static final String QT_ANDROID_THEME = "light"; // sets the default theme to light. Possible values are:
                                                            // * ""           - for the device default dark theme
                                                            // * "light"      - for the device default light theme
                                                            // * "holo"       - for the holo dark theme
                                                            // * "holo_light" - for the holo light theme

    private static final int INCOMPATIBLE_MINISTRO_VERSION = 1; // Incompatible Ministro version. Ministro needs to be upgraded.
    private static final String DISPLAY_DPI_KEY = "display.dpi";
    private static final int BUFFER_SIZE = 1024;

    private ActivityInfo m_activityInfo = null; // activity info object, used to access the libs and the strings
    private DexClassLoader m_classLoader = null; // loader object
    private String[] m_sources = {"https://download.qt-project.org/ministro/android/qt5/latest"}; // Make sure you are using ONLY secure locations
    private String m_repository = "default"; // Overwrites the default Ministro repository
                                                        // Possible values:
                                                        // * default - Ministro default repository set with "Ministro configuration tool".
                                                        // By default the stable version is used. Only this or stable repositories should
                                                        // be used in production.
                                                        // * stable - stable repository, only this and default repositories should be used
                                                        // in production.
                                                        // * testing - testing repository, DO NOT use this repository in production,
                                                        // this repository is used to push a new release, and should be used to test your application.
                                                        // * unstable - unstable repository, DO NOT use this repository in production,
                                                        // this repository is used to push Qt snapshots.
    private String[] m_qtLibs = null; // required qt libs

    private static SialanActivity instance;
    public boolean _transparentStatusBar = false;
    public boolean _transparentNavigationBar = false;
    public static final int SELECT_IMAGE = 1;

//    SialanActivity(){
//        SialanActivity.instance = this;
//    }

    public static SialanActivity getActivityInstance() {
        return SialanActivity.instance;
    }

    public boolean transparentStatusBar() {
        return _transparentStatusBar;
    }

    public boolean transparentNavigationBar() {
        return _transparentNavigationBar;
    }

    // this function is used to load and start the loader
    private void loadApplication(Bundle loaderParams)
    {
        SialanActivity.instance = this;
        try {
            final int errorCode = loaderParams.getInt(ERROR_CODE_KEY);
            if (errorCode != 0) {
                if (errorCode == INCOMPATIBLE_MINISTRO_VERSION) {
                    downloadUpgradeMinistro(loaderParams.getString(ERROR_MESSAGE_KEY));
                    return;
                }

                // fatal error, show the error and quit
                AlertDialog errorDialog = new AlertDialog.Builder(SialanActivity.this).create();
                errorDialog.setMessage(loaderParams.getString(ERROR_MESSAGE_KEY));
                errorDialog.setButton(getResources().getString(android.R.string.ok), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        finish();
                    }
                });
                errorDialog.show();
                return;
            }

            // add all bundled Qt libs to loader params
            ArrayList<String> libs = new ArrayList<String>();
            if ( m_activityInfo.metaData.containsKey("android.app.bundled_libs_resource_id") )
                libs.addAll(Arrays.asList(getResources().getStringArray(m_activityInfo.metaData.getInt("android.app.bundled_libs_resource_id"))));

            String libName = null;
            if ( m_activityInfo.metaData.containsKey("android.app.lib_name") ) {
                libName = m_activityInfo.metaData.getString("android.app.lib_name");
                loaderParams.putString(MAIN_LIBRARY_KEY, libName); //main library contains main() function
            }

            loaderParams.putStringArrayList(BUNDLED_LIBRARIES_KEY, libs);
            loaderParams.putInt(NECESSITAS_API_LEVEL_KEY, NECESSITAS_API_LEVEL);

            // load and start QtLoader class
            m_classLoader = new DexClassLoader(loaderParams.getString(DEX_PATH_KEY), // .jar/.apk files
                                               getDir("outdex", Context.MODE_PRIVATE).getAbsolutePath(), // directory where optimized DEX files should be written.
                                               loaderParams.containsKey(LIB_PATH_KEY) ? loaderParams.getString(LIB_PATH_KEY) : null, // libs folder (if exists)
                                               getClassLoader()); // parent loader

            @SuppressWarnings("rawtypes")
            Class loaderClass = m_classLoader.loadClass(loaderParams.getString(LOADER_CLASS_NAME_KEY)); // load QtLoader class
            Object qtLoader = loaderClass.newInstance(); // create an instance
            Method perpareAppMethod = qtLoader.getClass().getMethod("loadApplication",
                                                                    Activity.class,
                                                                    ClassLoader.class,
                                                                    Bundle.class);
            if (!(Boolean)perpareAppMethod.invoke(qtLoader, this, m_classLoader, loaderParams))
                throw new Exception("");

            SialanApplication.setQtActivityDelegate(qtLoader);

            // now load the application library so it's accessible from this class loader
            if (libName != null)
                System.loadLibrary(libName);

            Method startAppMethod=qtLoader.getClass().getMethod("startApplication");
            if (!(Boolean)startAppMethod.invoke(qtLoader))
                throw new Exception("");

        } catch (Exception e) {
            e.printStackTrace();
            AlertDialog errorDialog = new AlertDialog.Builder(SialanActivity.this).create();
            if (m_activityInfo.metaData.containsKey("android.app.fatal_error_msg"))
                errorDialog.setMessage(m_activityInfo.metaData.getString("android.app.fatal_error_msg"));
            else
                errorDialog.setMessage("Fatal error, your application can't be started.");

            errorDialog.setButton(getResources().getString(android.R.string.ok), new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    finish();
                }
            });
            errorDialog.show();
        }
    }

    private ServiceConnection m_ministroConnection=new ServiceConnection() {
        private IMinistro m_service = null;
    @Override
        public void onServiceConnected(ComponentName name, IBinder service)
        {
            m_service = IMinistro.Stub.asInterface(service);
            try {
                if (m_service!=null) {
                    Bundle parameters= new Bundle();
                    parameters.putStringArray(REQUIRED_MODULES_KEY, m_qtLibs);
                    parameters.putString(APPLICATION_TITLE_KEY, (String)SialanActivity.this.getTitle());
                    parameters.putInt(MINIMUM_MINISTRO_API_KEY, MINISTRO_API_LEVEL);
                    parameters.putInt(MINIMUM_QT_VERSION_KEY, QT_VERSION);
                    parameters.putString(ENVIRONMENT_VARIABLES_KEY, ENVIRONMENT_VARIABLES);
                    if (null!=APPLICATION_PARAMETERS)
                        parameters.putString(APPLICATION_PARAMETERS_KEY, APPLICATION_PARAMETERS);
                    parameters.putStringArray(SOURCES_KEY, m_sources);
                    parameters.putString(REPOSITORY_KEY, m_repository);
                    parameters.putInt(DISPLAY_DPI_KEY, SialanActivity.this.getResources().getDisplayMetrics().densityDpi);
                    m_service.requestLoader(m_ministroCallback, parameters);
                }
            } catch (RemoteException e) {
                    e.printStackTrace();
            }
        }

    private IMinistroCallback m_ministroCallback = new IMinistroCallback.Stub() {
        // this function is called back by Ministro.
        @Override
        public void loaderReady(final Bundle loaderParams) throws RemoteException {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    unbindService(m_ministroConnection);
                    loadApplication(loaderParams);
                }
            });
        }
    };

        @Override
        public void onServiceDisconnected(ComponentName name) {
            m_service = null;
        }
    };

    private void downloadUpgradeMinistro(String msg)
    {
        AlertDialog.Builder downloadDialog = new AlertDialog.Builder(this);
        downloadDialog.setMessage(msg);
        downloadDialog.setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                try {
                    Uri uri = Uri.parse("market://search?q=pname:org.kde.necessitas.ministro");
                    Intent intent = new Intent(Intent.ACTION_VIEW, uri);
                    startActivityForResult(intent, MINISTRO_INSTALL_REQUEST_CODE);
                } catch (Exception e) {
                    e.printStackTrace();
                    ministroNotFound();
                }
            }
        });

        downloadDialog.setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                SialanActivity.this.finish();
            }
        });
        downloadDialog.show();
    }

    private void ministroNotFound()
    {
        AlertDialog errorDialog = new AlertDialog.Builder(SialanActivity.this).create();

        if (m_activityInfo.metaData.containsKey("android.app.ministro_not_found_msg"))
            errorDialog.setMessage(m_activityInfo.metaData.getString("android.app.ministro_not_found_msg"));
        else
            errorDialog.setMessage("Can't find Ministro service.\nThe application can't start.");

        errorDialog.setButton(getResources().getString(android.R.string.ok), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                finish();
            }
        });
        errorDialog.show();
    }

    static private void copyFile(InputStream inputStream, OutputStream outputStream)
        throws IOException
    {
        byte[] buffer = new byte[BUFFER_SIZE];

        int count;
        while ((count = inputStream.read(buffer)) > 0)
            outputStream.write(buffer, 0, count);
    }


    private void copyAsset(String source, String destination)
        throws IOException
    {
        // Already exists, we don't have to do anything
        File destinationFile = new File(destination);
        if (destinationFile.exists())
            return;

        File parentDirectory = destinationFile.getParentFile();
        if (!parentDirectory.exists())
            parentDirectory.mkdirs();

        destinationFile.createNewFile();

        AssetManager assetsManager = getAssets();
        InputStream inputStream = assetsManager.open(source);
        OutputStream outputStream = new FileOutputStream(destinationFile);
        copyFile(inputStream, outputStream);
    }

    private static void createBundledBinary(String source, String destination)
        throws IOException
    {
        // Already exists, we don't have to do anything
        File destinationFile = new File(destination);
        if (destinationFile.exists())
            return;

        File parentDirectory = destinationFile.getParentFile();
        if (!parentDirectory.exists())
            parentDirectory.mkdirs();

        destinationFile.createNewFile();

        InputStream inputStream = new FileInputStream(source);
        OutputStream outputStream = new FileOutputStream(destinationFile);
        copyFile(inputStream, outputStream);
    }

    private void extractBundledPluginsAndImports(String localPrefix)
        throws IOException
    {
        ArrayList<String> libs = new ArrayList<String>();

        {
            String key = BUNDLED_IN_LIB_RESOURCE_ID_KEY;
            java.util.Set<String> keys = m_activityInfo.metaData.keySet();
            if (m_activityInfo.metaData.containsKey(key)) {
                String[] list = getResources().getStringArray(m_activityInfo.metaData.getInt(key));

                for (String bundledImportBinary : list) {
                    String[] split = bundledImportBinary.split(":");
                    String sourceFileName = localPrefix + "lib/" + split[0];
                    String destinationFileName = localPrefix + split[1];
                    createBundledBinary(sourceFileName, destinationFileName);
                }
            }
        }

        {
            String key = BUNDLED_IN_ASSETS_RESOURCE_ID_KEY;
            if (m_activityInfo.metaData.containsKey(key)) {
                String[] list = getResources().getStringArray(m_activityInfo.metaData.getInt(key));

                for (String fileName : list) {
                    String[] split = fileName.split(":");
                    String sourceFileName = split[0];
                    String destinationFileName = localPrefix + split[1];
                    copyAsset(sourceFileName, destinationFileName);
                }
            }

        }
    }

    private void startApp(final boolean firstStart)
    {
        try {
            if (m_activityInfo.metaData.containsKey("android.app.qt_sources_resource_id")) {
                int resourceId = m_activityInfo.metaData.getInt("android.app.qt_sources_resource_id");
                m_sources = getResources().getStringArray(resourceId);
            }

            if (m_activityInfo.metaData.containsKey("android.app.repository"))
                m_repository = m_activityInfo.metaData.getString("android.app.repository");

            if (m_activityInfo.metaData.containsKey("android.app.qt_libs_resource_id")) {
                int resourceId = m_activityInfo.metaData.getInt("android.app.qt_libs_resource_id");
                m_qtLibs = getResources().getStringArray(resourceId);
            }

            if (m_activityInfo.metaData.containsKey("android.app.use_local_qt_libs")
                    && m_activityInfo.metaData.getInt("android.app.use_local_qt_libs") == 1) {
                ArrayList<String> libraryList = new ArrayList<String>();


                String localPrefix = "/data/local/tmp/qt/";
                if (m_activityInfo.metaData.containsKey("android.app.libs_prefix"))
                    localPrefix = m_activityInfo.metaData.getString("android.app.libs_prefix");

                boolean bundlingQtLibs = false;
                if (m_activityInfo.metaData.containsKey("android.app.bundle_local_qt_libs")
                    && m_activityInfo.metaData.getInt("android.app.bundle_local_qt_libs") == 1) {
                    localPrefix = getApplicationInfo().dataDir + "/";
                    extractBundledPluginsAndImports(localPrefix);
                    bundlingQtLibs = true;
                }

                if (m_qtLibs != null) {
                    for (int i=0;i<m_qtLibs.length;i++) {
                        libraryList.add(localPrefix
                                        + "lib/lib"
                                        + m_qtLibs[i]
                                        + ".so");
                    }
                }

                if (m_activityInfo.metaData.containsKey("android.app.load_local_libs")) {
                    String[] extraLibs = m_activityInfo.metaData.getString("android.app.load_local_libs").split(":");
                    for (String lib : extraLibs) {
                        if (lib.length() > 0)
                            libraryList.add(localPrefix + lib);
                    }
                }


                String dexPaths = new String();
                String pathSeparator = System.getProperty("path.separator", ":");
                if (!bundlingQtLibs && m_activityInfo.metaData.containsKey("android.app.load_local_jars")) {
                    String[] jarFiles = m_activityInfo.metaData.getString("android.app.load_local_jars").split(":");
                    for (String jar:jarFiles) {
                        if (jar.length() > 0) {
                            if (dexPaths.length() > 0)
                                dexPaths += pathSeparator;
                            dexPaths += localPrefix + jar;
                        }
                    }
                }

                Bundle loaderParams = new Bundle();
                loaderParams.putInt(ERROR_CODE_KEY, 0);
                loaderParams.putString(DEX_PATH_KEY, dexPaths);
                loaderParams.putString(LOADER_CLASS_NAME_KEY, "org.qtproject.qt5.android.QtActivityDelegate");
                if (m_activityInfo.metaData.containsKey("android.app.static_init_classes")) {
                    loaderParams.putStringArray(STATIC_INIT_CLASSES_KEY,
                                                m_activityInfo.metaData.getString("android.app.static_init_classes").split(":"));
                }
                loaderParams.putStringArrayList(NATIVE_LIBRARIES_KEY, libraryList);
                loaderParams.putString(ENVIRONMENT_VARIABLES_KEY, ENVIRONMENT_VARIABLES
                                                                  + "\tQML2_IMPORT_PATH=" + localPrefix + "/qml"
                                                                  + "\tQML_IMPORT_PATH=" + localPrefix + "/imports"
                                                                  + "\tQT_PLUGIN_PATH=" + localPrefix + "/plugins");
                loadApplication(loaderParams);
                return;
            }

            try {
                if (!bindService(new Intent(org.kde.necessitas.ministro.IMinistro.class.getCanonicalName()),
                                 m_ministroConnection,
                                 Context.BIND_AUTO_CREATE)) {
                    throw new SecurityException("");
                }
            } catch (Exception e) {
                if (firstStart) {
                    String msg = "This application requires Ministro service. Would you like to install it?";
                    if (m_activityInfo.metaData.containsKey("android.app.ministro_needed_msg"))
                        msg = m_activityInfo.metaData.getString("android.app.ministro_needed_msg");
                    downloadUpgradeMinistro(msg);
                } else {
                    ministroNotFound();
                }
            }
        } catch (Exception e) {
            Log.e(SialanApplication.QtTAG, "Can't create main activity", e);
        }
    }



    /////////////////////////// forward all notifications ////////////////////////////
    /////////////////////////// Super class calls ////////////////////////////////////
    /////////////// PLEASE DO NOT CHANGE THE FOLLOWING CODE //////////////////////////
    //////////////////////////////////////////////////////////////////////////////////

    @Override
    public boolean dispatchKeyEvent(KeyEvent event)
    {
        if (SialanApplication.m_delegateObject != null && SialanApplication.dispatchKeyEvent != null)
            return (Boolean) SialanApplication.invokeDelegateMethod(SialanApplication.dispatchKeyEvent, event);
        else
            return super.dispatchKeyEvent(event);
    }
    public boolean super_dispatchKeyEvent(KeyEvent event)
    {
        return super.dispatchKeyEvent(event);
    }
    //---------------------------------------------------------------------------

    @Override
    public boolean dispatchPopulateAccessibilityEvent(AccessibilityEvent event)
    {
        if (SialanApplication.m_delegateObject != null && SialanApplication.dispatchPopulateAccessibilityEvent != null)
            return (Boolean) SialanApplication.invokeDelegateMethod(SialanApplication.dispatchPopulateAccessibilityEvent, event);
        else
            return super.dispatchPopulateAccessibilityEvent(event);
    }
    public boolean super_dispatchPopulateAccessibilityEvent(AccessibilityEvent event)
    {
        return super_dispatchPopulateAccessibilityEvent(event);
    }
    //---------------------------------------------------------------------------

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev)
    {
        if (SialanApplication.m_delegateObject != null && SialanApplication.dispatchTouchEvent != null)
            return (Boolean) SialanApplication.invokeDelegateMethod(SialanApplication.dispatchTouchEvent, ev);
        else
            return super.dispatchTouchEvent(ev);
    }
    public boolean super_dispatchTouchEvent(MotionEvent event)
    {
        return super.dispatchTouchEvent(event);
    }
    //---------------------------------------------------------------------------

    @Override
    public boolean dispatchTrackballEvent(MotionEvent ev)
    {
        if (SialanApplication.m_delegateObject != null && SialanApplication.dispatchTrackballEvent != null)
            return (Boolean) SialanApplication.invokeDelegateMethod(SialanApplication.dispatchTrackballEvent, ev);
        else
            return super.dispatchTrackballEvent(ev);
    }
    public boolean super_dispatchTrackballEvent(MotionEvent event)
    {
        return super.dispatchTrackballEvent(event);
    }
    //---------------------------------------------------------------------------

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        if (resultCode == RESULT_OK) {
            if (requestCode == SialanActivity.SELECT_IMAGE) {
                Uri selectedImageUri = data.getData();
                SialanJavaLayer.selectImageResult( getPath(selectedImageUri) );
            }
        }

        if (SialanApplication.m_delegateObject != null && SialanApplication.onActivityResult != null) {
            SialanApplication.invokeDelegateMethod(SialanApplication.onActivityResult, requestCode, resultCode, data);
            return;
        }
        if (requestCode == MINISTRO_INSTALL_REQUEST_CODE)
            startApp(false);
        super.onActivityResult(requestCode, resultCode, data);
    }

    public void super_onActivityResult(int requestCode, int resultCode, Intent data)
    {
        super.onActivityResult(requestCode, resultCode, data);
    }
    //---------------------------------------------------------------------------

    public String getPath(Uri uri) {
        String selectedImagePath;
        //1:MEDIA GALLERY --- query from MediaStore.Images.Media.DATA
        String[] projection = { MediaStore.Images.Media.DATA };
        Cursor cursor = managedQuery(uri, projection, null, null, null);
        if(cursor != null){
            int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
            cursor.moveToFirst();
            selectedImagePath = cursor.getString(column_index);
        }else{
            selectedImagePath = null;
        }

        if(selectedImagePath == null){
            //2:OI FILE Manager --- call method: uri.getPath()
            selectedImagePath = uri.getPath();
        }
        return selectedImagePath;
    }

    @Override
    protected void onApplyThemeResource(Theme theme, int resid, boolean first)
    {
        if (!SialanApplication.invokeDelegate(theme, resid, first).invoked)
            super.onApplyThemeResource(theme, resid, first);
    }
    public void super_onApplyThemeResource(Theme theme, int resid, boolean first)
    {
        super.onApplyThemeResource(theme, resid, first);
    }
    //---------------------------------------------------------------------------


    @Override
    protected void onChildTitleChanged(Activity childActivity, CharSequence title)
    {
        if (!SialanApplication.invokeDelegate(childActivity, title).invoked)
            super.onChildTitleChanged(childActivity, title);
    }
    public void super_onChildTitleChanged(Activity childActivity, CharSequence title)
    {
        super.onChildTitleChanged(childActivity, title);
    }
    //---------------------------------------------------------------------------

    @Override
    public void onConfigurationChanged(Configuration newConfig)
    {
        if (!SialanApplication.invokeDelegate(newConfig).invoked)
            super.onConfigurationChanged(newConfig);
    }
    public void super_onConfigurationChanged(Configuration newConfig)
    {
        super.onConfigurationChanged(newConfig);
    }
    //---------------------------------------------------------------------------

    @Override
    public void onContentChanged()
    {
        if (!SialanApplication.invokeDelegate().invoked)
            super.onContentChanged();
    }
    public void super_onContentChanged()
    {
        super.onContentChanged();
    }
    //---------------------------------------------------------------------------

    @Override
    public boolean onContextItemSelected(MenuItem item)
    {
        SialanApplication.InvokeResult res = SialanApplication.invokeDelegate(item);
        if (res.invoked)
            return (Boolean)res.methodReturns;
        else
            return super.onContextItemSelected(item);
    }
    public boolean super_onContextItemSelected(MenuItem item)
    {
        return super.onContextItemSelected(item);
    }
    //---------------------------------------------------------------------------

    @Override
    public void onContextMenuClosed(Menu menu)
    {
        if (!SialanApplication.invokeDelegate(menu).invoked)
            super.onContextMenuClosed(menu);
    }
    public void super_onContextMenuClosed(Menu menu)
    {
        super.onContextMenuClosed(menu);
    }
    //---------------------------------------------------------------------------

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setVolumeControlStream(AudioManager.STREAM_MUSIC);
        if (SialanApplication.m_delegateObject != null && SialanApplication.onCreate != null) {
            SialanApplication.invokeDelegateMethod(SialanApplication.onCreate, savedInstanceState);
            return;
        }

        Window w = getWindow();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            w.setFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION, WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
            w.setFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS, WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            _transparentStatusBar = true;
            _transparentNavigationBar = true;
        } else {
            w.setFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS, WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);
            _transparentStatusBar = true;
        }
        w.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        ENVIRONMENT_VARIABLES += "\tQT_ANDROID_THEME=" + QT_ANDROID_THEME
                              + "/\tQT_ANDROID_THEME_DISPLAY_DPI=" + getResources().getDisplayMetrics().densityDpi + "\t";
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        try {
            m_activityInfo = getPackageManager().getActivityInfo(getComponentName(), PackageManager.GET_META_DATA);
        } catch (NameNotFoundException e) {
            e.printStackTrace();
            finish();
            return;
        }

        if (null == getLastNonConfigurationInstance()) {
            // if splash screen is defined, then show it
            if (m_activityInfo.metaData.containsKey("android.app.splash_screen") )
                setContentView(m_activityInfo.metaData.getInt("android.app.splash_screen"));
            startApp(true);
        }

        checkIntent(getIntent());
    }
    //---------------------------------------------------------------------------

    @Override
    public void onCreateContextMenu(ContextMenu menu, View v, ContextMenuInfo menuInfo)
    {
        if (!SialanApplication.invokeDelegate(menu, v, menuInfo).invoked)
            super.onCreateContextMenu(menu, v, menuInfo);
    }
    public void super_onCreateContextMenu(ContextMenu menu, View v, ContextMenuInfo menuInfo)
    {
        super.onCreateContextMenu(menu, v, menuInfo);
    }
    //---------------------------------------------------------------------------

    @Override
    public CharSequence onCreateDescription()
    {
        SialanApplication.InvokeResult res = SialanApplication.invokeDelegate();
        if (res.invoked)
            return (CharSequence)res.methodReturns;
        else
            return super.onCreateDescription();
    }
    public CharSequence super_onCreateDescription()
    {
        return super.onCreateDescription();
    }
    //---------------------------------------------------------------------------

    @Override
    protected Dialog onCreateDialog(int id)
    {
        SialanApplication.InvokeResult res = SialanApplication.invokeDelegate(id);
        if (res.invoked)
            return (Dialog)res.methodReturns;
        else
            return super.onCreateDialog(id);
    }
    public Dialog super_onCreateDialog(int id)
    {
        return super.onCreateDialog(id);
    }
    //---------------------------------------------------------------------------

    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        SialanApplication.InvokeResult res = SialanApplication.invokeDelegate(menu);
        if (res.invoked)
            return (Boolean)res.methodReturns;
        else
            return super.onCreateOptionsMenu(menu);
    }
    public boolean super_onCreateOptionsMenu(Menu menu)
    {
        return super.onCreateOptionsMenu(menu);
    }
    //---------------------------------------------------------------------------

    @Override
    public boolean onCreatePanelMenu(int featureId, Menu menu)
    {
        SialanApplication.InvokeResult res = SialanApplication.invokeDelegate(featureId, menu);
        if (res.invoked)
            return (Boolean)res.methodReturns;
        else
            return super.onCreatePanelMenu(featureId, menu);
    }
    public boolean super_onCreatePanelMenu(int featureId, Menu menu)
    {
        return super.onCreatePanelMenu(featureId, menu);
    }
    //---------------------------------------------------------------------------


    @Override
    public View onCreatePanelView(int featureId)
    {
        SialanApplication.InvokeResult res = SialanApplication.invokeDelegate(featureId);
        if (res.invoked)
            return (View)res.methodReturns;
        else
            return super.onCreatePanelView(featureId);
    }
    public View super_onCreatePanelView(int featureId)
    {
        return super.onCreatePanelView(featureId);
    }
    //---------------------------------------------------------------------------

    @Override
    public boolean onCreateThumbnail(Bitmap outBitmap, Canvas canvas)
    {
        SialanApplication.InvokeResult res = SialanApplication.invokeDelegate(outBitmap, canvas);
        if (res.invoked)
            return (Boolean)res.methodReturns;
        else
            return super.onCreateThumbnail(outBitmap, canvas);
    }
    public boolean super_onCreateThumbnail(Bitmap outBitmap, Canvas canvas)
    {
        return super.onCreateThumbnail(outBitmap, canvas);
    }
    //---------------------------------------------------------------------------

    @Override
    public View onCreateView(String name, Context context, AttributeSet attrs)
    {
        SialanApplication.InvokeResult res = SialanApplication.invokeDelegate(name, context, attrs);
        if (res.invoked)
            return (View)res.methodReturns;
        else
            return super.onCreateView(name, context, attrs);
    }
    public View super_onCreateView(String name, Context context, AttributeSet attrs)
    {
        return super.onCreateView(name, context, attrs);
    }
    //---------------------------------------------------------------------------

    @Override
    protected void onDestroy()
    {
        super.onDestroy();
        SialanApplication.invokeDelegate();
    }
    //---------------------------------------------------------------------------


    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event)
    {
        // Added By Bardia
        if( keyCode == KeyEvent.KEYCODE_VOLUME_DOWN || keyCode == KeyEvent.KEYCODE_VOLUME_UP )
            return false;
        if (SialanApplication.m_delegateObject != null && SialanApplication.onKeyDown != null)
            return (Boolean) SialanApplication.invokeDelegateMethod(SialanApplication.onKeyDown, keyCode, event);
        else
            return super.onKeyDown(keyCode, event);
    }
    public boolean super_onKeyDown(int keyCode, KeyEvent event)
    {
        return super.onKeyDown(keyCode, event);
    }
    //---------------------------------------------------------------------------


    @Override
    public boolean onKeyMultiple(int keyCode, int repeatCount, KeyEvent event)
    {
        if (SialanApplication.m_delegateObject != null && SialanApplication.onKeyMultiple != null)
            return (Boolean) SialanApplication.invokeDelegateMethod(SialanApplication.onKeyMultiple, keyCode, repeatCount, event);
        else
            return super.onKeyMultiple(keyCode, repeatCount, event);
    }
    public boolean super_onKeyMultiple(int keyCode, int repeatCount, KeyEvent event)
    {
        return super.onKeyMultiple(keyCode, repeatCount, event);
    }
    //---------------------------------------------------------------------------

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event)
    {
        // Added By Bardia
        if( keyCode == KeyEvent.KEYCODE_VOLUME_DOWN || keyCode == KeyEvent.KEYCODE_VOLUME_UP )
            return false;
        if (SialanApplication.m_delegateObject != null  && SialanApplication.onKeyDown != null)
            return (Boolean) SialanApplication.invokeDelegateMethod(SialanApplication.onKeyUp, keyCode, event);
        else
            return super.onKeyUp(keyCode, event);
    }
    public boolean super_onKeyUp(int keyCode, KeyEvent event)
    {
        return super.onKeyUp(keyCode, event);
    }
    //---------------------------------------------------------------------------

    @Override
    public void onLowMemory()
    {
        if (!SialanApplication.invokeDelegate().invoked)
            super.onLowMemory();
    }
    //---------------------------------------------------------------------------

    @Override
    public boolean onMenuItemSelected(int featureId, MenuItem item)
    {
        SialanApplication.InvokeResult res = SialanApplication.invokeDelegate(featureId, item);
        if (res.invoked)
            return (Boolean)res.methodReturns;
        else
            return super.onMenuItemSelected(featureId, item);
    }
    public boolean super_onMenuItemSelected(int featureId, MenuItem item)
    {
        return super.onMenuItemSelected(featureId, item);
    }
    //---------------------------------------------------------------------------

    @Override
    public boolean onMenuOpened(int featureId, Menu menu)
    {
        SialanApplication.InvokeResult res = SialanApplication.invokeDelegate(featureId, menu);
        if (res.invoked)
            return (Boolean)res.methodReturns;
        else
            return super.onMenuOpened(featureId, menu);
    }
    public boolean super_onMenuOpened(int featureId, Menu menu)
    {
        return super.onMenuOpened(featureId, menu);
    }
    //---------------------------------------------------------------------------

    @Override
    protected void onNewIntent(Intent intent)
    {
        if (!SialanApplication.invokeDelegate(intent).invoked)
            super.onNewIntent(intent);

        checkIntent(intent);
    }

    protected void checkIntent(Intent intent)
    {
        String action = intent.getAction();
        String type = intent.getType();
        if ( !Intent.ACTION_SEND.equals(action) || type == null)
            return;

        if ("text/plain".equals(type))
            SialanJavaLayer.sendNote(intent.getStringExtra(Intent.EXTRA_SUBJECT), intent.getStringExtra(Intent.EXTRA_TEXT) );
        else
        if("image/png".equals(type) || "image/jpeg".equals(type))
            SialanJavaLayer.sendImage( (Uri)intent.getExtras().get(Intent.EXTRA_STREAM) );
    }

    public void super_onNewIntent(Intent intent)
    {
        super.onNewIntent(intent);
    }
    //---------------------------------------------------------------------------

    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        SialanApplication.InvokeResult res = SialanApplication.invokeDelegate(item);
        if (res.invoked)
            return (Boolean)res.methodReturns;
        else
            return super.onOptionsItemSelected(item);
    }
    public boolean super_onOptionsItemSelected(MenuItem item)
    {
        return super.onOptionsItemSelected(item);
    }
    //---------------------------------------------------------------------------

    @Override
    public void onOptionsMenuClosed(Menu menu)
    {
        if (!SialanApplication.invokeDelegate(menu).invoked)
            super.onOptionsMenuClosed(menu);
    }
    public void super_onOptionsMenuClosed(Menu menu)
    {
        super.onOptionsMenuClosed(menu);
    }
    //---------------------------------------------------------------------------

    @Override
    public void onPanelClosed(int featureId, Menu menu)
    {
        if (!SialanApplication.invokeDelegate(featureId, menu).invoked)
            super.onPanelClosed(featureId, menu);
    }
    public void super_onPanelClosed(int featureId, Menu menu)
    {
        super.onPanelClosed(featureId, menu);
    }
    //---------------------------------------------------------------------------

    @Override
    protected void onPause()
    {
        SialanJavaLayer.activityPaused();
        super.onPause();
        SialanApplication.invokeDelegate();
    }
    //---------------------------------------------------------------------------

    @Override
    protected void onPostCreate(Bundle savedInstanceState)
    {
        super.onPostCreate(savedInstanceState);
        SialanApplication.invokeDelegate(savedInstanceState);
    }
    //---------------------------------------------------------------------------

    @Override
    protected void onPostResume()
    {
        super.onPostResume();
        SialanApplication.invokeDelegate();
    }
    //---------------------------------------------------------------------------

    @Override
    protected void onPrepareDialog(int id, Dialog dialog)
    {
        if (!SialanApplication.invokeDelegate(id, dialog).invoked)
            super.onPrepareDialog(id, dialog);
    }
    public void super_onPrepareDialog(int id, Dialog dialog)
    {
        super.onPrepareDialog(id, dialog);
    }
    //---------------------------------------------------------------------------

    @Override
    public boolean onPrepareOptionsMenu(Menu menu)
    {
        SialanApplication.InvokeResult res = SialanApplication.invokeDelegate(menu);
        if (res.invoked)
            return (Boolean)res.methodReturns;
        else
            return super.onPrepareOptionsMenu(menu);
    }
    public boolean super_onPrepareOptionsMenu(Menu menu)
    {
        return super.onPrepareOptionsMenu(menu);
    }
    //---------------------------------------------------------------------------

    @Override
    public boolean onPreparePanel(int featureId, View view, Menu menu)
    {
        SialanApplication.InvokeResult res = SialanApplication.invokeDelegate(featureId, view, menu);
        if (res.invoked)
            return (Boolean)res.methodReturns;
        else
            return super.onPreparePanel(featureId, view, menu);
    }
    public boolean super_onPreparePanel(int featureId, View view, Menu menu)
    {
        return super.onPreparePanel(featureId, view, menu);
    }
    //---------------------------------------------------------------------------

    @Override
    protected void onRestart()
    {
        SialanJavaLayer.activityRestarted();
        super.onRestart();
        SialanApplication.invokeDelegate();
    }
    //---------------------------------------------------------------------------

    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState)
    {
        if (!SialanApplication.invokeDelegate(savedInstanceState).invoked)
            super.onRestoreInstanceState(savedInstanceState);
    }
    public void super_onRestoreInstanceState(Bundle savedInstanceState)
    {
        super.onRestoreInstanceState(savedInstanceState);
    }
    //---------------------------------------------------------------------------

    @Override
    protected void onResume()
    {
        SialanJavaLayer.activityResumed();
        super.onResume();
        SialanApplication.invokeDelegate();
    }
    //---------------------------------------------------------------------------

    @Override
    public Object onRetainNonConfigurationInstance()
    {
        SialanApplication.InvokeResult res = SialanApplication.invokeDelegate();
        if (res.invoked)
            return res.methodReturns;
        else
            return super.onRetainNonConfigurationInstance();
    }
    public Object super_onRetainNonConfigurationInstance()
    {
        return super.onRetainNonConfigurationInstance();
    }
    //---------------------------------------------------------------------------

    @Override
    protected void onSaveInstanceState(Bundle outState)
    {
        if (!SialanApplication.invokeDelegate(outState).invoked)
            super.onSaveInstanceState(outState);
    }
    public void super_onSaveInstanceState(Bundle outState)
    {
        super.onSaveInstanceState(outState);

    }
    //---------------------------------------------------------------------------

    @Override
    public boolean onSearchRequested()
    {
        SialanApplication.InvokeResult res = SialanApplication.invokeDelegate();
        if (res.invoked)
            return (Boolean)res.methodReturns;
        else
            return super.onSearchRequested();
    }
    public boolean super_onSearchRequested()
    {
        return super.onSearchRequested();
    }
    //---------------------------------------------------------------------------

    @Override
    protected void onStart()
    {
        super.onStart();
        SialanApplication.invokeDelegate();
        SialanJavaLayer.activityStarted();
    }
    //---------------------------------------------------------------------------

    @Override
    protected void onStop()
    {
        SialanJavaLayer.activityStopped();
        super.onStop();
        SialanApplication.invokeDelegate();
    }
    //---------------------------------------------------------------------------

    @Override
    protected void onTitleChanged(CharSequence title, int color)
    {
        if (!SialanApplication.invokeDelegate(title, color).invoked)
            super.onTitleChanged(title, color);
    }
    public void super_onTitleChanged(CharSequence title, int color)
    {
        super.onTitleChanged(title, color);
    }
    //---------------------------------------------------------------------------

    @Override
    public boolean onTouchEvent(MotionEvent event)
    {
        if (SialanApplication.m_delegateObject != null  && SialanApplication.onTouchEvent != null)
            return (Boolean) SialanApplication.invokeDelegateMethod(SialanApplication.onTouchEvent, event);
        else
            return super.onTouchEvent(event);
    }
    public boolean super_onTouchEvent(MotionEvent event)
    {
        return super.onTouchEvent(event);
    }
    //---------------------------------------------------------------------------

    @Override
    public boolean onTrackballEvent(MotionEvent event)
    {
        if (SialanApplication.m_delegateObject != null  && SialanApplication.onTrackballEvent != null)
            return (Boolean) SialanApplication.invokeDelegateMethod(SialanApplication.onTrackballEvent, event);
        else
            return super.onTrackballEvent(event);
    }
    public boolean super_onTrackballEvent(MotionEvent event)
    {
        return super.onTrackballEvent(event);
    }
    //---------------------------------------------------------------------------

    @Override
    public void onUserInteraction()
    {
        if (!SialanApplication.invokeDelegate().invoked)
            super.onUserInteraction();
    }
    public void super_onUserInteraction()
    {
        super.onUserInteraction();
    }
    //---------------------------------------------------------------------------

    @Override
    protected void onUserLeaveHint()
    {
        if (!SialanApplication.invokeDelegate().invoked)
            super.onUserLeaveHint();
    }
    public void super_onUserLeaveHint()
    {
        super.onUserLeaveHint();
    }
    //---------------------------------------------------------------------------

    @Override
    public void onWindowAttributesChanged(LayoutParams params)
    {
        if (!SialanApplication.invokeDelegate(params).invoked)
            super.onWindowAttributesChanged(params);
    }
    public void super_onWindowAttributesChanged(LayoutParams params)
    {
        super.onWindowAttributesChanged(params);
    }
    //---------------------------------------------------------------------------

    @Override
    public void onWindowFocusChanged(boolean hasFocus)
    {
        if (!SialanApplication.invokeDelegate(hasFocus).invoked)
            super.onWindowFocusChanged(hasFocus);
    }
    public void super_onWindowFocusChanged(boolean hasFocus)
    {
        super.onWindowFocusChanged(hasFocus);
    }
    //---------------------------------------------------------------------------

    //////////////// Activity API 5 /////////////
//@ANDROID-5
    @Override
    public void onAttachedToWindow()
    {
        if (!SialanApplication.invokeDelegate().invoked)
            super.onAttachedToWindow();
    }
    public void super_onAttachedToWindow()
    {
        super.onAttachedToWindow();
    }
    //---------------------------------------------------------------------------

    @Override
    public void onBackPressed()
    {
        if (!SialanApplication.invokeDelegate().invoked)
            super.onBackPressed();
    }
    public void super_onBackPressed()
    {
        super.onBackPressed();
    }
    //---------------------------------------------------------------------------

    @Override
    public void onDetachedFromWindow()
    {
        if (!SialanApplication.invokeDelegate().invoked)
            super.onDetachedFromWindow();
    }
    public void super_onDetachedFromWindow()
    {
        super.onDetachedFromWindow();
    }
    //---------------------------------------------------------------------------

    @Override
    public boolean onKeyLongPress(int keyCode, KeyEvent event)
    {
        if (SialanApplication.m_delegateObject != null  && SialanApplication.onKeyLongPress != null)
            return (Boolean) SialanApplication.invokeDelegateMethod(SialanApplication.onKeyLongPress, keyCode, event);
        else
            return super.onKeyLongPress(keyCode, event);
    }
    public boolean super_onKeyLongPress(int keyCode, KeyEvent event)
    {
        return super.onKeyLongPress(keyCode, event);
    }
    //---------------------------------------------------------------------------
//@ANDROID-5

//////////////// Activity API 8 /////////////
//@ANDROID-8
@Override
    protected Dialog onCreateDialog(int id, Bundle args)
    {
        SialanApplication.InvokeResult res = SialanApplication.invokeDelegate(id, args);
        if (res.invoked)
            return (Dialog)res.methodReturns;
        else
            return super.onCreateDialog(id, args);
    }
    public Dialog super_onCreateDialog(int id, Bundle args)
    {
        return super.onCreateDialog(id, args);
    }
    //---------------------------------------------------------------------------

    @Override
    protected void onPrepareDialog(int id, Dialog dialog, Bundle args)
    {
        if (!SialanApplication.invokeDelegate(id, dialog, args).invoked)
            super.onPrepareDialog(id, dialog, args);
    }
    public void super_onPrepareDialog(int id, Dialog dialog, Bundle args)
    {
        super.onPrepareDialog(id, dialog, args);
    }
    //---------------------------------------------------------------------------
//@ANDROID-8
    //////////////// Activity API 11 /////////////

//@ANDROID-11
//QtCreator     @Override
//QtCreator     public boolean dispatchKeyShortcutEvent(KeyEvent event)
//QtCreator     {
//QtCreator         if (SialanApplication.m_delegateObject != null  && SialanApplication.dispatchKeyShortcutEvent != null)
//QtCreator             return (Boolean) SialanApplication.invokeDelegateMethod(SialanApplication.dispatchKeyShortcutEvent, event);
//QtCreator         else
//QtCreator             return super.dispatchKeyShortcutEvent(event);
//QtCreator     }
//QtCreator     public boolean super_dispatchKeyShortcutEvent(KeyEvent event)
//QtCreator     {
//QtCreator         return super.dispatchKeyShortcutEvent(event);
//QtCreator     }
//QtCreator     //---------------------------------------------------------------------------
//QtCreator 
//QtCreator     @Override
//QtCreator     public void onActionModeFinished(ActionMode mode)
//QtCreator     {
//QtCreator         if (!SialanApplication.invokeDelegate(mode).invoked)
//QtCreator             super.onActionModeFinished(mode);
//QtCreator     }
//QtCreator     public void super_onActionModeFinished(ActionMode mode)
//QtCreator     {
//QtCreator         super.onActionModeFinished(mode);
//QtCreator     }
//QtCreator     //---------------------------------------------------------------------------
//QtCreator 
//QtCreator     @Override
//QtCreator     public void onActionModeStarted(ActionMode mode)
//QtCreator     {
//QtCreator         if (!SialanApplication.invokeDelegate(mode).invoked)
//QtCreator             super.onActionModeStarted(mode);
//QtCreator     }
//QtCreator     public void super_onActionModeStarted(ActionMode mode)
//QtCreator     {
//QtCreator         super.onActionModeStarted(mode);
//QtCreator     }
//QtCreator     //---------------------------------------------------------------------------
//QtCreator 
//QtCreator     @Override
//QtCreator     public void onAttachFragment(Fragment fragment)
//QtCreator     {
//QtCreator         if (!SialanApplication.invokeDelegate(fragment).invoked)
//QtCreator             super.onAttachFragment(fragment);
//QtCreator     }
//QtCreator     public void super_onAttachFragment(Fragment fragment)
//QtCreator     {
//QtCreator         super.onAttachFragment(fragment);
//QtCreator     }
//QtCreator     //---------------------------------------------------------------------------
//QtCreator 
//QtCreator     @Override
//QtCreator     public View onCreateView(View parent, String name, Context context, AttributeSet attrs)
//QtCreator     {
//QtCreator         SialanApplication.InvokeResult res = SialanApplication.invokeDelegate(parent, name, context, attrs);
//QtCreator         if (res.invoked)
//QtCreator             return (View)res.methodReturns;
//QtCreator         else
//QtCreator             return super.onCreateView(parent, name, context, attrs);
//QtCreator     }
//QtCreator     public View super_onCreateView(View parent, String name, Context context,
//QtCreator             AttributeSet attrs) {
//QtCreator         return super.onCreateView(parent, name, context, attrs);
//QtCreator     }
//QtCreator     //---------------------------------------------------------------------------
//QtCreator 
//QtCreator     @Override
//QtCreator     public boolean onKeyShortcut(int keyCode, KeyEvent event)
//QtCreator     {
//QtCreator         if (SialanApplication.m_delegateObject != null  && SialanApplication.onKeyShortcut != null)
//QtCreator             return (Boolean) SialanApplication.invokeDelegateMethod(SialanApplication.onKeyShortcut, keyCode,event);
//QtCreator         else
//QtCreator             return super.onKeyShortcut(keyCode, event);
//QtCreator     }
//QtCreator     public boolean super_onKeyShortcut(int keyCode, KeyEvent event)
//QtCreator     {
//QtCreator         return super.onKeyShortcut(keyCode, event);
//QtCreator     }
//QtCreator     //---------------------------------------------------------------------------
//QtCreator 
//QtCreator     @Override
//QtCreator     public ActionMode onWindowStartingActionMode(Callback callback)
//QtCreator     {
//QtCreator         SialanApplication.InvokeResult res = SialanApplication.invokeDelegate(callback);
//QtCreator         if (res.invoked)
//QtCreator             return (ActionMode)res.methodReturns;
//QtCreator         else
//QtCreator             return super.onWindowStartingActionMode(callback);
//QtCreator     }
//QtCreator     public ActionMode super_onWindowStartingActionMode(Callback callback)
//QtCreator     {
//QtCreator         return super.onWindowStartingActionMode(callback);
//QtCreator     }
//QtCreator     //---------------------------------------------------------------------------
//@ANDROID-11
    //////////////// Activity API 12 /////////////

//@ANDROID-12
//QtCreator     @Override
//QtCreator     public boolean dispatchGenericMotionEvent(MotionEvent ev)
//QtCreator     {
//QtCreator         if (SialanApplication.m_delegateObject != null  && SialanApplication.dispatchGenericMotionEvent != null)
//QtCreator             return (Boolean) SialanApplication.invokeDelegateMethod(SialanApplication.dispatchGenericMotionEvent, ev);
//QtCreator         else
//QtCreator             return super.dispatchGenericMotionEvent(ev);
//QtCreator     }
//QtCreator     public boolean super_dispatchGenericMotionEvent(MotionEvent event)
//QtCreator     {
//QtCreator         return super.dispatchGenericMotionEvent(event);
//QtCreator     }
//QtCreator     //---------------------------------------------------------------------------
//QtCreator 
//QtCreator     @Override
//QtCreator     public boolean onGenericMotionEvent(MotionEvent event)
//QtCreator     {
//QtCreator         if (SialanApplication.m_delegateObject != null  && SialanApplication.onGenericMotionEvent != null)
//QtCreator             return (Boolean) SialanApplication.invokeDelegateMethod(SialanApplication.onGenericMotionEvent, event);
//QtCreator         else
//QtCreator             return super.onGenericMotionEvent(event);
//QtCreator     }
//QtCreator     public boolean super_onGenericMotionEvent(MotionEvent event)
//QtCreator     {
//QtCreator         return super.onGenericMotionEvent(event);
//QtCreator     }
//QtCreator     //---------------------------------------------------------------------------
//@ANDROID-12

}