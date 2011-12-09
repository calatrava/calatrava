package com.thoughtworks.jsbridge;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;
import org.mozilla.javascript.Context;
import org.mozilla.javascript.ScriptableObject;

import java.io.IOException;
import java.io.Reader;

public class RhinoService extends Service {
    private Context cx;
    private ScriptableObject scope;
    private static RhinoService mRhinoService;

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        cx = Context.enter();
        cx.setOptimizationLevel(-1);
        scope = cx.initStandardObjects();

        mRhinoService = this;
    }

    @Override
    public void onStart(Intent intent, int startId) {
        super.onStart(intent, startId);
    }

    public String eval(String source) {
        Log.d("cc-android", source);
        Object result = cx.evaluateString(scope, source, "<custom>", 1, null);
        return cx.toString(result);
    }

    public void load(Reader source, String name) {
        try {
            cx.evaluateReader(scope, source, name, 0, null);
        } catch (IOException e) {
            Log.d("cc-android", "Error loading the file: " + name);
        }

        android.util.Log.d("cc-android", "Loaded file: " + name);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Context.exit();
    }

    public static RhinoService getInstance() {
        return mRhinoService;
    }
}
