// This is the only file that adds things to the global namespace. To
// simulate, in Node, the appearance of running in a browser, with
// files loaded by <script> tags

// Because it needs to pollute the global namespace, it has been
// written in JavaScript, because CoffeeScript protects the global
// namespace very effectively.

sinon = require('sinon');
underscore = require('underscore');
_ = underscore;

stubView = require('stubView.coffee').stubView;

calatrava = require('environment.spec_helper').calatrava;

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

example = {};
recursiveExtend(example, require('controller.converter').example);
recursiveExtend(example, require('repository.converter').example);

exports.stubView = stubView;
exports.calatrava = calatrava;
exports.appDir = __dirname + "/../app";
exports.example = example;

// Custom matchers:
beforeEach(function() {
  this.addMatchers({
    toBeEmpty: function() {
      if (typeof this.actual === "string") {
        return this.actual === "";
      } else if (_.isArray(this.actual)) {
        return _.isEmpty(this.actual);
      } else {
        return this.actual !== null && this.actual !== undefined && !this.actual.isEmpty();
      }
    }
  });
});
