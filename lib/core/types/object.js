(function() {
  var def,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  def = require('./utils').def;

  Object["new"] = function(a) {
    var o;

    o = {};
    a.step(2, function(k, v) {
      return o[k] = v;
    });
    return o;
  };

  def(Object, {
    concat: function(m) {
      var k, o, v;

      o = {};
      for (k in this) {
        v = this[k];
        o[k] = v;
      }
      return o.merge(m || {});
    }
  });

  def(Object, {
    destroy: function(key) {
      var res;

      if (this.hasKey(key)) {
        res = this[key];
        delete this[key];
        return res;
      }
      return null;
    }
  });

  def(Object, {
    each: function(f) {
      var k, v;

      if (f != null) {
        for (k in this) {
          v = this[k];
          f(k, v);
        }
      }
      return this;
    }
  });

  def(Object, {
    empty: function() {
      return this.keys().empty();
    }
  });

  def(Object, {
    first: function() {
      if (this.empty()) {
        return null;
      } else {
        return this.flatten().group(2).first();
      }
    }
  });

  def(Object, {
    flatten: function() {
      var a, k, v;

      a = [];
      for (k in this) {
        v = this[k];
        a = a.concat([k, v]);
      }
      return a;
    }
  });

  def(Object, {
    has: function(value) {
      return __indexOf.call(this.values(), value) >= 0;
    }
  });

  def(Object, {
    hasKey: function(key) {
      return this[key] != null;
    }
  });

  def(Object, {
    keys: function() {
      var k, _results;

      _results = [];
      for (k in this) {
        _results.push(k);
      }
      return _results;
    }
  });

  def(Object, {
    length: function() {
      return this.keys().length;
    }
  });

  def(Object, {
    last: function() {
      if (this.empty()) {
        return null;
      } else {
        return this.flatten().group(2).last();
      }
    }
  });

  def(Object, {
    map: function(f) {
      var k, v;

      return Object["new"](((function() {
        var _results;

        _results = [];
        for (k in this) {
          v = this[k];
          _results.push(f(k, v));
        }
        return _results;
      }).call(this)).flatten());
    }
  });

  def(Object, {
    merge: function(o) {
      var k, v;

      for (k in o) {
        v = o[k];
        this[k] = v;
      }
      return this;
    }
  });

  def(Object, {
    reject: function(f) {
      var k, o, v;

      o = {};
      for (k in this) {
        v = this[k];
        if (!(typeof f === "function" ? f(k, v) : void 0)) {
          o[k] = v;
        }
      }
      return o;
    }
  });

  def(Object, {
    select: function(f) {
      var k, o, v;

      o = {};
      for (k in this) {
        v = this[k];
        if (typeof f === "function" ? f(k, v) : void 0) {
          o[k] = v;
        }
      }
      return o;
    }
  });

  def(Object, {
    size: function() {
      return this.length();
    }
  });

  def(Object, {
    sort: function(f) {
      var k, o, _i, _len, _ref;

      if ((f == null) || typeof f !== 'function') {
        f = function(a, b) {
          if (a > b) {
            return 1;
          } else if (b < a) {
            return -1;
          } else {
            return 0;
          }
        };
      }
      o = {};
      _ref = this.keys().sort(f);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        k = _ref[_i];
        o[k] = this[k];
      }
      return o;
    }
  });

  def(Object, {
    sortedKeys: function() {
      return this.keys().sort();
    }
  });

  def(Object, {
    sortedValues: function() {
      var k, _i, _len, _ref, _results;

      _ref = this.sortedKeys();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        k = _ref[_i];
        _results.push(this[k]);
      }
      return _results;
    }
  });

  def(Object, {
    tap: function(block) {
      block.call(this, this);
      return this;
    }
  });

  def(Object, {
    type: function() {
      return Object.prototype.toString.call(this).toLowerCase().replace(/\[object (\w+)\]/, "$1");
    }
  });

  def(Object, {
    update: Object.prototype.merge
  });

  def(Object, {
    values: function() {
      var k, _i, _len, _ref, _results;

      _ref = this.keys();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        k = _ref[_i];
        _results.push(this[k]);
      }
      return _results;
    }
  });

  def(Object, {
    quacksLike: function(type) {
      var definition, k, v, _ref;

      if (type.__definition__ != null) {
        definition = type.__definition__;
        if (typeof definition === "function") {
          return definition(this);
        }
        for (k in definition) {
          v = definition[k];
          switch (typeof v) {
            case "function":
              if (!v(this[k])) {
                return false;
              }
              break;
            default:
              if (!(v === "*" || ((_ref = this[k]) != null ? _ref.type() : void 0) === v)) {
                return false;
              }
          }
        }
        return true;
      } else {
        return false;
      }
    }
  });

}).call(this);
