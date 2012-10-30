package com.calatrava.bridge;

import android.content.Intent;

public interface PluginCommand
{
  void execute(Intent action, RegisteredActivity frontmost);
}