package com.calatrava.bridge;

public interface PageStateManager {

  public void onCreateProcessing();

  public void onResumeProcessing();

  public void onPauseProcessing();

  public void onDestroyProcessing();

}
