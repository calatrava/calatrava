package com.thoughtworks.jsbridge;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
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
    private final Handler mNetworkHandler = new Handler() {
        @Override
        public void handleMessage(final Message msg) {
            new FetchResponse() {
                @Override
                protected void onPostExecute(String response) {
                    Log.d(FetchResponse.TAG, "Response: " + response);
                    if (response != null) {
                        String javascriptUrl = "javascript:" + msg.getData().getString("callback") + "( '" + response.replace("'", "\\'") + "' );";
                        getScriptService().eval(javascriptUrl);
                    }
                }
            }.execute(msg.getData().getString("url"));
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

        return new BufferedReader(new InputStreamReader(stream), 5 * 1024);
    }

    protected void initScripts() {
        //register console.log function
        //associate equivalent of console.log
        getScriptService().bind("out", System.out);

        //bind Network Service
        getScriptService().bind("tw_networkService", new NetworkService(mNetworkHandler));

        //load global scripts here.
        getScriptService().load(readAsset("domain/network_service.js"), "network_service.js");
    }

    public RhinoService getScriptService() {
        return mScriptService;
    }
}
