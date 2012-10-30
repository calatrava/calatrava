package com.calatrava.bridge;

import android.content.Context;
import android.content.ContextWrapper;
import android.content.pm.PackageManager.NameNotFoundException;

import dalvik.system.DexFile;
import dalvik.system.PathClassLoader;
import dalvik.system.DexClassLoader;

import java.lang.annotation.Annotation;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Iterator;
import java.io.IOException;
import java.net.URISyntaxException;

public class AnnotationRegistrar
{
  private String packageName;
  private HashSet<String> searchScope = new HashSet<String>();
  private Context context;

  public AnnotationRegistrar(String packageName, Context context, String... searchScope)
  {
    this.packageName = packageName;
    this.context = context;
    
    this.searchScope.add(this.packageName);
    for (String pkg : searchScope)
    {
      this.searchScope.add(pkg);
    }
  }

  public void register(Registration receiver)
    throws IOException, URISyntaxException, ClassNotFoundException, NameNotFoundException
  {
    String apkName = context.getPackageManager().getApplicationInfo(packageName, 0).sourceDir;
    DexFile dexFile = new DexFile(apkName);
    PathClassLoader pathBasedLoader = new PathClassLoader(apkName, Thread.currentThread().getContextClassLoader());
    DexClassLoader classLoader = new DexClassLoader(apkName, new ContextWrapper(context).getCacheDir().getAbsolutePath(), null, pathBasedLoader);

    Enumeration<String> entries = dexFile.entries();
    while (entries.hasMoreElements())
    {
      String entry = entries.nextElement();
      boolean inScope = false;
      Iterator<String> it = searchScope.iterator();
      while (!inScope && it.hasNext())
      {
        if (entry.startsWith(it.next()))
        {
          inScope = true;
        }
      }
      if (inScope)
      {
        Class<?> entryClass = classLoader.loadClass(entry);
        if (entryClass != null)
        {
          Annotation[] annotations = entryClass.getAnnotations();
          for (Annotation annotation : annotations)
          {
            receiver.install(annotation, entryClass);
          }
        }
      }               
    }
  }
}