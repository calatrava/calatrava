package com.calatrava.bridge;

import android.app.Application;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.util.Log;

import java.io.IOException;
import java.io.BufferedReader;
import java.io.InputStreamReader;

public class Launcher {

  private static RhinoService rhino;
  private static Context appContext;
  private static Application application;

  static ServiceConnection connection = new ServiceConnection() {
    public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
      rhino = ((RhinoService.LocalBinder) iBinder).getService();
      PageRegistry.setSharedRegistry(new PageRegistry(appContext, application, rhino));
      AjaxRequestManager.setSharedManager(new AjaxRequestManager(appContext, rhino));
      initBridge();
    }

    public void onServiceDisconnected(ComponentName componentName) {

    }
  };

  public static void launchKernel(Context appContext, Application application) {
    Launcher.appContext = appContext;
    Launcher.application = application;

    Intent serviceIntent = new Intent(appContext, RhinoService.class);
    appContext.bindService(serviceIntent, connection, Context.BIND_AUTO_CREATE);
  }

  public static void launchFlow(String flow)
  {
    rhino.callJsFunction(flow);
  }

  private static void initBridge() {
    AssetRepository assets = new AssetRepository(appContext);

    try {
      Log.d("AuthenticatedCustomer Activity", "About to prep the rhino");
      rhino.initRhino();

      Log.d("AuthenticatedCustomer Activity", "About to load and start kernel");
      // Load all the application JS
      KernelBridge bridge = new KernelBridge(assets, rhino);
      BufferedReader loadFileReader = new BufferedReader(new InputStreamReader(appContext.getAssets().open("hybrid/load_file.text")));
      String line = null;
      while ((line = loadFileReader.readLine()) != null)
      {
        bridge.loadLibrary(line);
      }
      bridge.loadLibrary("hybrid/scripts/app.constants.js");

    } catch (IOException e) {
      Log.d("AuthenticatedCustomer Activity", "LauncherActivity failed to start: " + e);
    }
  }
}
