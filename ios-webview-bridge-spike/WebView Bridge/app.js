(function() {
  function createController(screen) {
    function convert(input) {
      return input / 2;
    }

    function convertTouchedHandler(input) {
      var output = convert(+input);
      window.alert( "converted output: "+output );
    };

    screen.onConvertTouched( convertTouchedHandler );

    return {};
  };

  function createScreen(bridge){
    function onConvertTouched(handler) {
      bridge.bind( 'conversionScreen.convertButtonTouched', function(params) {
        handler(params.inputCurrency);
      });
    }

    return {
      onConvertTouched: onConvertTouched
    };
  };

  var screen = createScreen(window.ramp);
  var controller = createController(screen);

}());

