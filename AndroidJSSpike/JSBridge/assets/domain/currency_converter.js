converter = function(){
	var exchangeRateForEuro = 0.5;
	var usdToEuro = function(value){
		return value * exchangeRateForEuro;
	};

	function setExchangeRate(exchangeRate){
	   exchangeRateForEuro = exchangeRate;
	}

	return {
		usdToEuro: usdToEuro,
		setExchangeRate: setExchangeRate
	};
}();
