// this sets the background color of the master UIView (when there are no windows/tab groups on it)
Titanium.UI.setBackgroundColor('#fff');



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


win.add(Ti.UI.createTextField({
	hintText : 'Enter money value in USD',
	height : '50'
}));

win.add(Ti.UI.createButton({
	title: "Convert",
	backgroundColor: "#794289"
}));


win.open();
