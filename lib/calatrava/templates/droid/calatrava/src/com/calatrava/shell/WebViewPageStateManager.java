package com.calatrava.shell;

import android.app.Activity;
import android.util.Log;
import android.webkit.JsResult;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import com.calatrava.bridge.PageStateManager;

public class WebViewPageStateManager implements PageStateManager {

  private static final String TAG = WebViewPageStateManager.class.getSimpleName();
  private WebViewActivity webViewActivity;
  private WebViewActivity.JSContainer jsContainer;
  private final String pageName;
  private final WebView webView;

  public WebViewPageStateManager(Activity activity, WebViewActivity.JSContainer jsContainer, String pageName, WebView webView) {
    this.webViewActivity = (WebViewActivity) activity;
    this.jsContainer = jsContainer;
    this.pageName = pageName;
    this.webView = webView;
  }

  public void onCreateProcessing() {
    webViewActivity.registerPage();

    webViewActivity.setContentView(webView);

    webView.getSettings().setJavaScriptEnabled(true);
    webView.getSettings().setDomStorageEnabled(true);
    webView.setScrollBarStyle(webView.SCROLLBARS_OUTSIDE_OVERLAY);
    webView.setScrollbarFadingEnabled(true);
    webView.addJavascriptInterface(jsContainer, "container");

    webView.setWebViewClient(new WebViewClient() {
      @Override
      public void onPageFinished(WebView view, String url) {
        super.onPageFinished(view, url);
        Log.d(TAG, "Webview finished loading a URL");

        webViewActivity.pageReadiness(true);
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

    webView.loadUrl("file:///android_asset/calatrava/views/" + pageName + ".html");
    pageHasOpened();
  }

  public void onResumeProcessing() {
    onPageLoadCompleted();
    pageHasOpened();
  }

  public void onPauseProcessing() {
    webViewActivity.pageOffScreen();
  }

  public void onDestroyProcessing() {
    webViewActivity.unRegisterPage();
  }

  private void onPageLoadCompleted() {
    if (jsContainer != null && webViewActivity.pageState()) {
      jsContainer.onRenderComplete(null);

      for (String field : webViewActivity.getFields()) {
        jsContainer.hasField(field);
      }

      webViewActivity.pageOnScreen();
    }
  }

  private void pageHasOpened() {
    webViewActivity.triggerEvent("pageOpened", new String[]{});
  }

}
