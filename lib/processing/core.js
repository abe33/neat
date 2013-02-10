(function() {
  var Neat, Q, exists, fs, path, readFiles, utils;

  fs = require('fs');

  path = require('path');

  Q = require('q');

  Neat = require('../neat');

  utils = Neat.require('utils/files');

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

  module.exports = {
    readFiles: readFiles
  };

}).call(this);
