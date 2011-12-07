window.ramp = (function() {
  var callbacks = {};

  function bind(name,fn){
    callbacks[name] = fn;
  }

  function trigger(name, params) {
    callbacks[name](params);
  }

  return {
    trigger: trigger,
    bind: bind
  };
}());
