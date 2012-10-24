package com.calatrava.bridge;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import android.content.pm.PackageManager.NameNotFoundException;

import org.mozilla.javascript.ScriptableObject;

import com.calatrava.CalatravaPage;

import java.util.*;

import java.io.IOException;
import java.net.URISyntaxException;

import java.lang.annotation.Annotation;

public class PageRegistry {
  public static String TAG = PageRegistry.class.getSimpleName();
  private static PageRegistry sharedRegistry;

  private Context appContext;
  private RhinoService rhino;
  private Map<String, Class<?>> pageFactories = new HashMap<String, Class<?>>();
  private Map<String, RegisteredPage> registeredPages = new HashMap<String, RegisteredPage>();
  private Map<String, String> proxyByPage = new HashMap<String, String>();

  public static PageRegistry sharedRegistry() {
    return sharedRegistry;
  }

  public static void setSharedRegistry(PageRegistry shared) {
    Log.d(TAG, "Set shared page registry");
    sharedRegistry = shared;
  }

  public PageRegistry(String appName, Context appContext, Application app, RhinoService rhino)
    throws IOException, URISyntaxException, ClassNotFoundException, NameNotFoundException
  {
    this.appContext = appContext;
    this.rhino = rhino;

    // Find all the logical page classes in the app
    Log.d(TAG, "Searching for Calatrava pages in '" + appName + "'");
    addPages(appName, appContext);
  }

  private void addPages(String packageName, Context context)
    throws IOException, URISyntaxException, ClassNotFoundException, NameNotFoundException
  {
    AnnotationRegistrar registrar = new AnnotationRegistrar(packageName, context);
    registrar.register(new Registration() {
        public void install(Annotation annotation, Class<?> toRegister)
        {
          if (annotation instanceof CalatravaPage)
          {
            String pageName = ((CalatravaPage)annotation).name();
            Log.d(TAG, "Registering Calatrava page: " + pageName);
            pageFactories.put(pageName, toRegister);
          }
        }
    });
  }

  public void registerProxyForPage(String pageName, String proxyId) {
    Log.d(TAG, "Attaching proxy '" + proxyId + "' to name '" + pageName + "'");
    proxyByPage.put(pageName, proxyId);
  }
  
  public void changePage(String target) {
    Log.d(TAG, "changePage('" + target + "')");
    Class activityClass = pageFactories.get(target);
    Log.d(TAG, "Activity to be started: " + activityClass.getSimpleName());
    appContext.startActivity(new Intent(appContext, activityClass));
  }

  public void triggerEvent(String pageName, String event, String... extraArgs) {
    String proxy = proxyByPage.get(pageName);
    Log.d(TAG, "Dispatching to proxy '" + proxy + "'");
    rhino.triggerEvent(proxy, event, extraArgs);
  }

  public void displayWidget(String name, String options) {
    appContext.sendBroadcast(new Intent("com.calatrava.widget").putExtra("name", name).putExtra("options", options));
  }

  public void displayDialog(String dialogName) {
    appContext.sendBroadcast(new Intent("com.calatrava.dialog").putExtra("name", dialogName));
  }

  public void alert(String message) {
    Log.d(TAG, "Broadcasting alert message: '" + message + "'");
    appContext.sendBroadcast(new Intent("com.calatrava.alert").putExtra("message", message));
  }

  public void openUrl(String url) {
    Intent browser = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
    appContext.startActivity(browser);
  }

  public void track(String pageName, String channel, String eventName, Object variables, Object properties) {
  }

  public void startTimer(int timeout, final String timerId) {
    final Timer timer = new Timer();
    timer.schedule(new TimerTask() {
      @Override
      public void run() {
        timer.cancel();
        timer.purge();
        rhino.callJsFunction("calatrava.inbound.fireTimer", new String[] {timerId});
      }
    }, 1000 * timeout);
  }

  private HashMap<String, String> jsObjectToMap(ScriptableObject obj) {
    HashMap<String, String> map = new HashMap<String, String>();
    for (Object k : obj.getIds()) {
      if (k instanceof String) {
        map.put((String) k, ScriptableObject.getProperty(obj, (String) k).toString());
      }
    }
    return map;
  }

  private void ensureRegisteredPage(String name, RegisteredActivity page) {
    if (registeredPages.get(name) == null) {
      registeredPages.put(name, new RegisteredPage(page));
    } else if (page != null) {
      registeredPages.get(name).setPage(page);
    }
  }

  public void registerPage(String name, RegisteredActivity page) {
    ensureRegisteredPage(name, page);
  }

  public void unregisterPage(String pageName) {
    registeredPages.remove(pageName);
  }

  public String getValueForField(String page, String field) {
    Log.d(TAG, "Requesting field '" + field + "' from page '" + page + "'");
    ensureRegisteredPage(page, null);
    return registeredPages.get(page).getFieldValue(field);
  }

  public void renderPage(String page, String renderJson) {
    Log.d(TAG, "renderPage: '" + page + "' Response object: " + renderJson);

    ensureRegisteredPage(page, null);
    registeredPages.get(page).render(renderJson);
  }

  public void pageOffscreen(String page) {
    ensureRegisteredPage(page, null);
    registeredPages.get(page).pageOffscreen();
  }

  public void pageOnscreen(String page) {
    ensureRegisteredPage(page, null);
    registeredPages.get(page).pageOnscreen();
  }

  private class RegisteredPage {
    private RegisteredActivity activity;
    List<String> pendingRenders = new ArrayList<String>();
    boolean onScreen = false;

    private RegisteredPage(RegisteredActivity activity) {
      this.activity = activity;
    }

    public RegisteredActivity getPage() {
      return activity;
    }

    public void setPage(RegisteredActivity page) {
      this.activity = page;
    }

    public void render(String renderJson) {
      if (activity != null && onScreen) {
        activity.render(renderJson);
      } else {
        pendingRenders.add(renderJson);
      }
    }

    public String getFieldValue(String field) {
      if (activity != null) {
        return activity.getFieldValue(field);
      } else {
        return "";
      }
    }

    public void pageOffscreen() {
      onScreen = false;
    }

    public void pageOnscreen() {
      onScreen = true;

      for (String pendingRender : pendingRenders) {
        Log.d(TAG, "Pending activity for: " + pendingRender);

        activity.render(pendingRender);
      }
      pendingRenders.clear();
    }
  }
}
