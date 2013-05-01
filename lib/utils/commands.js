(function() {
  var Neat, aliases, asyncErrorTrap, decorate, deprecated, describe, environment, error, hashArguments, help, neatTask, neatTaskAlias, print, puts, resolve, run, spawn, usages, _, _ref,
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  spawn = require('child_process').spawn;

  resolve = require('path').resolve;

  _ref = require('./logs'), puts = _ref.puts, print = _ref.print, error = _ref.error;

  Neat = require('../neat');

  _ = Neat.i18n.getHelper();

  decorate = function(target, property, value) {
    target[property] = value;
    return target;
  };

  aliases = function() {
    var aliases, target, _i;

    aliases = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), target = arguments[_i++];
    return decorate(target, 'aliases', aliases);
  };

  asyncErrorTrap = function(errCallback, callback) {
    return function() {
      var args, err, _ref1;

      err = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (callback == null) {
        _ref1 = [callback, errCallback], errCallback = _ref1[0], callback = _ref1[1];
      }
      if (err != null) {
        if (errCallback != null) {
          return errCallback(err);
        } else {
          return err;
        }
      }
      return callback != null ? callback.apply(null, args) : void 0;
    };
  };

  deprecated = function(message, target) {
    return decorate(target, 'deprecated', message);
  };

  describe = function(description, target) {
    return decorate(target, 'description', description);
  };

  environment = function(env, target) {
    return decorate(target, 'environment', env);
  };

  hashArguments = function() {
    var ary, expr, hash, k, parse, v, _i, _len, _ref1;

    ary = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    ary = ary.flatten();
    hash = {};
    parse = function(v) {
      var sub, _i, _len, _ref1, _results;

      switch (true) {
        case /^(false|no|off)$/.test(v):
          return false;
        case /^(true|yes|on)$/.test(v):
          return true;
        case /^(-*)\d+$/g.test(v):
          return parseInt(v);
        case /^(-*)\d+\.\d+$/g.test(v):
          return parseFloat(v);
        case __indexOf.call(String(v), ',') >= 0:
          _ref1 = v.split(',');
          _results = [];
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            sub = _ref1[_i];
            _results.push(parse(sub));
          }
          return _results;
          break;
        default:
          return v.replace(/^('|")|('|")$/g, '');
      }
    };
    for (_i = 0, _len = ary.length; _i < _len; _i++) {
      expr = ary[_i];
      if (__indexOf.call(expr, ':') < 0) {
        hash[k] = true;
        continue;
      }
      _ref1 = expr.split(':'), k = _ref1[0], v = _ref1[1];
      if (v.empty()) {
        throw new Error(_('neat.commands.invalid_arguments', {
          expression: expr
        }));
      }
      hash[k] = parse(v);
    }
    return hash;
  };

  help = function(help, target) {
    return decorate(target, 'help', help);
  };

  neatTask = function(options) {
    var action, description, name, taskAction;

    name = options.name, action = options.action, description = options.description, environment = options.environment;
    if (name == null) {
      throw new Error(_('neat.tasks.no_name'));
    }
    if (action == null) {
      throw new Error(_('neat.tasks.no_action'));
    }
    action.environment = environment;
    action.description = description;
    taskAction = function() {
      action = options.action, environment = options.environment;
      if (environment != null) {
        Neat.defaultEnvironment = environment;
      }
      return Neat.initEnvironment(function() {
        return Neat.beforeTask.dispatch(function() {
          return action(function(status) {
            return Neat.afterTask.dispatch(status, function() {
              return process.exit(status);
            });
          });
        });
      });
    };
    task(name, description, taskAction);
    return action;
  };

  neatTaskAlias = function(source, alias, environment) {
    return neatTask({
      name: alias,
      description: _('neat.tasks.alias', {
        task: source
      }),
      environment: environment,
      action: function(callback) {
        var task;

        task = Neat.task(source);
        return task(callback);
      }
    });
  };

  run = function(command, params, options, callback) {
    var exe, _ref1;

    if (typeof options === 'function') {
      _ref1 = [options, callback], callback = _ref1[0], options = _ref1[1];
    }
    exe = spawn(command, params);
    if ((options != null ? options.noStdout : void 0) == null) {
      exe.stdout.on('data', (options != null ? options.stdout : void 0) || function(data) {
        return print(data.toString());
      });
    }
    if ((options != null ? options.noStderr : void 0) == null) {
      exe.stderr.on('data', (options != null ? options.stderr : void 0) || function(data) {
        return print(data.toString());
      });
    }
    exe.on('exit', function(status) {
      return typeof callback === "function" ? callback(status) : void 0;
    });
    return exe;
  };

  usages = function() {
    var target, usages, _i;

    usages = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), target = arguments[_i++];
    return decorate(target, 'usages', usages);
  };

  module.exports = {
    aliases: aliases,
    asyncErrorTrap: asyncErrorTrap,
    decorate: decorate,
    describe: describe,
    deprecated: deprecated,
    environment: environment,
    hashArguments: hashArguments,
    help: help,
    neatTask: neatTask,
    neatTaskAlias: neatTaskAlias,
    run: run,
    usages: usages
  };

}).call(this);
