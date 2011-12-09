package com.thoughtworks.jsbridge;

import android.app.Activity;
import android.content.Intent;
import android.content.res.AssetManager;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import java.io.*;

public class ConverterActivity extends Activity {

    private AssetManager assetManager;
    private EditText valueInUsd;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        Intent serviceIntent = new Intent(ConverterActivity.this, RhinoService.class);
        startService(serviceIntent);

        assetManager = getAssets();


        Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
                    public void run() {
//                      RhinoService.getInstance().eval("var a=1+3");
                        RhinoService.getInstance().load(readAsset("domain/currency_converter.js"), "converter.js");

                    }
                }, 3000);


        valueInUsd = (EditText) findViewById(R.id.valueInUSD);
        final TextView convertedValue = (TextView) findViewById(R.id.textOnScreen);

        findViewById(R.id.convert).setOnClickListener(new View.OnClickListener() {
            public void onClick(View view) {
                String result = RhinoService.getInstance().eval("converter.usdToEuro(" + valueInUsd.getText() + ");");

                convertedValue.setText(result);
                android.util.Log.d("cc-android", result);
            }
        });


    }

    private Reader readAsset(String filePath) {

        InputStream stream = null;
        try {
            stream = assetManager.open(filePath);

        } catch (IOException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }

        return new BufferedReader(new InputStreamReader(stream));

    }


}
