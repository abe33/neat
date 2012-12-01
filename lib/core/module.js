(function() {
  var Module,
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Module = (function() {

    Module.include = function() {
      var excluded, hook, key, mixin, mixins, value, __excluded__, _i, _len;
      mixins = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.__superOf__ = this.__superOf__.concat();
      __excluded__ = ["constructorHook", "included", "excluded"];
      for (_i = 0, _len = mixins.length; _i < _len; _i++) {
        mixin = mixins[_i];
        excluded = mixin.excluded != null ? __excluded__.concat(mixin.excluded) : __excluded__.concat();
        for (key in mixin) {
          value = mixin[key];
          if (!(__indexOf.call(excluded, key) < 0)) {
            continue;
          }
          this.prototype[key] = value;
          if (typeof value === 'function') {
            this.__superOf__[key] = this.__super__;
          }
        }
        if (mixin.constructorHook != null) {
          hook = mixin.constructorHook;
          this.__hooks__ = this.__hooks__.concat(hook);
        }
      }
      if (typeof mixin.included === "function") {
        mixin.included(this);
      }
      return this;
    };

    Module.__hooks__ = [];

    Module.__superOf__ = {};

    Module.prototype.preventConstructorHooksInModule = false;

    function Module() {
      if (!this.preventConstructorHooksInModule) {
        this.triggerConstructorHooks();
      }
    }

    Module.prototype.triggerConstructorHooks = function() {
      var hook, _i, _len, _ref, _results;
      _ref = this.constructor.__hooks__;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        hook = _ref[_i];
        _results.push(hook.call(this));
      }
      return _results;
    };

    Module.prototype["super"] = function() {
      var args, method, _ref, _ref1;
      method = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return (_ref = this.constructor.__superOf__[method]) != null ? (_ref1 = _ref[method]) != null ? _ref1.apply(this, args) : void 0 : void 0;
    };

    return Module;

  })();

  module.exports = Module;

}).call(this);
