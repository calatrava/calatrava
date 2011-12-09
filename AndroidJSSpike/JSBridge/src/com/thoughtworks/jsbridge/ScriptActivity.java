package com.thoughtworks.jsbridge;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.util.Log;

import java.io.*;

public class ScriptActivity extends Activity {
    private RhinoService mScriptService;
    private ServiceConnection mConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName componentName, IBinder binder) {
            Log.v(RhinoService.TAG, "Connection to " + componentName + " is established");
            mScriptService = ((RhinoService.LocalBinder) binder).getService();
            initScripts();
        }

        public void onServiceDisconnected(ComponentName componentName) {
            Log.v(RhinoService.TAG, "Connection to " + componentName + "is disconnected");
        }
    };

    @Override
    protected void onStart() {
        super.onStart();
        Intent serviceIntent = new Intent(this, RhinoService.class);
        bindService(serviceIntent, mConnection, Context.BIND_AUTO_CREATE);
    }

    @Override
    protected void onStop() {
        super.onStop();
        unbindService(mConnection);
    }

    protected Reader readAsset(String filePath) {
        InputStream stream = null;
        try {
            stream = getAssets().open(filePath);
        } catch (IOException e) {
            e.printStackTrace();
        }

        return new BufferedReader(new InputStreamReader(stream));
    }

    protected void initScripts() {
        //load global scripts here.
    }

    public RhinoService getScriptService() {
        return mScriptService;
    }

}
