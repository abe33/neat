(function() {
  var Neat, aliases, describe, environment, error, first, last, length, list, namespace, property, puts, usages, _, _ref, _ref1, _ref2;

  Neat = require('../neat');

  _ref = Neat.require('utils/logs'), error = _ref.error, puts = _ref.puts;

  _ref1 = Neat.require('utils/commands'), aliases = _ref1.aliases, describe = _ref1.describe, environment = _ref1.environment, usages = _ref1.usages;

  namespace = Neat.require('utils/exports').namespace;

  _ref2 = Neat.require('utils/mappers'), first = _ref2.first, last = _ref2.last, length = _ref2.length, property = _ref2.property;

  _ = Neat.i18n.getHelper();

  list = function(pr, commands) {
    var cmd;

    if (pr == null) {
      throw new Error(_('neat.commands.no_program', {
        command: 'list'
      }));
    }
    return aliases('list', describe(_('neat.commands.list.description'), environment('production', cmd = function(cb) {
      var c1, c2, c3, command, env, k, t, v;

      t = commands.flatten().group(2);
      c1 = t.map(first(length())).max() + 4;
      c2 = t.map(last(property('environment', length()))).compact().max() + 4;
      c3 = t.map(last(property('aliases', function(o) {
        return String(o).length;
      }))).compact().max() + 4;
      command = _('neat.commands.list.headers.command').left(c1);
      environment = _('neat.commands.list.headers.environment').left(c2);
      aliases = _('neat.commands.list.headers.aliases').left(c3);
      puts(("" + command + environment + aliases).yellow, 5);
      for (k in commands) {
        v = commands[k];
        env = v.environment != null ? v.environment.left(c2) : 'default'.left(c2);
        aliases = v.aliases != null ? String(v.aliases).left(c3) : String.fill(c3);
        puts("" + (k.left(c1)) + env + aliases, 5);
      }
      return typeof cb === "function" ? cb() : void 0;
    })));
  };

  module.exports = {
    list: list
  };

}).call(this);
