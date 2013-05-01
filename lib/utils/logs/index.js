(function() {
  var Logger, blue, color, colors, cyan, debug, e, error, fatal, green, info, inverse, logger, magenta, missing, notOutsideNeat, prefix, print, puts, red, warn, yellow;

  Logger = require('./logger');

  try {
    colors = require('colors');
  } catch (_error) {
    e = _error;
    console.log("Can't find colors module\n\nRun cake install to install the dependencies.");
  }

  logger = new Logger;

  color = function(str, color) {
    if (str[color] != null) {
      return str[color];
    } else {
      return str;
    }
  };

  blue = function(str) {
    return color(str, 'blue');
  };

  cyan = function(str) {
    return color(str, 'cyan');
  };

  green = function(str) {
    return color(str, 'green');
  };

  inverse = function(str) {
    return color(str, 'inverse');
  };

  magenta = function(str) {
    return color(str, 'magenta');
  };

  red = function(str) {
    return color(str, 'red');
  };

  yellow = function(str) {
    return color(str, 'yellow');
  };

  puts = function(str, level) {
    if (level == null) {
      level = 0;
    }
    return logger.log("" + str + "\n", level);
  };

  print = function(str, level) {
    if (level == null) {
      level = 0;
    }
    return logger.log(str, level);
  };

  prefix = function(string, prefix) {
    return "" + prefix + " " + string;
  };

  fatal = function(string) {
    return puts(prefix(string, inverse(red(" FATAL "))), Logger.FATAL);
  };

  error = function(string) {
    return puts(prefix(string, inverse(red(" ERROR "))), Logger.ERROR);
  };

  warn = function(string) {
    return puts(prefix(string, inverse(yellow(" WARN "))), Logger.WARN);
  };

  info = function(string) {
    return puts(prefix(string, inverse(green(" INFO "))), Logger.INFO);
  };

  debug = function(string) {
    return puts(prefix(string, inverse(blue(" DEBUG "))), Logger.DEBUG);
  };

  missing = function(path) {
    var _;

    _ = require('../../neat').i18n.getHelper();
    return red(_('neat.errors.missing', {
      missing: path
    }));
  };

  notOutsideNeat = function(s) {
    var _;

    _ = require('../../neat').i18n.getHelper();
    return red(_('neat.errors.outside_neat', {
      expression: s
    }));
  };

  module.exports = {
    blue: blue,
    cyan: cyan,
    debug: debug,
    error: error,
    green: green,
    info: info,
    inverse: inverse,
    logger: logger,
    magenta: magenta,
    missing: missing,
    notOutsideNeat: notOutsideNeat,
    prefix: prefix,
    print: print,
    puts: puts,
    red: red,
    warn: warn,
    yellow: yellow
  };

}).call(this);
