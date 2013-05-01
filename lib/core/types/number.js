(function() {
  var def;

  def = require('./utils').def;

  def(Number, {
    ago: function() {
      return new Date(new Date().getTime() - this.valueOf());
    }
  });

  def(Number, {
    days: function() {
      return this.hours() * 24;
    }
  });

  def(Number, {
    even: function() {
      return this.valueOf() % 2 === 0;
    }
  });

  def(Number, {
    fromNow: function() {
      return new Date(new Date().getTime() + this.valueOf());
    }
  });

  def(Number, {
    hours: function() {
      return this.minutes() * 60;
    }
  });

  Number.later = function() {
    return this.fromNow();
  };

  def(Number, {
    minutes: function() {
      return this.seconds() * 60;
    }
  });

  def(Number, {
    odd: function() {
      return this.valueOf() % 2 === 1;
    }
  });

  def(Number, {
    seconds: function() {
      return this.valueOf() * 1000;
    }
  });

  def(Number, {
    times: function(target) {
      var i, o, _i, _ref;

      if (typeof target === "function") {
        return (function() {
          var _i, _ref, _results;

          _results = [];
          for (i = _i = 0, _ref = this.valueOf() - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
            _results.push(target(i));
          }
          return _results;
        }).call(this);
      }
      o = target;
      for (i = _i = 1, _ref = this.valueOf() - 1; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
        if (Array.isArray(o)) {
          o = o.concat(target);
        } else {
          o += target;
        }
      }
      return o;
    }
  });

  def(Number, {
    to: function(end, callback) {
      var i, _i, _ref, _results;

      _results = [];
      for (i = _i = _ref = this.valueOf(); _ref <= end ? _i <= end : _i >= end; i = _ref <= end ? ++_i : --_i) {
        _results.push(callback(i));
      }
      return _results;
    }
  });

  def(Number, {
    weeks: function() {
      return this.days() * 7;
    }
  });

}).call(this);
