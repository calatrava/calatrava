package com.thoughtworks.jsbridge.app;

import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import com.thoughtworks.jsbridge.R;
import com.thoughtworks.jsbridge.ScriptActivity;

public class ConverterActivity extends ScriptActivity {
    private static final String TAG = "cc-android";
    private EditText valueInUsd;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        valueInUsd = (EditText) findViewById(R.id.valueInUSD);
        final TextView convertedValue = (TextView) findViewById(R.id.textOnScreen);

        findViewById(R.id.convert).setOnClickListener(new View.OnClickListener() {
            public void onClick(View view) {
                String result = getScriptService().eval("converter.usdToEuro(" + valueInUsd.getText() + ");");
                convertedValue.setText(result);
                android.util.Log.d(TAG, result);
            }
        });
    }


    @Override
    protected void initScripts() {
        super.initScripts();
        getScriptService().load(readAsset("domain/currency_converter.js"), "converter.js");
    }


}
