var tw = tw || {};
tw.bridge = tw.bridge || {};

// json.js does stupid things to the Object prototype
Object.prototype.toJSONString = "";
Object.prototype.parseJSON = "";

function generateRandomString(){
  var str = '';
  var i;
  for (i = 0; i < 32; ++i) {
    var r = Math.floor(Math.random() * 16);
    str = str + r.toString(16);
  }
  return str.toUpperCase();
}

function bridgeDispatch(proxyId) {
  var extraArgs = _.map(_.toArray(arguments).slice(1), function(obj) { return obj.valueOf(); });
  var proxyPage = tw.bridge.pages.pageByProxyId(proxyId);
  proxyPage.dispatch.apply(proxyPage, extraArgs);
}

function bridgeSuccessfulResponse(requestId, response) {
  tw.bridge.requests.successfulResponse(requestId, response);
}

function bridgeFailureResponse(requestId, errorCode, response) {
  tw.bridge.requests.failureResponse(requestId, errorCode, response);
}

function bridgeFireTimer(timerId) {
  tw.bridge.timers.fireTimer(timerId);
}

function bridgeInvokeCallback(widgetName) {
  var extraArgs = _.map(_.toArray(arguments).slice(1), function(obj) { return obj.valueOf(); });
  tw.bridge.widgets.callback(widgetName).apply(this, extraArgs);
}

tw.bridge.changePage = function(target) {
  TWBridgePageRegistry.sharedRegistry.changePage(target);
  return target;
};

tw.bridge.widgets = (function() {
  var callbacks;
  callbacks = {};
  return {
    display: function(name, options, callback) {
      TWBridgePageRegistry.sharedRegistry.displayWidget_withOptions(name, options);
      return callbacks[name] = callback;
    },
    callback: function(name) {
      return callbacks[name];
    }
  };
})();

tw.bridge.alert = function(message) {
  TWBridgePageRegistry.sharedRegistry.alert(message);
};

tw.bridge.openUrl = function(url) {
  TWBridgePageRegistry.sharedRegistry.openUrl(url);
};

tw.bridge.trackEvent = function(event) {
};

tw.bridge.log = function(message) {
  TWBridgePageRegistry.sharedRegistry.nslog(message);
};

tw.bridge.request = function(options) {
  if (options.contentType) {
    options.customHeaders = options.customHeaders || {};
    options.customHeaders['Content-Type'] = options.contentType;
  }
  tw.bridge.requests.issue(
    options.url,
    options.method,
    options.body,
    options.success,
    options.failure,
	  options.customHeaders);
};

tw.bridge.pageObject = function(pageName) {
  var proxyId = generateRandomString(),
    handlerRegistry = {};

  TWBridgePageRegistry.sharedRegistry.registerProxyId_forPageNamed(proxyId, pageName);

  function bind(event, handler) {
    handlerRegistry[event] = handler;
    TWBridgePageRegistry.sharedRegistry.attachHandler_forEvent(proxyId, event);
  }

  function dispatch(event) {
    args = _.toArray(arguments).slice(1);
    if (handlerRegistry[event]) {
      handlerRegistry[event].apply(this, args);
    }
  }

  function get(field) {
    return TWBridgePageRegistry.sharedRegistry.valueForField_onProxy(field, proxyId).valueOf();
  }

  function cleanValues(jsObject) {
    _.each(_.keys(jsObject), function(key) {
      if (jsObject[key] === null || jsObject[key] === undefined) {
        delete jsObject[key];
      } else if (jsObject[key] === false) {
        jsObject[key] = 0;
      } else {
        tw.bridge.log("key = '" + key + "'; value = '" + jsObject[key] + "'");
        if (jsObject[key] instanceof Object) {
          cleanValues(jsObject[key]);
        }
      }
    });
  }

  function render(viewObject) {
    // Clean off properties that cause problems when marshalling
    if (viewObject.hasOwnProperty('toJSONString')) {
      viewObject.toJSONString = null;
    }

    // Delete any keys that have a null value to avoid the Obj-C JSON
    // serialization failure
    if (viewObject != undefined) {
      cleanValues(viewObject);
    }
    if (viewObject.hasOwnProperty('parseJSON')) {
      viewObject.parseJSON = null;
    }
      
    TWBridgePageRegistry.sharedRegistry.render_onProxy(viewObject, proxyId);
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

tw.bridge.requests = (function() {
  var successHandlersById = {},
    failureHandlersById = {};

  function issue(url, method, body, success, failure, customHeaders) {
    var requestId = generateRandomString();
    bodyStr = body;

    if (bodyStr && bodyStr.constructor !== String) {
      bodyStr = JSON.stringify(body);
    }

    successHandlersById[requestId] = success;
    failureHandlersById[requestId] = failure;
    TWBridgeURLRequestManager.sharedManager.requestFrom_url_as_with_andHeaders(
      requestId,
      url,
      method,
      bodyStr,
      customHeaders
    );
  }

  function successfulResponse(requestId, response) {    
    successHandlersById[requestId](response);
    clearHandlers(requestId);
  }

  function failureResponse(requestId, errorCode, response) {
    failureHandlersById[requestId](errorCode, response);
    clearHandlers(requestId);
  }

  function clearHandlers(requestId) {
    successHandlersById[requestId] = null;
    failureHandlersById[requestId] = null;    
  }

  return {
    successfulResponse: successfulResponse,
    failureResponse: failureResponse,
    issue: issue
  };
}());

tw.bridge.timers = (function () {
  callbacks = {};

  return {
    start: function(timeout, callback) {
      var timerId = generateRandomString();
      callbacks[timerId] = callback;
      TWBridgePageRegistry.sharedRegistry.startTimer_timeout(timerId, timeout);
      return timerId;
    },
    fireTimer: function(timerId) {
      if (callbacks[timerId]) {
        callbacks[timerId]();
      }
    },
    clearTimer: function(timerId) {
      delete callbacks[timerId];
    }
  };
}());

tw.bridge.dialog = (function() {
  return {
    display: function(name) {
      TWBridgePageRegistry.sharedRegistry.displayDialog(name)
    }
  };
}());

