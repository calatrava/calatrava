package com.calatrava.bridge;

import android.app.Application;
import android.content.Context;
import android.content.pm.PackageManager;
import android.util.Log;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URISyntaxException;

public class CalatravaApplication extends Application
{
  private static String TAG = CalatravaApplication.class.getSimpleName();
  private RhinoService rhino;

  public void bootCalatrava(String appName)
  {
    rhino = new RhinoService(this);
    try
    {
      PageRegistry.setSharedRegistry(new PageRegistry(appName, this, rhino));
      PluginRegistry.setSharedRegistry(new PluginRegistry(appName, this, rhino));
      AjaxRequestManager.setSharedManager(new AjaxRequestManager(this, rhino));

      initBridge();
    } catch (Exception e)
    {
      Log.wtf(TAG, "Unable to boot Calatrava.", e);
    }
  }

  public void provideActivityContext(Context activityContext)
  {
    PageRegistry.sharedRegistry().updateContext(activityContext);
    PluginRegistry.sharedRegistry().updateContext(activityContext);
  }

  public void launchFlow(String flow)
  {
    rhino.callJsFunction(flow);
  }

  private void initBridge()
  {
    AssetRepository assets = new AssetRepository(this);

    BufferedReader loadFileReader = null;
    try
    {
      rhino.initRhino(this);
      // Load all the application JS
      InputStream inputStream = this.getAssets().open("calatrava/load_file.txt");
      loadFileReader = new BufferedReader(new InputStreamReader(inputStream), 8192);
      KernelBridge bridge = new KernelBridge(assets, rhino);
      String line;
      while ((line = loadFileReader.readLine()) != null)
      {
        bridge.loadLibrary(line);
      }

    } catch (IOException e) {
      Log.d(TAG, "LauncherActivity failed to start", e);
    }
    finally
    {
      if (loadFileReader != null)
      {
        try
        {
          loadFileReader.close();
        }
        catch(IOException e)
        {
          Log.e(TAG, "Unable to close load_file.txt", e);
        }
      }
    }
  }

  public RhinoService getRhino()
  {
    return rhino;
  }
}
