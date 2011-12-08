package com.thoughtworks.jsbridge;

import android.app.Activity;
import android.content.DialogInterface;
import android.content.res.Resources;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.webkit.*;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

public class SimpleActivity extends Activity {

    WebView webView;
    private TextView textOnScreen;
    private EditText currencyInUsd;

    /**
     * Called when the activity is first created.
     */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        textOnScreen = (TextView) findViewById(R.id.textOnScreen);
        currencyInUsd = (EditText) findViewById(R.id.valueInUSD);
        webView = new WebView(this);

        webView.getSettings().setJavaScriptEnabled(true);
        webView.addJavascriptInterface(this, "response");

        WebViewClient client = new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                Log.d("cc-android" , "Finished loading... " + url);
            }

            @Override
            public void onLoadResource(WebView view, String url) {
                Log.d("cc-android" , "Now loading resource... " + url);
            }

        };

        webView.setWebViewClient(client);
        webView.loadUrl("file:///android_asset/html/currencyConverter.html");


        Button convertButton = (Button) findViewById(R.id.convert);
        convertButton.setOnClickListener(new View.OnClickListener(){
            public void onClick(View view) {
                String javascriptUrl = "javascript:currencyHandler(" + currencyInUsd.getText() + ");";
                Log.d("cc-android" , "Calling javascript - " + javascriptUrl);
                webView.loadUrl(javascriptUrl);
            }
        });

    }

    public void handleResponse(final String value){
        this.runOnUiThread(new Runnable() {
            public void run() {
                textOnScreen.setText(value);
            }
        });
    }
}
