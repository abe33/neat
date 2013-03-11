(function() {
  var at, first, last, length, property;

  at = function(index, mapper) {
    if (index == null) {
      index = 0;
    }
    return function(el) {
      if (el == null) {
        return void 0;
      }
      if (mapper != null) {
        return mapper(el[index]);
      } else {
        return el[index];
      }
    };
  };

  first = function(mapper) {
    return function(el) {
      if (el == null) {
        return void 0;
      }
      if (mapper != null) {
        return mapper(typeof el.first === "function" ? el.first() : void 0);
      } else {
        return typeof el.first === "function" ? el.first() : void 0;
      }
    };
  };

  last = function(mapper) {
    return function(el) {
      if (el == null) {
        return void 0;
      }
      if (mapper != null) {
        return mapper(typeof el.last === "function" ? el.last() : void 0);
      } else {
        return typeof el.last === "function" ? el.last() : void 0;
      }
    };
  };

  length = function() {
    return function(el) {
      if (el == null) {
        return void 0;
      }
      if (typeof el.length === 'function') {
        return el.length();
      } else {
        return el.length;
      }
    };
  };

  property = function(key, mapper) {
    return function(el) {
      if (el == null) {
        return void 0;
      }
      if (mapper != null) {
        return mapper(el[key]);
      } else {
        return el[key];
      }
    };
  };

  module.exports = {
    at: at,
    first: first,
    last: last,
    length: length,
    property: property
  };

}).call(this);
