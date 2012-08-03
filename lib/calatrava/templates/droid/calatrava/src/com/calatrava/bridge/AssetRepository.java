package com.calatrava.bridge;

import android.content.Context;

import java.io.*;

public class AssetRepository {
  private Context appContext;

  public AssetRepository(Context appContext) {
    this.appContext = appContext;
  }

  public Reader assetReader(String path) throws IOException {
    return new BufferedReader(new InputStreamReader(appContext.getAssets().open(path)), 8192);
  }
}
