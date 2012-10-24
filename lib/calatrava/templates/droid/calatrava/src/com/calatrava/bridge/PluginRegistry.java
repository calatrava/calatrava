package com.calatrava.bridge;

import android.content.Context;
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
  private Map<String, RegisteredPlugin> registeredPlugins = new HashMap<String, RegisteredPlugin>();
  private ObjectMapper jsonMapper = new ObjectMapper();

  public static PluginRegistry sharedRegistry() {
    return sharedRegistry;
  }

  public static void setSharedRegistry(PluginRegistry shared)
  {
    sharedRegistry = shared;
  }

  public PluginRegistry(String packageName, Context appContext)
    throws IOException, URISyntaxException, ClassNotFoundException, NameNotFoundException
  {
    this.appContext = appContext;

    // Find all the plugins to register in the app
    addPlugins(packageName, appContext);
  }

  private void addPlugins(String packageName, Context context)
    throws IOException, URISyntaxException, ClassNotFoundException, NameNotFoundException
  {
    Log.d(TAG, "Searching for Calatrava plugins in '" + packageName + "'");
    AnnotationRegistrar registrar = new AnnotationRegistrar(packageName, context);
    registrar.register(new Registration() {
        public void install(Annotation annotation, Class<?> toRegister)
        {
          if (annotation instanceof CalatravaPlugin)
          {
            String pluginName = ((CalatravaPlugin)annotation).name();
            Log.d(TAG, "Registering Calatrava plugin: " + pluginName);
            try
            {
              registeredPlugins.put(pluginName, (RegisteredPlugin)toRegister.newInstance());
            }
            catch (Exception e)
            {
              Log.e(TAG, "Unable to instantiate plugin: " + pluginName, e);
            }
          }
        }
    });
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
}