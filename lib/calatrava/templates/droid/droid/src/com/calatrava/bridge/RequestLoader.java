package com.calatrava.bridge;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.ProgressDialog;
import android.content.Context;
import android.util.Log;

public class RequestLoader {
  private String TAG = RequestLoader.class.getSimpleName();

  private ProgressDialog dialog;
  private Activity parent;

  public RequestLoader(Activity parent) {
    this.parent = parent;
  }

  public void onLoadingStart() {
    Log.d(TAG, "About to create loader");
    dialog = new ProgressDialog(parent);
    dialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
    dialog.setMessage("Loading...");
    dialog.setCancelable(false);
    dialog.show();
  }
  
  public void onLoadingFinish() {
    dialog.hide();
  }
}
