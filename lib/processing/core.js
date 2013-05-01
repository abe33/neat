(function() {
  var Neat, Q, check, checkBuffer, exists, fileFooter, fileHeader, fs, join, parallel, path, processExtension, queue, readFiles, relocate, remove, utils, writeFiles, _ref, _ref1;

  fs = require('fs');

  path = require('path');

  Q = require('q');

  Neat = require('../neat');

  utils = Neat.require('utils/files');

  _ref = Neat.require('async'), parallel = _ref.parallel, queue = _ref.queue;

  _ref1 = require('./utils'), check = _ref1.check, checkBuffer = _ref1.checkBuffer;

  exists = fs.exists || path.exists;

  readFiles = function(paths) {
    var defer;

    defer = Q.defer();
    utils.readFiles(paths, function(err, res) {
      if (err != null) {
        return defer.reject(err);
      }
      return defer.resolve(res);
    });
    return defer.promise;
  };

  writeFiles = function(buffer) {
    var defer, error, gen, k, v;

    checkBuffer(buffer);
    defer = Q.defer();
    error = null;
    gen = function(p, content) {
      return function(callback) {
        var dir;

        dir = path.resolve(p, '..');
        return utils.ensurePath(dir, function(err) {
          if (err != null) {
            return defer.reject(err);
          }
          return fs.writeFile(p, content, function(err) {
            if (err != null) {
              return defer.reject(err);
            }
            return typeof callback === "function" ? callback() : void 0;
          });
        });
      };
    };
    queue((function() {
      var _results;

      _results = [];
      for (k in buffer) {
        v = buffer[k];
        _results.push(gen(k, v));
      }
      return _results;
    })(), function() {
      return defer.resolve(buffer);
    });
    return defer.promise;
  };

  processExtension = function(ext, process) {
    check(ext, 'Extension argument is mandatory');
    check(process, 'Function argument is mandatory');
    return function(buffer) {
      var defer, filteredBuffer, k;

      checkBuffer(buffer);
      defer = Q.defer();
      filteredBuffer = buffer.select(function(k) {
        return path.extname(k) === ("." + ext);
      });
      for (k in filteredBuffer) {
        buffer.destroy(k);
      }
      process(Q.fcall(function() {
        return filteredBuffer;
      })).then(function(processedBuffer) {
        return defer.resolve(buffer.merge(processedBuffer));
      }).fail(function(err) {
        return defer.reject(err);
      });
      return defer.promise;
    };
  };

  join = function(fileName) {
    check(fileName, 'File name argument is mandatory');
    return function(buffer) {
      checkBuffer(buffer);
      return Q.fcall(function() {
        var k, newBuffer, newContent, v;

        newBuffer = {};
        newContent = [];
        for (k in buffer) {
          v = buffer[k];
          newContent.push(v);
        }
        newBuffer[fileName] = newContent.join('\n');
        return newBuffer;
      });
    };
  };

  relocate = function(from, to) {
    check(from, 'From argument is mandatory');
    check(to, 'To argument is mandatory');
    return function(buffer) {
      checkBuffer(buffer);
      return Q.fcall(function() {
        var content, newBuffer, newPath, p;

        newBuffer = {};
        for (p in buffer) {
          content = buffer[p];
          newPath = p.replace(from, to);
          newBuffer[newPath] = content;
        }
        return newBuffer;
      });
    };
  };

  remove = function(path) {
    check(path, 'Path argument is mandatory');
    return function(buffer) {
      var defer;

      checkBuffer(buffer);
      defer = Q.defer();
      utils.rm(Neat.rootResolve(path), function(err) {
        if (err != null) {
          return defer.reject(err);
        }
        return defer.resolve(buffer);
      });
      return defer.promise;
    };
  };

  fileHeader = function(header) {
    check(header, 'Header argument is mandatory');
    return function(buffer) {
      checkBuffer(buffer);
      return Q.fcall(function() {
        var content, file, newBuffer;

        newBuffer = {};
        for (file in buffer) {
          content = buffer[file];
          newBuffer[file] = "" + header + "\n" + content;
        }
        return newBuffer;
      });
    };
  };

  fileFooter = function(footer) {
    check(footer, 'Footer argument is mandatory');
    return function(buffer) {
      checkBuffer(buffer);
      return Q.fcall(function() {
        var content, file, newBuffer;

        newBuffer = {};
        for (file in buffer) {
          content = buffer[file];
          newBuffer[file] = "" + content + "\n" + footer + "\n";
        }
        return newBuffer;
      });
    };
  };

  module.exports = {
    readFiles: readFiles,
    writeFiles: writeFiles,
    processExtension: processExtension,
    join: join,
    fileHeader: fileHeader,
    fileFooter: fileFooter,
    relocate: relocate,
    remove: remove
  };

}).call(this);
