package com.thoughtworks.jsbridge;

import android.app.Application;
import android.content.Intent;

public class AndroidApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        startService(new Intent(this, RhinoService.class));
    }
}
