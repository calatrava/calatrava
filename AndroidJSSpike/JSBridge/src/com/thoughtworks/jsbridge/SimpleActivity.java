package com.thoughtworks.jsbridge;

import android.app.Activity;
import android.content.res.Resources;
import android.os.Bundle;
import android.view.View;
import android.webkit.WebBackForwardList;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;

public class SimpleActivity extends Activity {

    WebView webView;

    /**
     * Called when the activity is first created.
     */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        final TextView textOnScreen = (TextView) findViewById(R.id.textOnScreen);
        webView = (WebView) findViewById(R.id.webView);
        webView.getSettings().setJavaScriptEnabled(true);

        final JSResponse response = new JSResponse();

        webView.addJavascriptInterface(response, "response");
        String data = "<html><body><script type='text/javascript'>window.response.setValue('Hello, from WebView..');</script></body></html>";

        WebViewClient client = new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                textOnScreen.setText(response.value);
            }
        };
        webView.setWebViewClient(client);

        webView.loadData(data, "text/html", "UTF-8");
    }


    private class JSResponse {
        private String value;

        public void setValue(String value) {
            System.out.println("=========");
            System.out.println(value);
            this.value = value;
        }
    }
}
