(function() {
  var allOf, anyOf, equalTo, greaterThan, greaterThanOrEqualTo, hasProperties, hasProperty, isNot, isNotNull, isNull, isType, lowerThan, lowerThanOrEqualTo, match, quacksLike,
    __slice = [].slice;

  match = function(m, v) {
    if (typeof m === 'function') {
      return m(v);
    } else {
      return m === v;
    }
  };

  anyOf = function() {
    var matchers;

    matchers = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return function(el) {
      var m, _i, _len;

      for (_i = 0, _len = matchers.length; _i < _len; _i++) {
        m = matchers[_i];
        if (match(m, el)) {
          return true;
        }
      }
      return false;
    };
  };

  allOf = function() {
    var matchers;

    matchers = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return function(el) {
      var m, _i, _len;

      for (_i = 0, _len = matchers.length; _i < _len; _i++) {
        m = matchers[_i];
        if (!match(m, el)) {
          return false;
        }
      }
      return true;
    };
  };

  equalTo = function(val) {
    return function(el) {
      return el === val;
    };
  };

  greaterThan = function(val) {
    return function(el) {
      return el > val;
    };
  };

  greaterThanOrEqualTo = function(val) {
    return function(el) {
      return el >= val;
    };
  };

  hasProperty = function(prop, val) {
    return function(el) {
      return el[prop] !== void 0 && (val != null ? match(val, el[prop]) : true);
    };
  };

  hasProperties = function() {
    var propsets;

    propsets = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return function(el) {
      var k, propset, results, v, _i, _len;

      results = true;
      for (_i = 0, _len = propsets.length; _i < _len; _i++) {
        propset = propsets[_i];
        if (typeof propset === 'string') {
          results && (results = el[propset] !== void 0);
        } else {
          for (k in propset) {
            v = propset[k];
            results && (results = hasProperty(k, v)(el));
          }
        }
      }
      return results;
    };
  };

  isNot = function(m) {
    return function(el) {
      return !match(m, el);
    };
  };

  isNotNull = function() {
    return function(el) {
      return el != null;
    };
  };

  isNull = function() {
    return function(el) {
      return el == null;
    };
  };

  isType = function(type) {
    return function(el) {
      return typeof el === type;
    };
  };

  lowerThan = function(val) {
    return function(el) {
      return el < val;
    };
  };

  lowerThanOrEqualTo = function(val) {
    return function(el) {
      return el <= val;
    };
  };

  quacksLike = function(def) {
    return function(el) {
      return el != null ? el.quacksLike(def) : void 0;
    };
  };

  module.exports = {
    allOf: allOf,
    anyOf: anyOf,
    equalTo: equalTo,
    greaterThan: greaterThan,
    greaterThanOrEqualTo: greaterThanOrEqualTo,
    hasProperties: hasProperties,
    hasProperty: hasProperty,
    isNot: isNot,
    isNotNull: isNotNull,
    isNull: isNull,
    isType: isType,
    lowerThan: lowerThan,
    lowerThanOrEqualTo: lowerThanOrEqualTo,
    quacksLike: quacksLike
  };

}).call(this);
