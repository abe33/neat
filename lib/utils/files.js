(function() {
  var basename, dirWithIndex, dirWithIndexSync, ensure, ensurePath, ensurePathSync, ensureSync, error, exists, existsSync, extname, find, findBase, findBaseSync, findOnce, findSiblingFile, findSiblingFileSync, findSync, findSyncOnce, fs, isNeatRoot, isNeatRootSync, missing, neatRoot, neatRootSync, noExtension, parallel, path, puts, readFiles, readFilesSync, relative, resolve, rm, rmSync, touch, touchSync, warn, _ref, _ref1,
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  fs = require('fs');

  path = require('path');

  _ref = require('path'), resolve = _ref.resolve, basename = _ref.basename, relative = _ref.relative, extname = _ref.extname;

  _ref1 = require('./logs'), puts = _ref1.puts, error = _ref1.error, warn = _ref1.warn, missing = _ref1.missing;

  parallel = require('../async').parallel;

  existsSync = fs.existsSync || path.existsSync;

  exists = fs.exists || path.exists;

  dirWithIndex = function(dir, ext, callback) {
    var _ref2;

    if (ext == null) {
      ext = null;
    }
    if (typeof ext === 'function') {
      _ref2 = [callback, ext], ext = _ref2[0], callback = _ref2[1];
    }
    return exists(dir, function(b) {
      var index;

      if (!b) {
        return typeof callback === "function" ? callback() : void 0;
      }
      index = ext != null ? "index." + ext : "index";
      return findBase(dir, index, function(res) {
        return callback(res != null ? res[0] : void 0);
      });
    });
  };

  dirWithIndexSync = function(dir, ext) {
    var index, _ref2;

    if (ext == null) {
      ext = null;
    }
    if (!existsSync(dir)) {
      return;
    }
    index = ext != null ? "index." + ext : "index";
    return (_ref2 = findBaseSync(dir, index)) != null ? _ref2[0] : void 0;
  };

  ensure = function(dir, callback) {
    return exists(dir, function(b) {
      if (b) {
        return typeof callback === "function" ? callback(null, false) : void 0;
      } else {
        return fs.mkdir(dir, function(err) {
          if (err != null) {
            return typeof callback === "function" ? callback(err, false) : void 0;
          } else {
            return typeof callback === "function" ? callback(null, true) : void 0;
          }
        });
      }
    });
  };

  ensureSync = function(dir) {
    if (!existsSync(dir)) {
      fs.mkdirSync(dir);
      return true;
    }
    return false;
  };

  ensurePath = function(path, callback) {
    var d, dirs, generator, next, p, stack, _i, _len;

    stack = [];
    generator = function(d) {
      return function(callback) {
        return ensure(d, callback);
      };
    };
    next = function(err, created) {
      var _base;

      if (err != null) {
        if (typeof callback === "function") {
          callback(err, false);
        }
      }
      if (stack.length > 0) {
        return typeof (_base = stack.shift()) === "function" ? _base(next) : void 0;
      } else {
        return typeof callback === "function" ? callback(null, created) : void 0;
      }
    };
    dirs = path.split('/').slice(1);
    p = '';
    for (_i = 0, _len = dirs.length; _i < _len; _i++) {
      d = dirs[_i];
      stack.push(generator(p = "" + p + "/" + d));
    }
    return next();
  };

  ensurePathSync = function(path) {
    var d, dirs, p, _results;

    dirs = path.split('/');
    dirs.shift();
    p = '/';
    _results = [];
    while (dirs.length > 0) {
      d = dirs.shift();
      p = resolve(p, d);
      if (!existsSync(p)) {
        _results.push(fs.mkdirSync(p));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  find = function(pattern, ext, paths, callback) {
    var lookup, output, p, _ref2;

    if (typeof pattern === "string") {
      _ref2 = [null, pattern, ext, paths], pattern = _ref2[0], ext = _ref2[1], paths = _ref2[2], callback = _ref2[3];
    }
    if (typeof paths === "string") {
      return findOnce(pattern, ext, paths, callback);
    } else {
      output = [];
      lookup = function(pattern, ext, paths) {
        return function(cb) {
          return findOnce(pattern, ext, paths, function(err, files) {
            var file, _i, _len;

            if (files != null) {
              for (_i = 0, _len = files.length; _i < _len; _i++) {
                file = files[_i];
                output.push(file);
              }
            }
            return typeof cb === "function" ? cb() : void 0;
          });
        };
      };
      if (paths.empty()) {
        return typeof callback === "function" ? callback(null, output) : void 0;
      } else {
        return parallel((function() {
          var _i, _len, _results;

          _results = [];
          for (_i = 0, _len = paths.length; _i < _len; _i++) {
            p = paths[_i];
            _results.push(lookup(pattern, ext, p));
          }
          return _results;
        })(), function() {
          return typeof callback === "function" ? callback(null, output) : void 0;
        });
      }
    }
  };

  findOnce = function(pattern, ext, path, callback, output) {
    return exists(path, function(b) {
      var extRe, lookup, out;

      if (b == null) {
        if (typeof callback === "function") {
          callback(new Error(''));
        }
      }
      out = [];
      extRe = RegExp("\\." + ext + "$");
      lookup = function(path, output) {
        return function(cb) {
          var p;

          p = basename(path);
          return fs.lstat(path, function(err, stats) {
            var found;

            if (stats.isDirectory()) {
              return find(pattern, ext, path, function(err, files) {
                var file, index, _i, _len;

                if (err != null) {
                  return typeof callback === "function" ? callback(err) : void 0;
                }
                if (files != null) {
                  for (_i = 0, _len = files.length; _i < _len; _i++) {
                    file = files[_i];
                    output.push(file);
                  }
                }
                index = resolve(path, "index." + ext);
                return exists(index, function(b) {
                  if ((pattern != null) && p.match(pattern) && b) {
                    output.push(index);
                  }
                  return typeof cb === "function" ? cb() : void 0;
                });
              });
            } else if (p.match(extRe)) {
              if (pattern != null) {
                if (p.replace(extRe, '').match(pattern)) {
                  found = path;
                }
              } else {
                found = path;
              }
              if (found != null) {
                output.push(found);
              }
              return typeof cb === "function" ? cb() : void 0;
            } else {
              return typeof cb === "function" ? cb() : void 0;
            }
          });
        };
      };
      return fs.readdir(path, function(err, content) {
        var p;

        if (err != null) {
          throw err;
        }
        output = [];
        if (content.empty()) {
          return typeof callback === "function" ? callback(null, output) : void 0;
        } else {
          return parallel((function() {
            var _i, _len, _results;

            _results = [];
            for (_i = 0, _len = content.length; _i < _len; _i++) {
              p = content[_i];
              _results.push(lookup(resolve(path, p), output));
            }
            return _results;
          })(), function() {
            return typeof callback === "function" ? callback(null, output) : void 0;
          });
        }
      });
    });
  };

  findSync = function(pattern, ext, paths) {
    var founds, out, _i, _len, _ref2;

    if (typeof pattern === "string") {
      _ref2 = [null, pattern, ext], pattern = _ref2[0], ext = _ref2[1], paths = _ref2[2];
    }
    if (typeof paths === "string") {
      return findSyncOnce(pattern, ext, paths);
    } else {
      out = [];
      for (_i = 0, _len = paths.length; _i < _len; _i++) {
        path = paths[_i];
        founds = findSyncOnce(pattern, ext, path);
        if (founds != null) {
          out = out.concat(founds);
        }
      }
      return out;
    }
  };

  findSyncOnce = function(pattern, ext, path) {
    var content, extRe, found, index, out, p, stats, _i, _len, _path;

    if (!existsSync(path)) {
      return;
    }
    out = [];
    extRe = RegExp("\\." + ext + "$");
    content = fs.readdirSync(path);
    for (_i = 0, _len = content.length; _i < _len; _i++) {
      p = content[_i];
      found = null;
      _path = resolve(path, p);
      stats = fs.lstatSync(_path);
      if (stats.isDirectory()) {
        found = findSync(pattern, ext, _path);
        index = resolve(_path, "index." + ext);
        if ((pattern != null) && p.match(pattern) && existsSync(index)) {
          if (found == null) {
            found = [];
          }
          found.push(index);
        }
      } else if (p.match(extRe)) {
        if (pattern != null) {
          if (p.replace(extRe, '').match(pattern)) {
            found = _path;
          }
        } else {
          found = _path;
        }
      }
      if (found != null) {
        out = out.concat(found);
      }
    }
    if (out.length > 0) {
      return out;
    } else {
      return null;
    }
  };

  findBase = function(dir, base, callback) {
    return exists(dir, function(b) {
      if (!b) {
        return typeof callback === "function" ? callback() : void 0;
      }
      return fs.readdir(dir, function(err, content) {
        var f, res;

        if (err != null) {
          return typeof callback === "function" ? callback() : void 0;
        }
        res = (function() {
          var _i, _len, _results;

          _results = [];
          for (_i = 0, _len = content.length; _i < _len; _i++) {
            f = content[_i];
            if (f.match(RegExp("^" + base + "(\\.|$)"))) {
              _results.push(resolve(dir, f));
            }
          }
          return _results;
        })();
        return typeof callback === "function" ? callback(res) : void 0;
      });
    });
  };

  findBaseSync = function(dir, base) {
    var content, f, _i, _len, _results;

    if (!existsSync(dir)) {
      return;
    }
    content = fs.readdirSync(dir);
    _results = [];
    for (_i = 0, _len = content.length; _i < _len; _i++) {
      f = content[_i];
      if (f.match(RegExp("^" + base + "(\\.|$)"))) {
        _results.push(resolve(dir, f));
      }
    }
    return _results;
  };

  findSiblingFile = function() {
    var callback, dir, exts, path, paths, roots, _i;

    path = arguments[0], roots = arguments[1], dir = arguments[2], exts = 5 <= arguments.length ? __slice.call(arguments, 3, _i = arguments.length - 1) : (_i = 3, []), callback = arguments[_i++];
    paths = [];
    return neatRoot(path, function(pathRoot) {
      var base, dif, found, lookup, matchExtensions, matches, newPath, p, root, start;

      if (pathRoot == null) {
        return typeof callback === "function" ? callback(new Error(), void 0, []) : void 0;
      }
      start = noExtension(path);
      base = basename(start);
      dif = relative(pathRoot, resolve(start, ".."));
      newPath = dif.replace(/^[^\/]+/, dir);
      if ((exts == null) || exts.empty() || (exts.length === 1 && exts[0] === '*')) {
        exts = '*';
      }
      p = void 0;
      roots = roots.concat();
      roots.reverse();
      matches = {};
      found = [];
      matchExtensions = function(p) {
        var _ref2;

        return (_ref2 = extname(p).substr(1), __indexOf.call(exts, _ref2) >= 0) || exts === "*";
      };
      lookup = function(root) {
        return function(cb) {
          var basepath;

          basepath = resolve(root, newPath);
          paths.push(basepath);
          return findBase(basepath, base, function(ps) {
            var entryMatch;

            if ((ps != null) && !ps.empty()) {
              ps.sort();
              entryMatch = function(p) {
                return function(cb) {
                  return fs.lstat(p, function(err, stats) {
                    var _name;

                    if (err != null) {
                      return typeof callback === "function" ? callback(err, null, path) : void 0;
                    }
                    paths.push(p);
                    if (stats.isDirectory()) {
                      paths.push(resolve(p, 'index.*'));
                      return dirWithIndex(p, function(ip) {
                        var _name;

                        if ((ip != null) && matchExtensions(ip)) {
                          matches[_name = roots.indexOf(root)] || (matches[_name] = []);
                          matches[roots.indexOf(root)].push(ip);
                        }
                        return typeof cb === "function" ? cb() : void 0;
                      });
                    } else {
                      if (matchExtensions(p)) {
                        matches[_name = roots.indexOf(root)] || (matches[_name] = []);
                        matches[roots.indexOf(root)].push(p);
                      }
                      return typeof cb === "function" ? cb() : void 0;
                    }
                  });
                };
              };
              return parallel((function() {
                var _j, _len, _results;

                _results = [];
                for (_j = 0, _len = ps.length; _j < _len; _j++) {
                  p = ps[_j];
                  _results.push(entryMatch(p));
                }
                return _results;
              })(), function() {
                var i, r, _j, _len;

                for (i = _j = 0, _len = roots.length; _j < _len; i = ++_j) {
                  r = roots[i];
                  found.push(matches[i]);
                }
                found = found.flatten().compact();
                return typeof cb === "function" ? cb() : void 0;
              });
            } else {
              return typeof cb === "function" ? cb() : void 0;
            }
          });
        };
      };
      if (roots.empty()) {
        return typeof callback === "function" ? callback(null, null, paths) : void 0;
      } else {
        return parallel((function() {
          var _j, _len, _results;

          _results = [];
          for (_j = 0, _len = roots.length; _j < _len; _j++) {
            root = roots[_j];
            _results.push(lookup(root));
          }
          return _results;
        })(), function() {
          return typeof callback === "function" ? callback(null, found.sort()[0], paths) : void 0;
        });
      }
    });
  };

  findSiblingFileSync = function() {
    var base, basepath, dif, dir, ext, exts, newPath, p, path, pathRoot, paths, ps, root, roots, start, stats, _i, _j, _k, _l, _len, _len1, _len2, _ref2;

    path = arguments[0], roots = arguments[1], dir = arguments[2], exts = 5 <= arguments.length ? __slice.call(arguments, 3, _i = arguments.length - 1) : (_i = 3, []), paths = arguments[_i++];
    pathRoot = neatRootSync(path);
    if (pathRoot == null) {
      return;
    }
    if (typeof paths === "string") {
      _ref2 = [exts.concat(paths), null], exts = _ref2[0], paths = _ref2[1];
    }
    start = noExtension(path);
    base = basename(start);
    dif = relative(pathRoot, resolve(start, ".."));
    newPath = dif.replace(/^[^\/]+/, dir);
    if (exts == null) {
      exts = "*";
    }
    if (typeof exts !== "object") {
      exts = [exts];
    }
    p = void 0;
    roots = roots.concat();
    roots.reverse();
    for (_j = 0, _len = roots.length; _j < _len; _j++) {
      root = roots[_j];
      basepath = resolve(root, newPath);
      for (_k = 0, _len1 = exts.length; _k < _len1; _k++) {
        ext = exts[_k];
        if (paths != null) {
          paths.push(resolve(basepath, ext === "*" ? base : "" + base + "." + ext));
        }
        ps = findBaseSync(basepath, base);
        if (ps != null) {
          ps.sort();
          for (_l = 0, _len2 = ps.length; _l < _len2; _l++) {
            p = ps[_l];
            stats = fs.lstatSync(p);
            if (stats.isDirectory()) {
              if (paths != null) {
                paths.push(resolve(p, ext === "*" ? "index" : "index." + ext));
              }
              p = dirWithIndexSync(p);
              if (ext !== "*") {
                if (p != null ? p.match(RegExp("\\." + ext + "$")) : void 0) {
                  return p;
                } else {
                  p = void 0;
                }
              } else {
                return p;
              }
            } else if (ext !== "*") {
              if (p != null ? p.match(RegExp("\\." + ext + "$")) : void 0) {
                return p;
              } else {
                p = void 0;
              }
            } else {
              return p;
            }
          }
        }
      }
    }
    return void 0;
  };

  isNeatRoot = function(dir, callback) {
    return exists(resolve(dir, ".neat"), callback);
  };

  isNeatRootSync = function(dir) {
    return existsSync(resolve(dir, ".neat"));
  };

  neatRoot = function(path, callback) {
    if (path == null) {
      path = ".";
    }
    path = resolve(path);
    return isNeatRoot(path, function(bool) {
      var parentPath;

      if (bool) {
        return typeof callback === "function" ? callback(path) : void 0;
      } else {
        parentPath = resolve(path, "..");
        if (parentPath === path) {
          return typeof callback === "function" ? callback() : void 0;
        }
        return neatRoot(parentPath, callback);
      }
    });
  };

  neatRootSync = function(path) {
    var parentPath;

    if (path == null) {
      path = ".";
    }
    path = resolve(path);
    if (isNeatRootSync(path)) {
      return path;
    } else {
      parentPath = resolve(path, "..");
      if (parentPath !== path) {
        return neatRootSync(parentPath);
      }
    }
  };

  noExtension = function(o) {
    var last, p;

    p = o.split('/');
    last = p.pop();
    last = last.replace(/([^/.]+)\..+$/, "$1");
    return p.concat(last).join('/');
  };

  readFiles = function(files, callback) {
    var p, readIteration, res;

    res = {};
    error = null;
    readIteration = function(path) {
      return function(cb) {
        return fs.readFile(path, function(err, content) {
          if (err != null) {
            return (error = err, cb());
          }
          res[path] = String(content);
          return cb();
        });
      };
    };
    return parallel((function() {
      var _i, _len, _results;

      _results = [];
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        p = files[_i];
        _results.push(readIteration(p));
      }
      return _results;
    })(), function() {
      return typeof callback === "function" ? callback(error, res) : void 0;
    });
  };

  readFilesSync = function(files) {
    var res, _i, _len;

    res = {};
    for (_i = 0, _len = files.length; _i < _len; _i++) {
      path = files[_i];
      res[path] = fs.readFileSync(path);
    }
    return res;
  };

  rm = function(path, callback) {
    var rmIteration;

    rmIteration = function(path) {
      return function(callback) {
        return rm(path, callback);
      };
    };
    return exists(path, function(exist) {
      if (exist) {
        return fs.lstat(path, function(err, stats) {
          if (err != null) {
            return typeof callback === "function" ? callback(err) : void 0;
          }
          if (stats.isDirectory()) {
            return fs.readdir(path, function(err, paths) {
              var p;

              if (err != null) {
                return typeof callback === "function" ? callback(err) : void 0;
              }
              return parallel((function() {
                var _i, _len, _results;

                _results = [];
                for (_i = 0, _len = paths.length; _i < _len; _i++) {
                  p = paths[_i];
                  _results.push(rmIteration("" + path + "/" + p));
                }
                return _results;
              })(), function() {
                return fs.rmdir(path, function(err) {
                  return typeof callback === "function" ? callback(err) : void 0;
                });
              });
            });
          } else {
            return fs.unlink(path, function(err) {
              return typeof callback === "function" ? callback(err) : void 0;
            });
          }
        });
      } else {
        return typeof callback === "function" ? callback() : void 0;
      }
    });
  };

  rmSync = function(path) {
    var p, paths, stats, _i, _len;

    if (existsSync(path)) {
      stats = fs.lstatSync(path);
      if (stats.isDirectory()) {
        paths = fs.readdirSync(path);
        if (paths != null) {
          for (_i = 0, _len = paths.length; _i < _len; _i++) {
            p = paths[_i];
            rmSync("" + path + "/" + p);
          }
        }
        return fs.rmdirSync(path);
      } else {
        return fs.unlinkSync(path);
      }
    }
  };

  touch = function(path, content, callback) {
    var _ref2;

    if (content == null) {
      content = '';
    }
    if (typeof content === 'function') {
      _ref2 = [callback, content], content = _ref2[0], callback = _ref2[1];
    }
    return exists(path, function(b) {
      if (b) {
        return typeof callback === "function" ? callback(null, false) : void 0;
      } else {
        return fs.writeFile(path, content, function(err) {
          if (err != null) {
            return typeof callback === "function" ? callback(err, false) : void 0;
          } else {
            return typeof callback === "function" ? callback(null, true) : void 0;
          }
        });
      }
    });
  };

  touchSync = function(path, content) {
    if (content == null) {
      content = '';
    }
    if (!existsSync(path)) {
      fs.writeFileSync(path, content);
      return true;
    }
    return false;
  };

  module.exports = {
    dirWithIndex: dirWithIndex,
    dirWithIndexSync: dirWithIndexSync,
    ensure: ensure,
    ensureSync: ensureSync,
    ensurePath: ensurePath,
    ensurePathSync: ensurePathSync,
    find: find,
    findSync: findSync,
    findBase: findBase,
    findBaseSync: findBaseSync,
    findSiblingFile: findSiblingFile,
    findSiblingFileSync: findSiblingFileSync,
    isNeatRoot: isNeatRoot,
    isNeatRootSync: isNeatRootSync,
    neatRoot: neatRoot,
    neatRootSync: neatRootSync,
    noExtension: noExtension,
    readFiles: readFiles,
    readFilesSync: readFilesSync,
    rm: rm,
    rmSync: rmSync,
    touch: touch,
    touchSync: touchSync
  };

}).call(this);
