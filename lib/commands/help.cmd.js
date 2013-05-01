(function() {
  var Neat, aliases, describe, environment, error, fs, help, missing, puts, render, renderSync, resolve, run, usages, warn, withHelp, _, _ref, _ref1, _ref2,
    __slice = [].slice;

  fs = require('fs');

  resolve = require('path').resolve;

  Neat = require('../neat');

  _ref = Neat.require("utils/templates"), render = _ref.render, renderSync = _ref.renderSync;

  _ref1 = Neat.require("utils/logs"), puts = _ref1.puts, error = _ref1.error, warn = _ref1.warn, missing = _ref1.missing;

  _ref2 = Neat.require('utils/commands'), run = _ref2.run, aliases = _ref2.aliases, usages = _ref2.usages, describe = _ref2.describe, withHelp = _ref2.help, environment = _ref2.environment;

  _ = Neat.i18n.getHelper();

  help = function(pr, commands) {
    var f;

    if (pr == null) {
      throw new Error(_('neat.commands.no_program', {
        command: 'help'
      }));
    }
    if (commands == null) {
      throw new Error(_('neat.commands.no_commands'));
    }
    return aliases('h', 'help', environment('production', usages('neat help [command]', describe(_('neat.commands.help.description'), withHelp(_('neat.commands.help.description'), f = function() {
      var args, c, cb, cmd, command, k, list, listContext, output, _i;

      command = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), cb = arguments[_i++];
      if (typeof cb !== 'function') {
        args.push(cb);
      }
      if ((command != null) && typeof command === 'string') {
        cmd = commands[command];
        if (cmd == null) {
          return typeof cb === "function" ? cb(new Error(missing(_('neat.commands.command', {
            command: command
          })))) : void 0;
        }
      } else {
        list = {};
        for (k in commands) {
          c = commands[k];
          list[c.aliases.join(", ")] = c;
        }
        listContext = {
          list: list,
          title: _('neat.commands.help.help_list_title')
        };
        cmd = {
          usages: ['neat [command] [args]...'],
          description: renderSync(resolve(__dirname, "help/_neat")).yellow,
          help: renderSync(resolve(__dirname, "help/_list"), listContext)
        };
      }
      output = function(err, res) {
        console.log(res);
        return typeof cb === "function" ? cb() : void 0;
      };
      if (typeof cmd.help === 'function') {
        return render(__filename, cmd.help.apply(null, args), output);
      } else {
        return render(__filename, cmd, output);
      }
    })))));
  };

  module.exports = {
    help: help
  };

}).call(this);
