package com.calatrava.bridge;

import android.app.Activity;
import android.content.*;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;

public abstract class RegisteredActivity extends Activity {
  private String TAG = RegisteredActivity.class.getSimpleName();

  private RhinoService rhino;
  private RequestLoader spinner = new RequestLoader(this);

  private BroadcastReceiver receiver = new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
      Log.d(TAG, "Received broadcast");
      if (intent.getAction().endsWith("start")) {
        spinner.onLoadingStart();
      } else if (intent.getAction().endsWith("finish")) {
        spinner.onLoadingFinish();
      } else if (intent.getAction().equals("com.calatrava.command")) {
        PluginRegistry.sharedRegistry().runCommand(intent, RegisteredActivity.this);
      }
    }
  };

  @Override
  protected void onCreate(Bundle availableData) {
    super.onCreate(availableData);
    rhino = ((CalatravaApplication)getApplication()).getRhino();
  }

  @Override
  protected void onResume() {
    super.onResume();
    registerReceiver(receiver, new IntentFilter("com.calatrava.ajax.start"));
    registerReceiver(receiver, new IntentFilter("com.calatrava.ajax.finish"));
    registerReceiver(receiver, new IntentFilter("com.calatrava.command"));
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

  public void triggerEvent(String event, String... extraArgs) {
    PageRegistry.sharedRegistry().triggerEvent(getPageName(), event, extraArgs);
  }
  
  public void invokeWidgetCallback(String...args) {
    rhino.callJsFunction("calatrava.inbound.invokeCallback", args);
  }

  protected abstract String getPageName();

  public abstract String getFieldValue(String field);

  public abstract void render(final String json);

  public RhinoService getRhino()
  {
    return rhino;
  }
}
