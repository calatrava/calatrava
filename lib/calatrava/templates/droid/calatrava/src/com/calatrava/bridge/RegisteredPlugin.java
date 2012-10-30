package com.calatrava.bridge;

import android.content.Context;
import java.util.Map;

interface RegisteredPlugin
{
  void setContext(PluginRegistry registry, Context ctxt);
  void call(String method, Map<String, Object> args);
}