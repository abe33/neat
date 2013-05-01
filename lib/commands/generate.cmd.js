(function() {
  var Neat, aliases, deprecated, describe, environment, error, generate, help, helpCmd, missing, puts, render, resolve, run, usages, warn, _, _ref, _ref1,
    __slice = [].slice;

  resolve = require('path').resolve;

  helpCmd = require('./help.cmd').help;

  Neat = require('../neat');

  render = Neat.require("utils/templates").renderSync;

  _ref = Neat.require("utils/logs"), puts = _ref.puts, error = _ref.error, warn = _ref.warn, missing = _ref.missing;

  deprecated = Neat.require("utils/lib").deprecated;

  _ref1 = Neat.require("utils/commands"), run = _ref1.run, aliases = _ref1.aliases, usages = _ref1.usages, describe = _ref1.describe, help = _ref1.help, environment = _ref1.environment;

  _ = Neat.i18n.getHelper();

  generate = function(pr, commands) {
    var f, generators, helpFunc, listContext;

    if (pr == null) {
      throw new Error(_('neat.commands.no_program', {
        command: 'generate'
      }));
    }
    generators = Neat.require("generators");
    listContext = {
      list: generators.map(function(k, v) {
        var usage, _i, _len, _ref2, _results;

        if (v.usages != null) {
          _ref2 = v.usages;
          _results = [];
          for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
            usage = _ref2[_i];
            _results.push([usage, v]);
          }
          return _results;
        } else {
          return [k, v];
        }
      }),
      title: _('neat.commands.generate.help_list_title')
    };
    helpFunc = function(target) {
      return function(generator) {
        var context, gen, helptpl;

        helptpl = resolve(__dirname, "help");
        if ((generator != null) && typeof generator === 'string') {
          gen = generators[generator];
          if (gen != null) {
            if ((gen.help != null) && typeof gen.help === 'function') {
              return gen.help.apply(null, arguments);
            } else {
              return console.log(render(helptpl, gen));
            }
          } else {
            throw new Error(missing(_('neat.commands.generate.generator.name', {
              generator: generator
            })));
          }
        } else {
          context = {};
          context.merge(target);
          context.help = render(resolve(__dirname, "help/_list"), listContext);
          return console.log(render(helptpl, context));
        }
      };
    };
    aliases('g', 'generate', environment('production', usages('neat generate [generator]', describe(_('neat.commands.generate.description'), f = function() {
      var args, callback, command, gen, generator, _i;

      generator = arguments[0], args = 4 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 2) : (_i = 1, []), command = arguments[_i++], callback = arguments[_i++];
      if (typeof generator === "object") {
        return f.help.apply(null, arguments) && (typeof callback === "function" ? callback() : void 0);
      }
      if (args.length === 0) {
        if (typeof command !== "object") {
          args.push(command);
        }
      } else if (typeof callback !== "function") {
        args.push(command) && (command = callback);
      }
      if (!(generator in generators)) {
        return typeof callback === "function" ? callback(new Error(missing(_('neat.commands.generate.generator.name', {
          generator: generator
        })))) : void 0;
      }
      gen = generators[generator];
      if ((gen != null ? gen.deprecated : void 0) != null) {
        deprecated(gen.deprecated);
      }
      if (typeof gen !== "function") {
        return typeof callback === "function" ? callback(new Error(_('neat.commands.generate.invalid_generator', {
          type: typeof gen
        }))) : void 0;
      }
      return gen.apply(null, [generator].concat(args).concat(callback));
    }))));
    return help(helpFunc(f), f);
  };

  module.exports = {
    generate: generate
  };

}).call(this);
