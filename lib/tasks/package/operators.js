(function() {
  var CLASS_MEMBER_RE, CLASS_RE, EXPORTS_RE, HASH_KEY_RE, HASH_RE, HASH_VALUE_RE, LITERAL_RE, MEMBER_RE, NAME_RE, Neat, OBJECT_RE, PACKAGE_RE, REQUIRE_RE, SPLIT_MEMBER_RE, STATIC_MEMBER_RE, STRING_RE, analyze, annotateClass, annotateFile, cleanPath, coffee, compile, createDirectory, createFile, ensurePath, existsSync, exportsToPackage, fs, headerLicense, initValidate, join, malformedConf, parallel, parser, path, pathChange, pathReset, preventMissingConf, pro, readFile, resolve, rm, stripRequires, uglify, validate, writeFile, _, _ref, _ref1,
    _this = this;

  path = require('path');

  fs = require('fs');

  resolve = path.resolve;

  writeFile = fs.writeFile, readFile = fs.readFile;

  existsSync = fs.existsSync || path.existsSync;

  Neat = require('../../neat');

  parallel = Neat.require('async').parallel;

  _ref = Neat.require('utils/files'), ensurePath = _ref.ensurePath, rm = _ref.rm, ensurePath = _ref.ensurePath;

  coffee = require('coffee-script').compile;

  _ref1 = require('uglify-js'), parser = _ref1.parser, pro = _ref1.uglify;

  _ = Neat.i18n.getHelper();

  LITERAL_RE = '[a-zA-Z_$][a-zA-Z0-9_$]*';

  STRING_RE = '["\'][^"\']+["\']';

  HASH_KEY_RE = "(" + LITERAL_RE + "|" + STRING_RE + ")";

  OBJECT_RE = "(\\s*" + HASH_KEY_RE + "(\\s*:\\s*([^,\\n}]+)))+";

  EXPORTS_RE = function() {
    return RegExp("(?:\\s|^)(module\\.exports|exports)(\\s*=\\s*\\n" + OBJECT_RE + "|[=\\[.\\s].+\\n)", "gm");
  };

  SPLIT_MEMBER_RE = function() {
    return /\s*=\s*/g;
  };

  MEMBER_RE = function() {
    return RegExp("\\[\\s*" + STRING_RE + "\\s*\\]|\\." + LITERAL_RE);
  };

  NAME_RE = function() {
    return /^[a-zA-Z_$][a-zA-Z0-9_$-.]*$/;
  };

  PACKAGE_RE = function() {
    return RegExp("^(" + LITERAL_RE + ")(\\." + LITERAL_RE + ")*$");
  };

  HASH_VALUE_RE = '(\\s*:\\s*([^,}]+))*';

  HASH_RE = function() {
    return RegExp("\\{(" + HASH_KEY_RE + HASH_VALUE_RE + ",*\\s*)+\\}");
  };

  REQUIRE_RE = function() {
    return RegExp("require\\s*(\\(\\s*)*" + STRING_RE, "gm");
  };

  CLASS_RE = function() {
    return RegExp("^([^#]*)class\\s*(" + LITERAL_RE + ")");
  };

  CLASS_MEMBER_RE = function() {
    return RegExp("^(\\s+)(" + LITERAL_RE + ")\\s*:\\s*(\\([^)]+\\)\\s*)*->");
  };

  STATIC_MEMBER_RE = function() {
    return RegExp("^(\\s+)@(" + LITERAL_RE + ")\\s*:\\s*(\\([^)]+\\)\\s*)*->");
  };

  initValidate = function(fn) {
    fn.validators || (fn.validators = []);
    return fn.validate || (fn.validate = function(conf) {
      var validate, _i, _len, _ref2, _results;

      _ref2 = fn.validators;
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        validate = _ref2[_i];
        _results.push(validate(conf));
      }
      return _results;
    });
  };

  validate = function(key, regex, expect, fn) {
    initValidate(fn);
    fn.validators.push(function(conf) {
      if (!regex.test(conf[key])) {
        throw new Error(_('neat.tasks.package.invalid_string', {
          key: key,
          expect: expect
        }));
      }
    });
    return fn;
  };

  malformedConf = function(key, type, test, fn) {
    initValidate(fn);
    fn.validators.push(function(conf) {
      if (!test(conf)) {
        throw new Error(_('neat.tasks.package.invalid_configuration', {
          key: key,
          type: type
        }));
      }
    });
    return fn;
  };

  preventMissingConf = function(key, fn) {
    initValidate(fn);
    fn.validators.push(function(conf) {
      if (conf[key] == null) {
        throw new Error(_('neat.tasks.package.missing_configuration', {
          key: key
        }));
      }
    });
    return fn;
  };

  analyze = function(path, content) {
    var comment, curClass, i, i2, line, m, out, p, s, _i, _len, _ref2, _ref3, _ref4;

    out = content.concat();
    i2 = 0;
    curClass = null;
    for (i = _i = 0, _len = content.length; _i < _len; i = ++_i) {
      line = content[i];
      comment = null;
      if (CLASS_RE().test(line)) {
        _ref2 = CLASS_RE().exec(line), m = _ref2[0], s = _ref2[1], curClass = _ref2[2];
        comment = "" + s + "`/* " + (cleanPath(path)) + "<" + curClass + "> line:" + (i + 1) + " */`";
      }
      if (CLASS_MEMBER_RE().test(line)) {
        _ref3 = CLASS_MEMBER_RE().exec(line), m = _ref3[0], s = _ref3[1], p = _ref3[2];
        comment = "" + s + "`/* " + (cleanPath(path)) + "<" + curClass + "::" + p + "> line:" + (i + 1) + " */`";
      }
      if (STATIC_MEMBER_RE().test(line)) {
        _ref4 = STATIC_MEMBER_RE().exec(line), m = _ref4[0], s = _ref4[1], p = _ref4[2];
        comment = "" + s + "`/* " + (cleanPath(path)) + "<" + curClass + "." + p + "> line:" + (i + 1) + " */`";
      }
      if (comment != null) {
        out.splice(i2, 0, comment);
        i2++;
      }
      i2++;
    }
    return out;
  };

  annotateClass = function(buffer, conf, errCallback, callback) {
    var content;

    for (path in buffer) {
      content = buffer[path];
      content = content.split('\n');
      content = analyze(path, content);
      buffer[path] = content.join('\n');
    }
    return typeof callback === "function" ? callback(buffer, conf, errCallback) : void 0;
  };

  annotateFile = function(buffer, conf, errCallback, callback) {
    var content, p;

    for (p in buffer) {
      content = buffer[p];
      buffer[p] = "`/* " + (cleanPath(p)) + " */`\n\n" + content + "\n";
    }
    return typeof callback === "function" ? callback(buffer, conf, errCallback) : void 0;
  };

  cleanPath = function(path) {
    return path.replace("" + Neat.root + "/", '');
  };

  compile = function(buffer, conf, errCallback, callback) {
    var content, e, newBuffer;

    newBuffer = {};
    for (path in buffer) {
      content = buffer[path];
      path = path.replace('.coffee', '.js');
      try {
        newBuffer[path] = coffee(content, {
          bare: conf.bare
        });
      } catch (_error) {
        e = _error;
        return typeof errCallback === "function" ? errCallback(e) : void 0;
      }
    }
    return typeof callback === "function" ? callback(newBuffer, conf, errCallback) : void 0;
  };

  preventMissingConf('directory', createDirectory = function(buffer, conf, errCallback, callback) {
    var newBuffer;

    newBuffer = {};
    path = "" + conf.dir + "/" + conf.directory;
    return ensurePath(path, function(err) {
      var c, p;

      for (p in buffer) {
        c = buffer[p];
        newBuffer[p.replace(conf.dir, path)] = c;
      }
      return typeof callback === "function" ? callback(newBuffer, conf, errCallback) : void 0;
    });
  });

  validate('package', PACKAGE_RE(), _('neat.tasks.package.expected_package'), preventMissingConf('package', exportsToPackage = function(buffer, conf, errCallback, callback) {
    var content, convertExports, header;

    header = function(conf) {
      var p, packages, pkg, _i, _len;

      header = '';
      packages = conf["package"].split('.');
      pkg = "@" + (packages.shift());
      header += "" + pkg + " ||= {}\n";
      for (_i = 0, _len = packages.length; _i < _len; _i++) {
        p = packages[_i];
        pkg += "." + p;
        header += "" + pkg + " ||= {}\n";
      }
      return "" + header + "\n";
    };
    convertExports = function(content, conf) {
      var exp, packageFor,
        _this = this;

      packageFor = function(k, v) {
        return "@" + conf["package"] + "." + k + " = " + (v || k);
      };
      exp = [];
      content = content.replace(EXPORTS_RE(), function(m, e, p) {
        var k, member, v, value, values, _i, _j, _len, _len1, _ref2, _ref3, _ref4;

        _ref2 = p.split(SPLIT_MEMBER_RE()), member = _ref2[0], value = _ref2[1];
        if (MEMBER_RE().test(member)) {
          return "@" + conf["package"] + p;
        } else {
          if (HASH_RE().test(value)) {
            values = value.replace(/\{|\}/g, '').strip().split(',').map(function(s) {
              return s.strip().split(/\s*:\s*/);
            });
            for (_i = 0, _len = values.length; _i < _len; _i++) {
              _ref3 = values[_i], k = _ref3[0], v = _ref3[1];
              exp.push(packageFor(k, v));
            }
          } else if (RegExp("" + OBJECT_RE, "m").test(value)) {
            values = value.split('\n').map(function(s) {
              return s.strip().split(/\s*:\s*/);
            });
            for (_j = 0, _len1 = values.length; _j < _len1; _j++) {
              _ref4 = values[_j], k = _ref4[0], v = _ref4[1];
              exp.push(packageFor(k, v));
            }
          } else {
            value = value.strip();
            exp.push("@" + conf["package"] + "." + value + " = " + value);
          }
          return '';
        }
      });
      return "" + content + "\n" + (exp.join('\n'));
    };
    for (path in buffer) {
      content = buffer[path];
      buffer[path] = "" + (header(conf)) + (convertExports(content, conf));
    }
    return typeof callback === "function" ? callback(buffer, conf, errCallback) : void 0;
  }));

  preventMissingConf('license', headerLicense = function(buffer, conf, errCallback, callback) {
    if (!existsSync(conf.license)) {
      return typeof errCallback === "function" ? errCallback(new Error(_('neat.tasks.package.missing_file', {
        file: conf.license
      }))) : void 0;
    }
    return readFile(conf.license, function(err, license) {
      var content, header, _results;

      if (err != null) {
        return typeof errCallback === "function" ? errCallback(err) : void 0;
      }
      license = license.toString().strip().split('\n').map(function(s) {
        return "* " + s;
      }).join('\n');
      header = "/*\n" + license + "\n*/";
      _results = [];
      for (path in buffer) {
        content = buffer[path];
        if (/\.coffee$/.test(path)) {
          buffer[path] = "`" + header + "`\n" + content;
        } else {
          buffer[path] = "" + header + "\n" + content;
        }
        _results.push(typeof callback === "function" ? callback(buffer, conf, errCallback) : void 0);
      }
      return _results;
    });
  });

  validate('name', NAME_RE(), _('neat.tasks.package.expected_name'), preventMissingConf('name', join = function(buffer, conf, errCallback, callback) {
    var k, newBuffer, newContent, newPath, _i, _len, _ref2;

    newBuffer = {};
    newPath = "" + conf.dir + "/" + conf.name + ".coffee";
    newContent = '';
    _ref2 = conf.files;
    for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
      k = _ref2[_i];
      newContent += buffer[k];
    }
    newBuffer[newPath] = newContent;
    return typeof callback === "function" ? callback(newBuffer, conf, errCallback) : void 0;
  }));

  uglify = function(buffer, conf, errCallback, callback) {
    var ast, content, newBuffer;

    newBuffer = {};
    for (path in buffer) {
      content = buffer[path];
      ast = parser.parse(content);
      ast = pro.ast_mangle(ast);
      ast = pro.ast_squeeze(ast);
      newBuffer[path.replace(/\.js$/g, '.min.js')] = pro.gen_code(ast);
    }
    return typeof callback === "function" ? callback(newBuffer, conf, errCallback) : void 0;
  };

  createFile = function(buffer, conf, errCallback, callback) {
    var gen, k, v;

    gen = function(path, content) {
      return function(callback) {
        var dir;

        dir = resolve(path, '..');
        return ensurePath(dir, function(err) {
          return writeFile(path, content, function(err) {
            return typeof callback === "function" ? callback() : void 0;
          });
        });
      };
    };
    return parallel((function() {
      var _results;

      _results = [];
      for (k in buffer) {
        v = buffer[k];
        _results.push(gen(k, v));
      }
      return _results;
    })(), function() {
      return typeof callback === "function" ? callback(buffer, conf, errCallback) : void 0;
    });
  };

  preventMissingConf('path', pathChange = function(buffer, conf, errCallback, callback) {
    var content, newBuffer, rel;

    newBuffer = {};
    for (path in buffer) {
      content = buffer[path];
      rel = path.replace("" + Neat.root + "/", '');
      path = resolve(Neat.root, conf.path, rel.split('/').slice(1).join('/'));
      newBuffer[path] = content;
    }
    return typeof callback === "function" ? callback(newBuffer, conf, errCallback) : void 0;
  });

  preventMissingConf('path', pathReset = function(buffer, conf, errCallback, callback) {
    path = resolve(Neat.root, conf.path);
    return rm(path, function(err) {
      return ensurePath(path, function(err) {
        return typeof callback === "function" ? callback(buffer, conf, errCallback) : void 0;
      });
    });
  });

  stripRequires = function(buffer, conf, errCallback, callback) {
    var content;

    for (path in buffer) {
      content = buffer[path];
      buffer[path] = content.split('\n').reject(function(s) {
        return REQUIRE_RE().test(s);
      }).join('\n');
    }
    return typeof callback === "function" ? callback(buffer, conf, errCallback) : void 0;
  };

  module.exports = {
    annotateClass: annotateClass,
    annotateFile: annotateFile,
    createDirectory: createDirectory,
    compile: compile,
    exportsToPackage: exportsToPackage,
    headerLicense: headerLicense,
    join: join,
    uglify: uglify,
    createFile: createFile,
    pathChange: pathChange,
    pathReset: pathReset,
    stripRequires: stripRequires
  };

}).call(this);
