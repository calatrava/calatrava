$(document).ready(function() {
  $('#cc-form').submit(function(){
    var usdVal = $('#usd').val(),
        euroVal = converter.usdToEuro(usdVal);
    $('.result').text( euroVal.toFixed(2) );
	return false;
  });
});