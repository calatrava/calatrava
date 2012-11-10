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
  private static String TAG = Launcher.class.getSimpleName();

  private static String appName;
  private static RhinoService rhino;
  private static Context appContext;
  private static Application application;
  private static Runnable startUp;

  static ServiceConnection connection = new ServiceConnection() {
    public void onServiceConnected(ComponentName componentName, IBinder iBinder)
    {
      try
      {
        rhino = ((RhinoService.LocalBinder) iBinder).getService();
        PageRegistry.setSharedRegistry(new PageRegistry(appName, appContext, application, rhino));
        PluginRegistry.setSharedRegistry(new PluginRegistry(appName, appContext, rhino));
        AjaxRequestManager.setSharedManager(new AjaxRequestManager(appContext, rhino));
        initBridge();
        startUp.run();
      }
      catch (Exception e)
      {
        Log.e(TAG, "Unable to start.", e);
      }
    }

    public void onServiceDisconnected(ComponentName componentName) {

    }
  };

  public static void launchKernel(String appName,
                                  Context appContext,
                                  Application application,
                                  Runnable startUp) {
    Launcher.appName = appName;
    Launcher.appContext = appContext;
    Launcher.application = application;
    Launcher.startUp = startUp;

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
      Log.d(TAG, "About to prep the rhino");
      rhino.initRhino();

      Log.d(TAG, "About to load and start kernel");
      // Load all the application JS
      KernelBridge bridge = new KernelBridge(assets, rhino);
      BufferedReader loadFileReader = new BufferedReader(new InputStreamReader(appContext.getAssets().open("calatrava/load_file.txt")), 8192);
      String line = null;
      while ((line = loadFileReader.readLine()) != null)
      {
        bridge.loadLibrary(line);
      }

    } catch (IOException e) {
      Log.d(TAG, "LauncherActivity failed to start: " + e);
    }
  }
}
