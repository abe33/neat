(function() {
  var chain, parallel, queue,
    __slice = [].slice;

  parallel = function(fns, callback) {
    var cb, count, fn, results, _i, _len, _results;

    count = 0;
    results = [];
    cb = function(res) {
      count += 1;
      results.push(res);
      if (count === fns.length) {
        return typeof callback === "function" ? callback(results) : void 0;
      }
    };
    if (fns.empty()) {
      return callback([]);
    } else {
      _results = [];
      for (_i = 0, _len = fns.length; _i < _len; _i++) {
        fn = fns[_i];
        _results.push(fn(cb));
      }
      return _results;
    }
  };

  queue = function(fns, callback) {
    var next;

    next = function() {
      if (fns.empty()) {
        return callback();
      } else {
        return fns.shift()(next);
      }
    };
    return next();
  };

  chain = function() {
    var args, callback, fns, next, _i;

    fns = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), callback = arguments[_i++];
    next = function() {
      var args;

      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (fns.empty()) {
        return callback.apply(null, args);
      } else {
        return fns.shift().apply(null, args.concat(next));
      }
    };
    return next.apply(null, args);
  };

  module.exports = {
    queue: queue,
    parallel: parallel,
    chain: chain
  };

}).call(this);
