package com.calatrava.bridge;

import java.io.IOException;

public class KernelBridge {

  private AssetRepository assetRepository;
  private RhinoService rhinoService;

  public KernelBridge(AssetRepository assetRepository, RhinoService rhinoService) throws IOException {
    this.assetRepository = assetRepository;
    this.rhinoService = rhinoService;

    //load js libraries
    loadLibrary("hybrid/scripts/underscore.js");
    loadLibrary("hybrid/scripts/date.js");

    //load bridge
    loadLibrary("hybrid/scripts/env.js");
    loadLibrary("hybrid/scripts/bridge.js");
  }

  public void loadLibrary(String libraryName) throws IOException {
    rhinoService.load(assetRepository.assetReader(libraryName), libraryName);
  }
}
