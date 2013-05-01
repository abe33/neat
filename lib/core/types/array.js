(function() {
  var def,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  def = require('./utils').def;

  Array.isArray = function(a) {
    return Object.prototype.toString.call(a) === '[object Array]';
  };

  def(Array, {
    compact: function() {
      return this.select(function(el) {
        return el != null;
      });
    }
  });

  def(Array, {
    empty: function() {
      return this.length === 0;
    }
  });

  def(Array, {
    first: function() {
      if (this.length > 0) {
        return this[0];
      } else {
        return void 0;
      }
    }
  });

  def(Array, {
    flatten: function(level) {
      var a, el, _i, _len;

      if (level == null) {
        level = Infinity;
      }
      if (level < 0) {
        level = Infinity;
      }
      a = [];
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        el = this[_i];
        if (Array.isArray(el) && level !== 0) {
          a = a.concat(el.flatten(level - 1));
        } else {
          a.push(el);
        }
      }
      return a;
    }
  });

  def(Array, {
    group: function(size) {
      var a;

      a = [];
      this.step(size, function() {
        var v;

        return a.push((function() {
          var _i, _len, _results;

          _results = [];
          for (_i = 0, _len = arguments.length; _i < _len; _i++) {
            v = arguments[_i];
            _results.push(v);
          }
          return _results;
        }).apply(this, arguments));
      });
      return a;
    }
  });

  def(Array, {
    last: function() {
      if (this.length > 0) {
        return this[this.length - 1];
      } else {
        return void 0;
      }
    }
  });

  def(Array, {
    max: function() {
      return Math.max.apply(null, this);
    }
  });

  def(Array, {
    min: function() {
      return Math.min.apply(null, this);
    }
  });

  def(Array, {
    reject: function(f) {
      var o, _i, _len, _results;

      _results = [];
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        o = this[_i];
        if (!(typeof f === "function" ? f(o) : void 0)) {
          _results.push(o);
        }
      }
      return _results;
    }
  });

  def(Array, {
    rotate: function(amount) {
      var direction, i, out, range, _i, _j, _k, _len, _len1, _ref, _results;

      if (amount == null) {
        amount = 1;
      }
      if (amount === 0) {
        amount = 1;
      }
      direction = amount > 0;
      out = this.concat();
      range = (function() {
        _results = [];
        for (var _i = 0, _ref = Math.abs(amount) - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this);
      if (direction) {
        for (_j = 0, _len = range.length; _j < _len; _j++) {
          i = range[_j];
          out.push(out.shift());
        }
      } else {
        for (_k = 0, _len1 = range.length; _k < _len1; _k++) {
          i = range[_k];
          out.unshift(out.pop());
        }
      }
      return out;
    }
  });

  def(Array, {
    select: function(f) {
      var o, _i, _len, _results;

      _results = [];
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        o = this[_i];
        if (typeof f === "function" ? f(o) : void 0) {
          _results.push(o);
        }
      }
      return _results;
    }
  });

  def(Array, {
    step: function(n, f) {
      var i, _i, _ref, _results;

      _results = [];
      for (i = _i = 0, _ref = Math.ceil(this.length / n) - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        _results.push(f != null ? f.apply(this, this.slice(i * n, +(i * n + n - 1) + 1 || 9e9)) : void 0);
      }
      return _results;
    }
  });

  def(Array, {
    uniq: function() {
      var out, v, _i, _len;

      out = [];
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        v = this[_i];
        if (__indexOf.call(out, v) < 0) {
          out.push(v);
        }
      }
      return out;
    }
  });

}).call(this);
