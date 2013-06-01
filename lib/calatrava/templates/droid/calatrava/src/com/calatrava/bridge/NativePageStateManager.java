package com.calatrava.bridge;

import android.app.Activity;

public class NativePageStateManager implements PageStateManager {

  private RegisteredActivity activity;

  public NativePageStateManager(Activity activity) {
    this.activity = (RegisteredActivity) activity;
  }

  @Override
  public void onCreateProcessing() {
    activity.registerPage();
  }

  @Override
  public void onResumeProcessing() {
    activity.pageOnScreen();
  }

  @Override
  public void onPauseProcessing() {
    activity.pageOffScreen();
  }

  @Override
  public void onDestroyProcessing() {
    activity.unRegisterPage();
  }
}
