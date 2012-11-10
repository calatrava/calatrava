package com.calatrava.bridge;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.content.pm.PackageManager.NameNotFoundException;

import org.codehaus.jackson.map.ObjectMapper;

import java.lang.annotation.Annotation;
import java.util.Map;
import java.util.HashMap;
import java.io.IOException;
import java.net.URISyntaxException;

import com.calatrava.CalatravaPlugin;

public class PluginRegistry {
  public static String TAG = PluginRegistry.class.getSimpleName();
  private static PluginRegistry sharedRegistry;

  private Context appContext;
  private RhinoService rhino;
  private Map<String, RegisteredPlugin> registeredPlugins = new HashMap<String, RegisteredPlugin>();
  private Map<String, PluginCommand> installedCmds = new HashMap<String, PluginCommand>();
  private ObjectMapper jsonMapper = new ObjectMapper();

  public static PluginRegistry sharedRegistry() {
    return sharedRegistry;
  }

  public static void setSharedRegistry(PluginRegistry shared)
  {
    sharedRegistry = shared;
  }

  public PluginRegistry(String packageName, Context appContext, RhinoService rhino)
    throws IOException, URISyntaxException, ClassNotFoundException, NameNotFoundException
  {
    this.appContext = appContext;
    this.rhino = rhino;

    // Find all the plugins to register in the app
    addPlugins(packageName, appContext);
  }

  private void addPlugins(String packageName, Context context)
    throws IOException, URISyntaxException, ClassNotFoundException, NameNotFoundException
  {
    Log.d(TAG, "Searching for Calatrava plugins in '" + packageName + "'");
    AnnotationRegistrar registrar = new AnnotationRegistrar(packageName, context, "com.calatrava.bridge");
    registrar.register(new Registration() {
        public void install(Annotation annotation, Class<?> toRegister)
        {
          if (annotation instanceof CalatravaPlugin)
          {
            String pluginName = ((CalatravaPlugin)annotation).name();
            Log.d(TAG, "Registering Calatrava plugin: " + pluginName);
            try
            {
              RegisteredPlugin plugin = (RegisteredPlugin)toRegister.newInstance();
              plugin.setContext(PluginRegistry.this, appContext);
              registeredPlugins.put(pluginName, plugin);
            }
            catch (Exception e)
            {
              Log.e(TAG, "Unable to instantiate plugin: " + pluginName, e);
            }
          }
        }
    });
  }

  public void installCommand(String cmd, PluginCommand handler)
  {
    installedCmds.put(cmd, handler);
  }

  public void runCommand(Intent intent, RegisteredActivity frontmost)
  {
    installedCmds.get(intent.getExtras().getString("command")).execute(intent, frontmost);
  }

  public Intent pluginCommand(String cmd)
  {
    return new Intent("com.calatrava.command").putExtra("command", cmd);
  }

  public void call(String plugin, String method, String argsJson)
  {
    try
    {
      if (registeredPlugins.get(plugin) != null)
      {
        registeredPlugins.get(plugin).call(method, jsonMapper.readValue(argsJson, Map.class));
      }
      else
      {
        Log.e(TAG, "No plugin registered: " + plugin);
      }
    }
    catch (IOException e)
    {
      Log.e(TAG, "Unable to deserialize JSON for plugin args.", e);
    }
  }

  public void invokeCallback(String callbackHandle, Object data)
  {
    rhino.callJsFunction("calatrava.inbound.invokePluginCallback", new String[] {callbackHandle, data.toString()});
  }
}
