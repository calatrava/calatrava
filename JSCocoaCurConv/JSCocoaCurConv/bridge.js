var tw = tw || {};
tw.bridge = tw.bridge || {};

function generateRandomString(){
  var str = '';
  var i;
  for (i = 0; i < 32; ++i) {
    var r = Math.floor(Math.random() * 16);
    str = str + r.toString(16);
  }
  return str.toUpperCase();
}

function bridgeDispatch(proxyId, event) {
  tw.bridge.pages.pageByProxyId(proxyId).dispatch(event);
}

tw.bridge.pageObject = function(pageName) {
  var proxyId = generateRandomString(),
    proxy = TWBridgePageRegistry.sharedRegistry.pageWithName(pageName),
    handlerRegistry = {};

  function bind(event, handler) {
    handlerRegistry[event] = handler;
    proxy.attachHandler_forEvent(proxyId, event);
  }

  function dispatch(event) {
    if (!handlerRegistry[event]) {
      event();
    } else {
      handlerRegistry[event]();
    }
  }

  function get(field) {
    return proxy.valueForField(field);
  }

  function render(viewObject) {
    proxy.render(viewObject);
  }

  return {
    proxyId: proxyId,
    bind: bind,
    dispatch: dispatch,
    get: get,
    render: render
  };
};

tw.bridge.pages = (function() {
  var pagesByName = {},
    pagesByProxyId = {};

  function pageNamed(pageName) {
    if (!pagesByName[pageName]) {
      var page = tw.bridge.pageObject(pageName);
      pagesByName[pageName] = page;
      pagesByProxyId[page.proxyId] = page;
    }
    return pagesByName[pageName];
  }

  function pageByProxyId(proxyId) {
    return pagesByProxyId[proxyId];
  }

  return {
    pageNamed: pageNamed,
    pageByProxyId: pageByProxyId
  };
}());
