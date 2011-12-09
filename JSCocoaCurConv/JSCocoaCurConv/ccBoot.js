var tw = tw || {};

tw.pages = {
  converter: tw.bridge.pages.pageNamed("CurrencyConverter")
};

tw.controllers = {};

tw.controllers.converter = (function() {
  function usd2Euro(usdValue) {
		return usdValue / 2;
  }

  tw.pages.converter.bind('convertCurrency', function() {
    var usdValue = tw.pages.converter.get('startCurrencyField');
    tw.pages.converter.render({value: usd2Euro(usdValue)});
  });
}());