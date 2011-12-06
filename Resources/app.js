// this sets the background color of the master UIView (when there are no windows/tab groups on it)
Titanium.UI.setBackgroundColor('#fff');

//include our domain scripts.
Ti.include('public/javascripts/domain/currency_converter.js');


//
// create base UI tab and root window
//
var win = Titanium.UI.createWindow({  
    title:'Currency Converter',
    backgroundColor:'#fff',
    layout: 'vertical'
});

 
win.add(Ti.UI.createLabel({
	text : 'Currency Converter',
	color : 'black',
	width : 'auto',
	height : 'auto'
}));


var inputCurrency = Ti.UI.createTextField({
	hintText : 'Enter money value in USD',
	height : '50'
});
win.add(inputCurrency);

button = Ti.UI.createButton({
	title: "Convert",
	color: "#794289",
	height : '50',
	width: '200'
	
});

win.add(button);


var result = Ti.UI.createLabel({
	text : 'Value',
	color : 'black',
	width : 'auto',
	height : 'auto'
});


button.addEventListener('click',function(e)
{
   var convertedCurrency = converter.usdToEuro( +inputCurrency.value );
   result.text = convertedCurrency;
   Titanium.API.info("You clicked the button");
});


win.add(result);

win.open();
