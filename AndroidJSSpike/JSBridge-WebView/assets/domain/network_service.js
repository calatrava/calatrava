network = function(){
    var service = window.networkService;
    var success = {};

    function ajax(url, successHandler) {
      network.success.successHandler1 = function( result ) {
        window.response.log("inside callback handler");
        successHandler( result );
      };
      window.response.log("inside networkservice");
      service.ajax(url, "network.success.successHandler1" );
    }

	return {
      ajax: ajax,
      success: success
	};
}();