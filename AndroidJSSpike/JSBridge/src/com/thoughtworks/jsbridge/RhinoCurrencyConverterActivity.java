package com.thoughtworks.jsbridge;

import android.app.Activity;
import android.os.Bundle;
import org.mozilla.javascript.Context;
import org.mozilla.javascript.ScriptableObject;

public class RhinoCurrencyConverterActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        try {
            Context cx = Context.enter();
            final ScriptableObject scope = cx.initStandardObjects();
            final Object result = cx.evaluateString(scope, "javascript:function() {return 'hi'}", "<cmd>", 1, null);

            System.out.println(cx.toString(result));

        } finally {
            Context.exit();
        }
    }
}
