network = function(){
    var service = tw_networkService;
    var success = {};

    function ajax(url, successHandler) {
      network.success.successHandler1 = function( result ) {
        out.println("inside callback handler");
        successHandler( result );
      };
      out.println("inside networkservice");
      service.ajax(url, "network.success.successHandler1" );
    }

	return {
      ajax: ajax,
      success: success
	};
}();