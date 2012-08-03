package com.calatrava.bridge;

import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.util.Log;
import com.calatrava.bridge.RhinoService;
import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.StatusLine;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpRequestBase;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.conn.ConnectTimeoutException;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicHeader;
import org.apache.http.params.HttpConnectionParams;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.*;
import java.net.SocketTimeoutException;
import java.util.Iterator;

public class AjaxRequestManager {

  private static String TAG = AjaxRequestManager.class.getSimpleName();
  private static AjaxRequestManager sharedManager;
  private Context context;
  private RhinoService rhino;

  public AjaxRequestManager(Context context, RhinoService rhino) {
    this.context = context;
    this.rhino = rhino;
  }

  public void makeRequest(String requestId, String url, String method, String body, String customHeaders) {
    Log.d(TAG, "requestId is :" + requestId);
    Log.d(TAG, "URL is :" + url);
    Log.d(TAG, "method :" + method);
    Log.d(TAG, "body :" + body);
    Log.d(TAG, "custom headers :" + customHeaders);

    new AjaxRequest().execute(requestId, url, method, body, customHeaders);
  }

  private HttpRequestBase httpMethod(String url, String method) {
    return method.equals("post") ? new HttpPost(url) : new HttpGet(url);
  }

  public static AjaxRequestManager sharedManager() {
    return sharedManager;
  }

  public static void setSharedManager(AjaxRequestManager ajaxRequestManager) {
    Log.d(TAG, "Set shared manager");
    sharedManager = ajaxRequestManager;
  }

  class AjaxRequest extends AsyncTask<String, Void, Void> {

    public static final int CONNECTION_TIMEOUT = 5;
    public static final int SO_TIMEOUT = 60;

    @Override
    protected Void doInBackground(String... params) {
      String requestId = params[0];
      String url = params[1];
      String method = params[2];
      String body = params[3];
      String customHeaders = params[4];
      try {
        Log.d(TAG, "About to show loader");
        context.sendBroadcast(new Intent("com.calatrava.ajax.start"));
        Log.d(TAG, "Issuing request");
        HttpClient httpclient = new DefaultHttpClient();
        HttpResponse response;
        HttpUriRequest request;

        if(method.equals("GET")) {
          request = new HttpGet(url);
        } else {
          HttpPost httpPost = new HttpPost(url);
          httpPost.setEntity(new StringEntity(body));
          httpPost.setHeaders(addHeaders(customHeaders));
          request = httpPost;
        }

        HttpConnectionParams.setConnectionTimeout(httpclient.getParams(), CONNECTION_TIMEOUT * 1000);
        HttpConnectionParams.setSoTimeout(httpclient.getParams(), SO_TIMEOUT * 1000);
        response = httpclient.execute(request);

        StatusLine statusLine = response.getStatusLine();
        String responseBody = readResponseBody(response);
        Log.d(TAG, "Response is :" + statusLine.getStatusCode());
        Log.d(TAG, "Response is :" + responseBody);
        if (statusLine.getStatusCode() < 300) {
          Log.d(TAG, "Invoke success callback");
          rhino.invokeSuccessCallback(requestId, responseBody);
        } else {
          Log.d(TAG, "Invoke failure callback");
          rhino.invokeFailureCallback(requestId, statusLine.getStatusCode(), responseBody);
        }
      } catch (UnsupportedEncodingException e) {
        Log.d(TAG, "Unable to construct an entity.", e);
      } catch (IOException e) {
        Log.d(TAG, "Request threw exception", e);
        Log.d(TAG, "requestId: " + requestId);
        rhino.invokeFailureCallback(requestId, 500, "IOException");
      } finally {
        Log.d(TAG, "About to hide loader");
        context.sendBroadcast(new Intent("com.calatrava.ajax.finish"));
      }
      return null;
    }

    private Header[] addHeaders(String customHeaders) {
      Header[] headers = null;
      try {
        if (customHeaders != null && customHeaders.trim() != "") {
          JSONObject jsonCustomHeaders = new JSONObject(customHeaders);
          headers = new Header[jsonCustomHeaders.length()];
          Iterator<String> keys = jsonCustomHeaders.keys();
          int cnt = 0;
          while (keys.hasNext()) {

            String headerKey = keys.next();
            String headerVal = jsonCustomHeaders.getString(headerKey);
            headers[cnt] = new BasicHeader(headerKey, headerVal);
            cnt++;
          }
        }
      } catch (JSONException e) {
      }
      if (headers != null) {
        Log.d(TAG, "Headers are: " + headers);
        for (Header header : headers) {
          Log.d(TAG, header.getName() + ":" + header.getValue());
        }
      }
      return headers;
    }

    private String readResponseBody(HttpResponse response) {
      StringBuilder builder = new StringBuilder();
      try {
        HttpEntity entity = response.getEntity();
        InputStream content = entity.getContent();
        BufferedReader reader = new BufferedReader(new InputStreamReader(content), 1024);
        String line;
        while ((line = reader.readLine()) != null) {
          builder.append(line);
        }

      } catch (Exception e) {
        Log.d(TAG, "Error ");
        e.printStackTrace();
      }
      return builder.toString();
    }
  }
}
