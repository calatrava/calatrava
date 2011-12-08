window.ramp = (function() {
  var callbacks = {};

  var _batSignal;
  function batSignal(){
    if( !_batSignal ){
      _batSignal = document.createElement("iframe");
      _batSignal.setAttribute("style", "display:none;");
      _batSignal.setAttribute("height","0px");
      _batSignal.setAttribute("width","0px");
      _batSignal.setAttribute("frameborder","0");
      document.documentElement.appendChild(_batSignal);
    }
    return _batSignal;
  }

  function bind(name,fn){
    callbacks[name] = fn;
  }

  function trigger(name, params) {
    callbacks[name](params);
  }

  function invoke(name, params) {
    batSignal().src = "http://bat.thoughtworks.com/" + name + "?" + encodeURIComponent( JSON.stringify( params ) );
  }

  return {
    invoke: invoke,
    trigger: trigger,
    bind: bind
  };
}());
