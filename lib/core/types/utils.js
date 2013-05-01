(function() {
  var def;

  def = function(ctor, o) {
    var name, value, _results;

    _results = [];
    for (name in o) {
      value = o[name];
      _results.push(typeof Object.defineProperty === "function" ? Object.defineProperty(ctor.prototype, name, {
        enumerable: false,
        value: value,
        writable: true
      }) : void 0);
    }
    return _results;
  };

  module.exports = {
    def: def
  };

}).call(this);
