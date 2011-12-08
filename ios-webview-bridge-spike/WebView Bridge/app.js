(function() {
  function createController(screen) {
    function convert(input) {
      return input / 2;
    }

    function convertTouchedHandler(input) {
      var output = convert(+input);
      screen.updateConversionResult( output );
    };

    screen.onConvertTouched( convertTouchedHandler );

    return {};
  };

  function createScreen(bridge){
    function updateConversionResult(result) {
      bridge.invoke( 'conversionScreen.updateConversionResult', { currencyResult: ""+result } );
    }

    function onConvertTouched(handler) {
      bridge.bind( 'conversionScreen.convertButtonTouched', function(params) {
        handler(params.inputCurrency);
      });
    }

    return {
      updateConversionResult: updateConversionResult,
      onConvertTouched: onConvertTouched
    };
  };

  var screen = createScreen(window.ramp);
  var controller = createController(screen);

}());

