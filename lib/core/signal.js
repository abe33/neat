(function() {
  var Signal,
    __slice = [].slice;

  Signal = (function() {
    function Signal() {
      var signature;

      signature = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.signature = signature;
      this.listeners = [];
      this.asyncListeners = 0;
    }

    Signal.prototype.add = function(listener, context, priority) {
      if (priority == null) {
        priority = 0;
      }
      this.validate(listener);
      if (!this.registered(listener, context)) {
        this.listeners.push([listener, context, false, priority]);
        if (this.isAsync(listener)) {
          this.asyncListeners++;
        }
        return this.sortListeners();
      }
    };

    Signal.prototype.addOnce = function(listener, context, priority) {
      if (priority == null) {
        priority = 0;
      }
      this.validate(listener);
      if (!this.registered(listener, context)) {
        this.listeners.push([listener, context, true, priority]);
        if (this.isAsync(listener)) {
          this.asyncListeners++;
        }
        return this.sortListeners();
      }
    };

    Signal.prototype.remove = function(listener, context) {
      if (this.registered(listener, context)) {
        if (this.isAsync(listener)) {
          this.asyncListeners--;
        }
        return this.listeners.splice(this.indexOf(listener, context), 1);
      }
    };

    Signal.prototype.removeAll = function() {
      this.listeners = [];
      return this.asyncListeners = 0;
    };

    Signal.prototype.indexOf = function(listener, context) {
      var c, i, l, _i, _len, _ref, _ref1;

      _ref = this.listeners;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        _ref1 = _ref[i], l = _ref1[0], c = _ref1[1];
        if (listener === l && context === c) {
          return i;
        }
      }
      return -1;
    };

    Signal.prototype.registered = function(listener, context) {
      return this.indexOf(listener, context) !== -1;
    };

    Signal.prototype.hasListeners = function() {
      return this.listeners.length !== 0;
    };

    Signal.prototype.sortListeners = function() {
      if (this.listeners.length <= 1) {
        return;
      }
      return this.listeners.sort(function(a, b) {
        var pA, pB, _ref;

        _ref = [a[3], b[3]], pA = _ref[0], pB = _ref[1];
        if (pA < pB) {
          return 1;
        } else if (pB < pA) {
          return -1;
        } else {
          return 0;
        }
      });
    };

    Signal.prototype.validate = function(listener) {
      var args, listenerSignature, m, re, s1, s2, signature;

      if (this.signature.length > 0) {
        re = /[^(]+\(([^)]+)\).*$/m;
        listenerSignature = Function.prototype.toString.call(listener).split('\n').shift();
        signature = listenerSignature.replace(re, '$1');
        args = signature.split(/\s*,\s*/g);
        if (args.first() === '') {
          args.shift();
        }
        if (args.last() === 'callback') {
          args.pop();
        }
        s1 = this.signature.join();
        s2 = args.join();
        m = "The listener " + listener + " doesn't match the signal's signature " + s1;
        if (s2 !== s1) {
          throw new Error(m);
        }
      }
    };

    Signal.prototype.isAsync = function(listener) {
      return Function.prototype.toString.call(listener).indexOf('callback)') !== -1;
    };

    Signal.prototype.dispatch = function() {
      var args, callback, context, listener, listeners, next, once, priority, _i, _j, _len, _ref,
        _this = this;

      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      if (typeof callback !== 'function') {
        args.push(callback);
        callback = null;
      }
      listeners = this.listeners.concat();
      if (this.asyncListeners > 0) {
        next = function(callback) {
          var context, listener, once, priority, _ref;

          if (listeners.length) {
            _ref = listeners.shift(), listener = _ref[0], context = _ref[1], once = _ref[2], priority = _ref[3];
            if (_this.isAsync(listener)) {
              return listener.apply(context, args.concat(function() {
                if (once) {
                  _this.remove(listener, context);
                }
                return next(callback);
              }));
            } else {
              listener.apply(context, args);
              if (once) {
                _this.remove(listener, context);
              }
              return next(callback);
            }
          } else {
            return typeof callback === "function" ? callback() : void 0;
          }
        };
        return next(callback);
      } else {
        for (_j = 0, _len = listeners.length; _j < _len; _j++) {
          _ref = listeners[_j], listener = _ref[0], context = _ref[1], once = _ref[2], priority = _ref[3];
          listener.apply(context, arguments);
          if (once) {
            this.remove(listener, context);
          }
        }
        return typeof callback === "function" ? callback() : void 0;
      }
    };

    return Signal;

  })();

  module.exports = Signal;

}).call(this);
