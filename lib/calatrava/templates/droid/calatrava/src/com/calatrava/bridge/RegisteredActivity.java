package com.calatrava.bridge;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.*;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;

public abstract class RegisteredActivity extends Activity {
  private String TAG = RegisteredActivity.class.getSimpleName();

  private RhinoService rhino;
  private RequestLoader spinner = new RequestLoader(this);
  private ServiceConnection connection = new ServiceConnection() {
    public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
      rhino = ((RhinoService.LocalBinder) iBinder).getService();
      RegisteredActivity.this.onRhinoConnected(rhino);
    }

    public void onServiceDisconnected(ComponentName componentName) {

    }
  };

  private BroadcastReceiver receiver = new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
      Log.d(TAG, "Received broadcast");
      if (intent.getAction().endsWith("start")) {
        spinner.onLoadingStart();
      } else if (intent.getAction().endsWith("finish")) {
        spinner.onLoadingFinish();
      } else {
        AlertDialog.Builder builder = new AlertDialog.Builder(RegisteredActivity.this);
        builder.setMessage(intent.getExtras().getString("message"))
            .setCancelable(false)
            .setPositiveButton("OK", new DialogInterface.OnClickListener() {
              @Override
              public void onClick(DialogInterface dialogInterface, int i) {
                dialogInterface.dismiss();
              }
            });
        AlertDialog dialog = builder.create();
        dialog.show();
      }
    }
  };

  @Override
  protected void onCreate(Bundle availableData) {
    super.onCreate(availableData);
    Intent serviceIntent = new Intent(this, RhinoService.class);
    bindService(serviceIntent, connection, Context.BIND_AUTO_CREATE);
  }

  @Override
  protected void onResume() {
    super.onResume();
    registerReceiver(receiver, new IntentFilter("com.calatrava.ajax.start"));
    registerReceiver(receiver, new IntentFilter("com.calatrava.ajax.finish"));
    registerReceiver(receiver, new IntentFilter("com.calatrava.alert"));
  }

  @Override
  protected void onPause() {
    super.onPause();
    unregisterReceiver(receiver);
  }

  @Override
  public void onDestroy() {
    super.onDestroy();
    unbindService(connection);
  }

  public void triggerEvent(String event, String... extraArgs) {
    PageRegistry.sharedRegistry().triggerEvent(getPageName(), event, extraArgs);
  }
  
  public void invokeWidgetCallback(String...args) {
    rhino.callJsFunction("calatrava.inbound.invokeCallback", args);
  }

  protected abstract void onRhinoConnected(RhinoService rhino);

  protected abstract String getPageName();

  public abstract String getFieldValue(String field);

  public abstract void render(final String json);
}
