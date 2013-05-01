(function() {
  var Neat, cup, describe, dirWithIndexSync, environment, error, existsSync, fs, index, info, namespace, notOutsideNeat, path, puts, render, resolve, usages, _, _ref, _ref1,
    __slice = [].slice;

  fs = require('fs');

  path = require('path');

  resolve = require('path').resolve;

  Neat = require('../neat');

  namespace = Neat.require("utils/exports").namespace;

  _ref = Neat.require("utils/commands"), describe = _ref.describe, usages = _ref.usages, environment = _ref.environment;

  _ref1 = Neat.require("utils/logs"), puts = _ref1.puts, error = _ref1.error, info = _ref1.info, notOutsideNeat = _ref1.notOutsideNeat;

  render = Neat.require("utils/templates").render;

  dirWithIndexSync = Neat.require("utils/files").dirWithIndexSync;

  cup = Neat.require("utils/cup");

  _ = Neat.i18n.getHelper();

  existsSync = fs.existsSync || path.existsSync;

  usages('neat generate package.json', environment('production', describe(_('neat.commands.generate.package.description'), index = function() {
    var args, cb, generator, pkg, _i;

    generator = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), cb = arguments[_i++];
    if (Neat.root == null) {
      throw new Error(notOutsideNeat('package generator'));
    }
    pkg = {};
    return fs.readFile(resolve(Neat.root, ".neat"), function(err, meta) {
      var k, v;

      meta = cup.read(meta);
      for (k in meta) {
        v = meta[k];
        pkg[k] = v;
      }
      return fs.readFile('Nemfile', function(err, nemfile) {
        var context;

        if (err) {
          throw new Error(_('neat.error.no_nemfile'));
        }
        puts("Nemfile found");
        path = resolve(__dirname, "package/dependencies");
        context = {
          npm: nemfile.toString().replace(/^(.|$)/gm, "  $1")
        };
        return render(path, context, function(err, source) {
          var a, bin, binaries, dependencies, g, hasLibIndex, hasSrcIndex, p, pkgfile, _j, _k, _l, _len, _len1, _len2, _ref2, _ref3;

          if (err != null) {
            throw err;
          }
          dependencies = cup.read(source);
          if (dependencies == null) {
            return;
          }
          pkg.dependencies = {};
          pkg.devDependencies = {};
          for (g in dependencies) {
            a = dependencies[g];
            if (g === "default" || g === "production") {
              for (_j = 0, _len = a.length; _j < _len; _j++) {
                _ref2 = a[_j], p = _ref2[0], v = _ref2[1];
                pkg.dependencies[p] = v || "*";
              }
            } else {
              for (_k = 0, _len1 = a.length; _k < _len1; _k++) {
                _ref3 = a[_k], p = _ref3[0], v = _ref3[1];
                pkg.devDependencies[p] = v || "*";
              }
            }
          }
          if (pkg.main == null) {
            hasLibIndex = dirWithIndexSync(resolve(Neat.root, "lib"));
            hasSrcIndex = dirWithIndexSync(resolve(Neat.root, "src"));
            if (hasLibIndex || hasSrcIndex) {
              pkg.main = './lib/index';
            }
          }
          if (existsSync(resolve(Neat.root, "bin"))) {
            binaries = fs.readdirSync(resolve(Neat.root, "bin"));
            if (binaries != null) {
              pkg.bin = {};
              for (_l = 0, _len2 = binaries.length; _l < _len2; _l++) {
                bin = binaries[_l];
                pkg.bin[bin] = "./bin/" + bin;
              }
            }
          }
          pkgfile = resolve(Neat.root, "package.json");
          return fs.writeFile(pkgfile, JSON.stringify(pkg, null, 2), function(err) {
            if (err != null) {
              throw err;
            }
            info(_('neat.commands.generate.package.package_generated').green);
            return typeof cb === "function" ? cb() : void 0;
          });
        });
      });
    });
  })));

  module.exports = namespace("package.json", {
    index: index
  });

}).call(this);
