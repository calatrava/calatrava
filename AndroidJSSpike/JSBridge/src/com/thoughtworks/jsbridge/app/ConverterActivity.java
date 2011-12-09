package com.thoughtworks.jsbridge.app;

import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import com.thoughtworks.jsbridge.R;
import com.thoughtworks.jsbridge.ScriptActivity;
import org.mozilla.javascript.ScriptableObject;

public class ConverterActivity extends ScriptActivity {
    private static final String TAG = "cc-android";
    private EditText valueInUsd;
    private TextView convertedValue;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        valueInUsd = (EditText) findViewById(R.id.valueInUSD);
        convertedValue = (TextView) findViewById(R.id.textOnScreen);

        findViewById(R.id.convert).setOnClickListener(new View.OnClickListener() {
            public void onClick(View view) {
                getScriptService().eval("currencyHandler(" + valueInUsd.getText() + ");");
            }
        });
    }


    @Override
    protected void initScripts() {
        super.initScripts();
        getScriptService().load(readAsset("domain/currency_converter.js"), "converter.js");
        getScriptService().load(readAsset("controller/converter_controller.js"), "converter_controller.js");
        ScriptableObject.putProperty(getScriptService().getScope(), "tw_page_currency_controller", this);
    }


    public void renderScreen(String response) {
        convertedValue.setText(response);
    }
}
