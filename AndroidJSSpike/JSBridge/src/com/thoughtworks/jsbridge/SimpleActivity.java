package com.thoughtworks.jsbridge;

import android.app.Activity;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.webkit.*;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.StatusLine;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.ResponseCache;
import java.net.URL;
import java.util.concurrent.Executor;

public class SimpleActivity extends Activity {

    private static final String EURO_VALUE = "EURO_VALUE";
    WebView webView;
    private TextView textOnScreen;
    private EditText currencyInUsd;
    private NetworkService networkService;

    /**
     * Called when the activity is first created.
     */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        networkService = new NetworkService();
        textOnScreen = (TextView) findViewById(R.id.textOnScreen);
        currencyInUsd = (EditText) findViewById(R.id.valueInUSD);

        webView = (WebView) getLastNonConfigurationInstance();

        if (savedInstanceState != null) {
            CharSequence savedEuroValue = savedInstanceState.getCharSequence(EURO_VALUE);
            textOnScreen.setText(savedEuroValue);
        }

        if (webView == null) {
            initializeWebView();
        }

        Button convertButton = (Button) findViewById(R.id.convert);
        convertButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View view) {
                String javascriptUrl = "javascript:currencyHandler(" + currencyInUsd.getText() + ");";
                Log.d("cc-android", "Calling javascript - " + javascriptUrl);
                webView.loadUrl(javascriptUrl);
            }
        });

    }

    private void initializeWebView() {
        webView = (WebView) findViewById(R.id.webView);
//                new WebView(this);

        webView.getSettings().setJavaScriptEnabled(true);
        webView.addJavascriptInterface(this, "response");
        webView.addJavascriptInterface(networkService, "networkService");

        WebViewClient client = new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                Log.d("cc-android", "Finished loading... " + url);
            }

            @Override
            public void onLoadResource(WebView view, String url) {
                Log.d("cc-android", "Now loading resource... " + url);
            }
        };

        webView.setWebViewClient(client);
        webView.loadUrl("file:///android_asset/html/currencyConverter.html");
    }


    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putCharSequence(EURO_VALUE, textOnScreen.getText());
    }

    @Override
    public Object onRetainNonConfigurationInstance() {
        return webView;
    }

    private class NetworkService {
        public void ajax(String url, String jsHandler) {
            Log.d("cc-android", "Calling Android Network Service - " + url);
            Log.d("cc-android", "With handler - " + jsHandler);
            new FetchResponse(jsHandler).execute(url);
        }
    }

    public class FetchResponse extends AsyncTask<String, String, String> {
        private String jsHandler;

        public FetchResponse(String jsHandler) {
            this.jsHandler = jsHandler;
        }

        @Override
        protected String doInBackground(String... url) {
            HttpClient httpclient = new DefaultHttpClient();
            HttpResponse response;
            String responseString = null;
            try {
                response = httpclient.execute(new HttpGet(url[0]));
                StatusLine statusLine = response.getStatusLine();
                if (statusLine.getStatusCode() == HttpStatus.SC_OK) {
                    ByteArrayOutputStream out = new ByteArrayOutputStream();
                    response.getEntity().writeTo(out);
                    out.close();
                    responseString = out.toString();
                } else {
                    //Closes the connection.
                    response.getEntity().getContent().close();
                    throw new IOException(statusLine.getReasonPhrase());
                }
            } catch (ClientProtocolException e) {
                //TODO Handle problems..
            } catch (IOException e) {
                //TODO Handle problems..
            }
            return responseString;
        }

        @Override
        protected void onPostExecute(String result) {
            String javascriptUrl = "javascript:" + jsHandler + "( '" + result.replace("'", "\\'") + "' );";
            Log.d("cc-android", "Calling callback - " + javascriptUrl);
            webView.loadUrl(javascriptUrl);
        }
    }

    public void log(String message) {
        Log.d("cc-android", message);
    }

    public void handleResponse(final String value) {
        this.runOnUiThread(new Runnable() {
            public void run() {
                textOnScreen.setText(value);
            }
        });
    }
}
