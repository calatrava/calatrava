package com.thoughtworks.jsbridge;

import android.app.Activity;
import android.content.res.Resources;
import android.os.Bundle;
import android.view.View;
import android.webkit.WebBackForwardList;
import android.webkit.WebSettings;
import android.webkit.WebView;
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

        TextView textOnScreen = (TextView) findViewById(R.id.textOnScreen);
        webView = (WebView) findViewById(R.id.webView);
        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        JSResponse response = new JSResponse();
        webView.addJavascriptInterface(response, "response");
        String data = "<html><body><script type='javascript'>response.setValue('Hello, from WebView..');</script></body></html>";

        webView.loadDataWithBaseURL(null, data, "text/html", "UTF-8", null);


        textOnScreen.setText(response.value);

    }


    private class JSResponse{
        private String value;

        public void setValue(String value){
            System.out.println("=========");
            System.out.println(value);
            this.value = value;
        }
    }
}
