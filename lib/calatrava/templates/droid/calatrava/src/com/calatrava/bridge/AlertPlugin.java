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
  
  public void setContext(PluginRegistry registry, Context ctxt)
  {
    this.registry = registry;
    this.ctxt = ctxt;
    registry.installCommand("alert", new PluginCommand() {
        @Override
        public void execute(Intent action, RegisteredActivity frontmost)
        {
          AlertDialog.Builder builder = new AlertDialog.Builder(frontmost);
          builder.setMessage(action.getExtras().getString("message"))
            .setCancelable(false)
            .setPositiveButton("OK", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialogInterface, int i) {
                  dialogInterface.dismiss();
                }
              });
          AlertDialog dialog = builder.create();
          dialog.show();
        }
      });
  }
  
  public void call(String method, Map<String, Object> args)
  {
    ctxt.sendBroadcast(registry.pluginCommand("alert").putExtra("message", (String)args.get("message")));
  }
}