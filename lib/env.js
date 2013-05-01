(function() {
  var CLICommand, Neat, cmdMap, commandTrigger, commands, core, error, fs, g, help, k, missing, pr, print, puts, register, resolve, spawn, _, _ref,
    __slice = [].slice;

  fs = require('fs');

  pr = require('commander');

  spawn = require('child_process').spawn;

  resolve = require('path').resolve;

  core = require('./core');

  _ref = require("./utils/logs"), puts = _ref.puts, print = _ref.print, error = _ref.error, missing = _ref.missing;

  Neat = require('./neat');

  _ = Neat.i18n.getHelper();

  CLICommand = require('./core/interfaces/cli_command');

  commands = require("./commands");

  commandTrigger = function(c) {
    return function() {
      var args, callback, _i;

      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      if (typeof callback !== 'function') {
        args.push(callback);
        callback = null;
      }
      if (c.environment != null) {
        Neat.defaultEnvironment = c.environment;
      }
      return Neat.initEnvironment(function() {
        return Neat.beforeCommand.dispatch(function() {
          return c.apply(null, args.concat(function(err) {
            if (err != null) {
              error(_('neat.errors.error', {
                msg: err.message,
                stack: err.stack
              }));
            }
            return Neat.afterCommand.dispatch(callback);
          }));
        });
      });
    };
  };

  cmdMap = {};

  register = function(k, c) {
    var alias, _i, _len, _ref1, _results;

    if (!c.quacksLike(CLICommand)) {
      return error(_('neat.commands.invalid_command', {
        command: _('neat.commands.no_register', {
          command: k
        }).red
      }));
    }
    _ref1 = c.aliases;
    _results = [];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      alias = _ref1[_i];
      pr.command(alias).description(c.description).action(commandTrigger(c));
      _results.push(cmdMap[k] = c);
    }
    return _results;
  };

  pr.version(Neat.meta.version);

  for (k in commands) {
    g = commands[k];
    register(k, g(pr, cmdMap));
  }

  pr.command("*").action(function(command) {
    return Neat.initEnvironment(function() {
      return error(_('neat.commands.missing_command', {
        missing: missing(_('neat.commands.command', {
          command: command
        }))
      }));
    });
  });

  pr.parse(process.argv);

  help = cmdMap.help;

  if (pr.args.length === 0 && (help != null)) {
    commandTrigger(help)();
  }

}).call(this);
