package com.calatrava.shell;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.webkit.WebView;
import com.calatrava.bridge.PageStateManager;
import com.calatrava.bridge.RegisteredActivity;
import com.calatrava.bridge.RhinoService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.FutureTask;
import java.util.concurrent.Semaphore;

public abstract class WebViewActivity extends RegisteredActivity {
  private String TAG = WebViewActivity.class.getSimpleName();

  private JSContainer jsContainer;
  private WebView webView;
  private boolean pageReady = false;

  private BroadcastReceiver receiver = new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
      if ("com.calatrava.dialog".equals(intent.getAction())) {
        String name = intent.getExtras().getString("name");
        webView.loadUrl("javascript:window." + getPageName() + "View.showDialog('" + name + "');");
      }
    }
  };

  @Override
  protected void onCreate(Bundle data)
  {
    super.onCreate(data);
  }

  @Override
  protected void initializePageStateManager() {
    jsContainer = new JSContainer(getRhino(), getPageName());
    webView = new WebView(this);
    pageStateManager = new WebViewPageStateManager(this, jsContainer, getPageName(), webView);
  }

  @Override
  protected void onResume() {
    super.onResume();
    registerReceiver(receiver, new IntentFilter("com.calatrava.dialog"));
  }

  @Override
  protected void onPause() {
    super.onPause();

    unregisterReceiver(receiver);
  }

  @Override
  public void onDestroy() {
    super.onDestroy();
  }

  public String getFieldValue(final String field) {
    assert (getFields().contains(field));

    Log.d(TAG, "Get value for field: " + field + " on page '" + getPageName() + "'");

    FutureTask<String> fieldValue = new FutureTask<String>(new Callable<String>() {
      public String call() throws Exception {
        webView.loadUrl("javascript:container.provideValueFor('" + field + "', window." + getPageName() + "View.get('" + field + "'));");
        return jsContainer.retrieveValueFor(field);
      }
    });

    runOnUiThread(fieldValue);

    String value;
    try {
      value = fieldValue.get();
    } catch (Exception e) {
      e.printStackTrace();
      // TODO: Signal failure to the UI thread
      return "";
    }

    Log.d(TAG, "(getFieldValue) : Got the field [" + field + "] value = " + value);
    return value;
  }

  public void render(final String json) {
    runOnUiThread(new Runnable() {
      public void run() {
        jsContainer.setJsObject(json);
        Log.d(TAG, "render page: " + getPageName());

        webView.loadUrl("javascript:container.onRenderComplete(window." + getPageName() + "View.render(JSON.parse(container.getJsObject())));");
      }
    });
  }

  protected abstract List<String> getEvents();

  protected abstract List<String> getFields();

  protected int getBackgroundColor(){
    return Color.TRANSPARENT;
  }

  public void pageReadiness(boolean pageState) {
    this.pageReady = pageState;
  }

  public boolean pageState() {
    return pageReady;
  }

  public class JSContainer {
    private String TAG = JSContainer.class.getSimpleName();

    private Map<String, String> lastValue = new HashMap<String, String>();
    private Map<String, Semaphore> valueAvailable = new HashMap<String, Semaphore>();
    private RhinoService rhino;
    private String pageName;
    private String jsObject;

    public JSContainer(RhinoService rhino, String pageName) {
      this.rhino = rhino;
      this.pageName = pageName;
    }

    public void setJsObject(String jsObject) {
      this.jsObject = jsObject;
    }

    public String getJsObject() {
      return jsObject;
    }

    public void hasField(String field) {
      valueAvailable.put(field, new Semaphore(0));
    }

    public void provideValueFor(String field, String value) {
      Log.d(TAG, "Got value '" + value + "' for field '" + field + "'");
      lastValue.put(field, value);
      valueAvailable.get(field).release();
    }

    public String retrieveValueFor(String field) {
      try {
        valueAvailable.get(field).acquire();
      } catch (InterruptedException e) {
        return retrieveValueFor(field);
      }

      String value = lastValue.remove(field);
      Log.d(TAG, "Reading value '" + value + "' for field '" + field + "'");
      return value;
    }

    public void handleEvent(String event, String... extraArgs) {
      Log.d(TAG, "User clicked");
      Log.d(TAG, "Current thread is " + Thread.currentThread().getId());

      if (extraArgs != null) {
        Log.d(TAG, "extraArgs = " + extraArgs.length);
        for (String arg : extraArgs) {
          Log.d(TAG, "arg = '" + arg + "'");
        }
      } else {
        Log.d(TAG, "extraArgs were null!");
      }
      triggerEvent(event, extraArgs);
    }

    public void onRenderComplete(Object ignored) {
      runOnUiThread(new Runnable() {
        public void run() {
          for (String event : getEvents()) {
            Log.d(TAG, "About to bind event '" + event + "'");
            webView.loadUrl("javascript:window." + getPageName() + "View.bind('" + event + "', function() { container.handleEvent('" + event + "', _.toArray(arguments)); });");
          }
        }
      });
    }
  }
}
