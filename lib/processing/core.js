(function() {
  var Neat, Q, exists, fs, parallel, path, processExtension, readFiles, utils, writeFiles;

  fs = require('fs');

  path = require('path');

  Q = require('q');

  Neat = require('../neat');

  utils = Neat.require('utils/files');

  parallel = Neat.require('async').parallel;

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
    defer = Q.defer();
    error = null;
    gen = function(p, content) {
      return function(callback) {
        var dir;
        dir = path.resolve(p, '..');
        return utils.ensurePath(dir, function(err) {
          return fs.writeFile(p, content, function(err) {
            if (err != null) {
              error = err;
            }
            return typeof callback === "function" ? callback() : void 0;
          });
        });
      };
    };
    parallel((function() {
      var _results;
      _results = [];
      for (k in buffer) {
        v = buffer[k];
        _results.push(gen(k, v));
      }
      return _results;
    })(), function() {
      if (error != null) {
        return defer.reject(error);
      }
      return defer.resolve(buffer);
    });
    return defer.promise;
  };

  processExtension = function(ext, process) {
    return function(buffer) {
      var defer, filteredBuffer, k;
      defer = Q.defer();
      filteredBuffer = buffer.select(function(k) {
        return path.extname(k) === ("." + ext);
      });
      for (k in filteredBuffer) {
        buffer.destroy(k);
      }
      process(filteredBuffer).then(function(processedBuffer) {
        return defer.resolve(buffer.merge(processedBuffer));
      }).fail(function(err) {
        return defer.reject(err);
      });
      return defer.promise;
    };
  };

  module.exports = {
    readFiles: readFiles,
    writeFiles: writeFiles,
    processExtension: processExtension
  };

}).call(this);
