package com.calatrava.bridge;

import java.io.IOException;

public class KernelBridge {

  private AssetRepository assetRepository;
  private RhinoService rhinoService;

  public KernelBridge(AssetRepository assetRepository, RhinoService rhinoService) throws IOException {
    this.assetRepository = assetRepository;
    this.rhinoService = rhinoService;

    //load js libraries
    loadLibrary("calatrava/scripts/underscore.js");

    //load bridge
    loadLibrary("calatrava/scripts/env.js");
    loadLibrary("calatrava/scripts/bridge.js");
  }

  public void loadLibrary(String libraryName) throws IOException {
    rhinoService.load(assetRepository.assetReader(libraryName), libraryName);
  }
}
