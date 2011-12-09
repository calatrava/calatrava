function currencyHandler(usdValue){
    out.println("currency handler - instead calling - network service");
    //http://10.0.2.2:1337
    network.ajax("http://www.multimolti.com/apps/currencyapi/index.php?curr=EUR", function(response) {
        converter.setExchangeRate(+response);
        tw_page_currency_controller.renderScreen(converter.usdToEuro(usdValue));
        });
};