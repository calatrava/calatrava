package com.thoughtworks.jsbridge;

import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

public class NetworkService {
    private static final String TAG = "NetworkService";
    private final Handler handler;

    public NetworkService(Handler handler) {
        this.handler = handler;
    }

    public void ajax(String url, String jsHandler) {
        Log.d(TAG, "Calling Android Network Service - " + url);
        Log.d(TAG, "With handler - " + jsHandler);

        Message msg = new Message();
        Bundle data = new Bundle();
        data.putString("url", url);
        data.putString("callback", jsHandler);
        msg.setData(data);
        handler.dispatchMessage(msg);
    }
}
