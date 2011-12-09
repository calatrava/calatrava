package com.thoughtworks.jsbridge;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;
import android.util.Log;
import org.mozilla.javascript.Context;
import org.mozilla.javascript.Scriptable;

import java.io.IOException;
import java.io.Reader;
import java.math.BigDecimal;
import java.util.concurrent.TimeUnit;

public class RhinoService extends Service {
    public static String TAG = RhinoService.class.getSimpleName();
    private static final BigDecimal DIVISOR = BigDecimal.valueOf(TimeUnit.NANOSECONDS.convert(1, TimeUnit.MILLISECONDS));

    private Context cx;
    private Scriptable scope;
    private final IBinder mBinder = new LocalBinder();

    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        cx = Context.enter();
        //optimization level -1 means no pre-compilation.
        cx.setOptimizationLevel(-1);
        scope = cx.initStandardObjects();
    }

    @Override
    public void onStart(Intent intent, int startId) {
        super.onStart(intent, startId);
        Log.v(TAG, "Rhino Service started");
    }

    public String eval(String source) {
        final long startTime = System.nanoTime();

        Object result = cx.evaluateString(scope, source, "<custom>", 1, null);

        final long endTime = System.nanoTime();
        Log.v(TAG, source + getElapsedTime(startTime, endTime));

        return cx.toString(result);
    }

    public void load(Reader source, String name) {
        try {
            cx.evaluateReader(scope, source, name, 0, null);
        } catch (IOException e) {
            Log.e(TAG, "Error loading the file: " + name, e);
        }

        Log.d(TAG, "Loaded file: " + name);
    }

    public Scriptable getScope() {
        return scope;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Context.exit();
        Log.v(TAG, "Rhino Service destroyed.");
    }

    public class LocalBinder extends Binder {
        RhinoService getService() {
            return RhinoService.this;
        }
    }

    private String getElapsedTime(long start, long end) {
        return " - took " + BigDecimal.valueOf(end - start).divide(DIVISOR).toPlainString() + "ms";
    }
}
