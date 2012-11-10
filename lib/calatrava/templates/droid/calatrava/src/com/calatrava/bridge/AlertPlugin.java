package com.calatrava.bridge;

import com.calatrava.CalatravaPlugin;

import android.content.Context;
import android.content.Intent;
import android.content.DialogInterface;
import android.app.AlertDialog;

import java.util.Map;

@CalatravaPlugin(name = "alert")
public class AlertPlugin implements RegisteredPlugin
{
  private PluginRegistry registry;
  private Context ctxt;
  private String currentOkCallbackHandle;
  
  public void setContext(PluginRegistry registry, Context ctxt)
  {
    this.registry = registry;
    this.ctxt = ctxt;
    registry.installCommand("alert", new PluginCommand() {
        @Override
        public void execute(Intent action, RegisteredActivity frontmost)
        {
          AlertDialog.Builder builder = new AlertDialog.Builder(frontmost);
          final boolean isConfirmDialog = action.getExtras().getString("method").equals("displayConfirm");
          builder.setMessage(action.getExtras().getString("message"))
            .setCancelable(isConfirmDialog)
            .setPositiveButton("OK", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialogInterface, int i) {
                  dialogInterface.dismiss();
                  if (isConfirmDialog) {
                    AlertPlugin.this.registry.invokeCallback(currentOkCallbackHandle, 1);
                  }
                }
              });
          if (isConfirmDialog) {
            builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialogInterface, int i) {
                  dialogInterface.dismiss();
                }
              });
          }
          AlertDialog dialog = builder.create();
          dialog.show();
        }
      });
  }
  
  public void call(String method, Map<String, Object> args)
  {
    currentOkCallbackHandle = (String)args.get("okHandler");
    ctxt.sendBroadcast(registry.pluginCommand("alert")
                       .putExtra("method", method)
                       .putExtra("message", (String)args.get("message")));
  }
}
