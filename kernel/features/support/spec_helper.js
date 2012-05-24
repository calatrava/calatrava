// This is the only file that adds things to the global namespace. To
// simulate, in Node, the appearance of running in a browser, with
// files loaded by <script> tags

// Because it needs to pollute the global namespace, it has been
// written in JavaScript, because CoffeeScript protects the global
// namespace very effectively.

coffee = require('coffee-script')
sinon = require('sinon');
should = require('should');
date = require('date');

underscore = require('underscore');
_ = underscore;

exports.tw = require('bridge').tw;

function recursiveExtend(moduleToExtend, module) {
  _.each(module, function (value, key) {
    if (moduleToExtend[key] == null) moduleToExtend[key] = {};
    if (typeof value == "Object") {
      recursiveExtend(moduleToExtend[key], value);
    } else {
      _.extend(moduleToExtend[key], module[key]);
    }
  });
}

function getPageObjectForPageName(pageName){
  var pageObject;
  return pageObject;
}

function getWidget(name) {
  return tw.bridge.widgets.widget(name)
}

function showDialog(name) {
  return tw.bridge.dialog.display(name)
}

function triggerTimer(name){
  return tw.bridge.timers.triggerTimer(name)
}

exports.getPageObjectForPageName = getPageObjectForPageName;
exports.getWidget = getWidget;
exports.triggerTimer = triggerTimer;
