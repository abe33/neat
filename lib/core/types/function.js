(function() {
  var CALLBACK, EMPTY_SIGNATURE, SIGN_POSITION, def,
    __slice = [].slice;

  def = require('./utils').def;

  Function.commaRE = /\s*,\s*/g;

  Function.signRE = /^function\s+([a-zA-Z_$][a-zA-Z0-9_$]*)*\(([^)]*)\)/;

  SIGN_POSITION = 2;

  EMPTY_SIGNATURE = '';

  CALLBACK = 'callback';

  Function.isAsync = function(fn) {
    return fn.signature().last() === CALLBACK;
  };

  def(Function, {
    isAsync: function() {
      return Function.isAsync(this);
    }
  });

  def(Function, {
    signature: function() {
      var sign;

      sign = Function.signRE.exec(this.toString())[SIGN_POSITION];
      if (sign === EMPTY_SIGNATURE) {
        return [];
      } else {
        return sign.split(Function.commaRE);
      }
    }
  });

  def(Function, {
    callAsync: function() {
      var args, callback, context, res, _i;

      context = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), callback = arguments[_i++];
      if (this.isAsync()) {
        return this.apply(context, args.concat(callback));
      } else {
        res = this.apply(context, args);
        return typeof callback === "function" ? callback(res) : void 0;
      }
    }
  });

  def(Function, {
    applyAsync: function(context, args, callback) {
      var res;

      if (this.isAsync()) {
        return this.apply(context, args.concat(callback));
      } else {
        res = this.apply(context, args);
        return typeof callback === "function" ? callback(res) : void 0;
      }
    }
  });

}).call(this);
