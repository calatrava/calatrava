package com.calatrava.shell;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.util.Log;
import android.webkit.JsResult;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.calatrava.bridge.RegisteredActivity;
import com.calatrava.bridge.RhinoService;
import com.calatrava.bridge.PageRegistry;

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
  private RhinoService rhino;

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
  protected void onRhinoConnected(RhinoService rhino) {
    this.rhino = rhino;
    jsContainer = new JSContainer(rhino, getPageName());
    loadPage();
  }

  @Override
  protected void onResume() {
    super.onResume();

    onPageLoadCompleted();

    if (rhino != null) {
      pageHasOpened();
    }
    registerReceiver(receiver, new IntentFilter("com.calatrava.dialog"));
  }

  @Override
  protected void onPause() {
    super.onPause();

    PageRegistry.sharedRegistry().pageOffscreen(getPageName());
    unregisterReceiver(receiver);
  }

  @Override
  public void onDestroy() {
    super.onDestroy();

    PageRegistry.sharedRegistry().unregisterPage(getPageName());
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

  protected void loadPage() {
    PageRegistry.sharedRegistry().registerPage(getPageName(), this);

    webView = new WebView(this);
    setContentView(webView);

    webView.getSettings().setJavaScriptEnabled(true);
    webView.getSettings().setDomStorageEnabled(true);
    webView.setScrollBarStyle(webView.SCROLLBARS_OUTSIDE_OVERLAY);
    webView.setScrollbarFadingEnabled(true);
    webView.setBackgroundColor(0xffffffff);
    webView.addJavascriptInterface(jsContainer, "container");

    webView.setWebViewClient(new WebViewClient() {
      @Override
      public void onPageFinished(WebView view, String url) {
        super.onPageFinished(view, url);
        Log.d(TAG, "Webview finished loading a URL");

        pageReady = true;
        onPageLoadCompleted();
      }
    });

    webView.setWebChromeClient(new WebChromeClient() {
      @Override
      public boolean onJsAlert(WebView view, String url, String message, JsResult result) {
        Log.d(TAG, "Received JS alert: '" + message + "'");
        return false;
      }
    });

    webView.loadUrl("file:///android_asset/calatrava/views/" + getPageName() + ".html");
    pageHasOpened();
  }

  private void pageHasOpened() {
    triggerEvent("pageOpened", new String[] {});
  }

  private void onPageLoadCompleted() {
    if (jsContainer != null && pageReady) {
      jsContainer.onRenderComplete(null);

      for (String field : getFields()) {
        jsContainer.hasField(field);
      }

      PageRegistry.sharedRegistry().pageOnscreen(getPageName());
    }
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
