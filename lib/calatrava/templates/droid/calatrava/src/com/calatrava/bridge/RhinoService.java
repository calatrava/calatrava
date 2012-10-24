package com.calatrava.bridge;

import android.app.Service;
import android.content.Intent;
import android.os.*;
import android.util.Log;
import org.mozilla.javascript.Context;
import org.mozilla.javascript.Scriptable;
import org.mozilla.javascript.ScriptableObject;

import java.io.IOException;
import java.io.Reader;
import java.lang.String;
import java.lang.ThreadGroup;
import java.util.concurrent.CountDownLatch;

public class RhinoService extends Service {
  public static String TAG = RhinoService.class.getSimpleName();

  private Scriptable mScope;
  private JSEvalThread evaller = new JSEvalThread();

  private final IBinder mBinder = new LocalBinder();
  
  CountDownLatch countDownLatch = new CountDownLatch(1);

  @Override
  public IBinder onBind(Intent intent) {
    return mBinder;
  }

  @Override
  public void onCreate() {
    super.onCreate();
    Log.d(TAG, "RhinoService created.");
  }

  public void initRhino() {
    Context ctxt = enterContext();
    try {
      mScope = ctxt.initStandardObjects();

      Object wrappedRegistry = Context.javaToJS(PageRegistry.sharedRegistry(), mScope);
      ScriptableObject.putProperty(mScope, "pageRegistry", wrappedRegistry);
      ScriptableObject.putProperty(mScope, "pluginRegistry", Context.javaToJS(PluginRegistry.sharedRegistry(), mScope));
      ScriptableObject.putProperty(mScope, "androidRuntime", this);

      Object wrappedAjaxRequestManagerRegistry = Context.javaToJS(AjaxRequestManager.sharedManager(), mScope);
      ScriptableObject.putProperty(mScope, "ajaxRequestManagerRegistry", wrappedAjaxRequestManagerRegistry);

      evaller.start();
      try {
        countDownLatch.await();
      } catch (InterruptedException e) {
        Log.d(TAG, "Interrupted Exception when waiting for JSEvalThread");
        e.printStackTrace();
      }
    } finally {
      Context.exit();
    }
  }

  private Context enterContext() {
    Context ctxt = Context.enter();
    // No pre-compilation
    ctxt.setOptimizationLevel(-1);
    return ctxt;
  }

  @Override
  public void onDestroy() {
    Log.d(TAG, "RhinoService destroyed.");
    super.onDestroy();
  }

  public void load(Reader source, String name) {
    evaller.load(source, name);
  }

  public void triggerEvent(String proxy, String eventId, String[] extraArgs) {
    evaller.triggerEvent(proxy, eventId, extraArgs);
  }

  public void invokeSuccessCallback(String requestId, String response) {
    evaller.ajaxSuccessfulResponse(requestId, response);
  }

  public void invokeFailureCallback(String requestId, int statusCode, String responseBody) {
    evaller.ajaxFailureResponse(requestId, statusCode, responseBody);
  }

  public void log(String message) {
    Log.d(TAG, message);
  }

  public void callJsFunction(String function) {
    evaller.callJsFunction(function);
  }

  public void callJsFunction(String function, String[] args) {
    evaller.callJsFunction(function, args);
  }

  public class LocalBinder extends Binder {
    public RhinoService getService() {
      return RhinoService.this;
    }
  }

  class JSEvalThread extends Thread {
    private Handler handler;
    private Context ctxt;

    public JSEvalThread() {
      super(null, null, "js eval thread", 32768);
    }
    
    public void load(final Reader source, final String name) {
      handler.post(new Runnable() {
        @Override
        public void run() {
          try {
            Log.d(TAG, "Loading file: '" + name + "'");
            ctxt.evaluateReader(mScope, source, name, 0, null);
          } catch (IOException e) {
            Log.e(TAG, "Error loading file: '" + name + "'", e);
          }
        }
      });
    }

    public void callJsFunction(String function) {
      String js = "{0}();"
          .replace("{0}", function);
      dispatchJs(js);
    }

    public void callJsFunction(String function, String[] args) {
      StringBuilder sb = new StringBuilder("");
      boolean first = true;
      for (String arg : args) {
        if (!first) {
          sb.append(",");
        }
        first = false;
        sb.append("'" + arg + "'");
      }

      String js = "{0}({1});"
        .replace("{0}", function)
        .replace("{1}", sb.toString());

      Log.d(TAG, "Dispatching: " + js);

      dispatchJs(js);
    }

    public void triggerEvent(String proxy, String eventId, String[] extraArgs) {
      StringBuilder sb = new StringBuilder("");
      for (String arg : extraArgs) {
        sb.append(", '");
        sb.append(arg);
        sb.append("'");
      }
      String js = "calatrava.inbound.dispatchEvent('{0}', '{1}'{2});"
          .replace("{0}", proxy)
          .replace("{1}", eventId)
          .replace("{2}", sb.toString());

      Log.d(TAG, "Dispatching: " + js);

      dispatchJs(js);
    }

    public void ajaxSuccessfulResponse(String requestId, String json) {
      String js = "calatrava.inbound.successfulResponse('{0}', '{1}');"
          .replace("{0}", requestId)
          .replace("{1}", json);
      dispatchJs(js);
    }

    public void ajaxFailureResponse(String requestId, int statusCode, String responseBody) {
      String js = "calatrava.inbound.failureResponse('{0}', {1}, '{2}');"
          .replace("{0}", requestId)
          .replace("{1}", Integer.toString(statusCode))
          .replace("{2}", responseBody);
      dispatchJs(js);
    }

    public void run() {
      Looper.prepare();
      ctxt = enterContext();

      try {
        handler = new Handler();
        countDownLatch.countDown();
        Looper.loop();
      }
      finally {
        Context.exit();
      }
    }

    private void dispatchJs(final String js) {
      handler.post(new Runnable() {
        @Override
        public void run() {
          eval(js);
        }
      });
    }

    private void eval(String jsCode) {
      ctxt.evaluateString(mScope, jsCode, "<Bridge>", 1, null);
    }

  }
}
