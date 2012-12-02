(function() {
  var Mixin,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Mixin = function(mixin) {
    var included;
    included = mixin.included;
    mixin.included = function(base) {
      var _ref;
      if (typeof included === "function") {
        included(base);
      }
      if ((_ref = base.__mixins__) == null) {
        base.__mixins__ = [];
      }
      if (__indexOf.call(base.__mixins__, mixin) < 0) {
        return base.__mixins__.push(mixin);
      }
    };
    mixin.excluded = ["isMixinOf", "__definition__"];
    mixin.isMixinOf = function(object) {
      if (object.constructor.__mixins__ != null) {
        return __indexOf.call(object.constructor.__mixins__, mixin) >= 0;
      }
    };
    return mixin;
  };

  module.exports = Mixin;

}).call(this);
