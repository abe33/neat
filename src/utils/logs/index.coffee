# This file contains the logging utilities used accross Neat.
# Use this methods rather than `console.log` if you want your
# messages to be filtered by the environment.
#@toc

Logger = require './logger'

# In case the `colors` module can't be found - probably in the case
# you downloaded the neat repository and didn't run `cake install` yet -
# a message is displayed.
try
  colors = require 'colors'
catch e
  console.log """Can't find colors module

                 Run cake install to install the dependencies."""

# A logger instance is created at startup.
logger = new Logger

## Logging Utilities

#### Colorization

##### color

# The color function is used to prevent the colorization of a string
# to fail when the `colors` module can't be found.
color = (str, color) ->  if str[color]? then str[color] else str

##### blue

# Returns the passed-in string colorized in blue, if the `colors` module
# can't be found the string is returned unchanged.
blue    = (str) -> color str, 'blue'
##### cyan

# Returns the passed-in string colorized in cyan, if the `colors` module
# can't be found the string is returned unchanged.
cyan    = (str) -> color str, 'cyan'
##### green

# Returns the passed-in string colorized in green, if the `colors` module
# can't be found the string is returned unchanged.
green   = (str) -> color str, 'green'
##### inverse

# Returns the passed-in string colorized in inverse, if the `colors` module
# can't be found the string is returned unchanged.
inverse = (str) -> color str, 'inverse'
##### magenta

# Returns the passed-in string colorized in magenta, if the `colors` module
# can't be found the string is returned unchanged.
magenta = (str) -> color str, 'magenta'
##### red

# Returns the passed-in string colorized in red, if the `colors` module
# can't be found the string is returned unchanged.
red     = (str) -> color str, 'red'
##### yellow

# Returns the passed-in string colorized in yellow, if the `colors` module
# can't be found the string is returned unchanged.
yellow  = (str) -> color str, 'yellow'

#### Logging

##### puts

# Log a message that automatically end with a new line character.
puts = (str, level=0) -> logger.log "#{str}\n", level

##### print

# Log a message without automatic new line character at the end.
print = (str, level=0) -> logger.log str, level

##### prefix

# Prefix the passed-in string with the passed-in prefix.
prefix = (string, prefix) -> "#{prefix} #{string}"

##### fatal

# Log a message using the `puts` function and with a priority
# corresponding to the `Logger.FATAL` level.
fatal = (string) -> puts prefix(string, inverse red " FATAL "), Logger.FATAL

##### error

# Log a message using the `puts` function and with a priority
# corresponding to the `Logger.ERROR` level.
error = (string) -> puts prefix(string, inverse red " ERROR "), Logger.ERROR

##### warn

# Log a message using the `puts` function and with a priority
# corresponding to the `Logger.WARN` level.
warn  = (string) -> puts prefix(string, inverse yellow " WARN "), Logger.WARN

##### info

# Log a message using the `puts` function and with a priority
# corresponding to the `Logger.INFO` level.
info  = (string) -> puts prefix(string, inverse green " INFO "), Logger.INFO

##### debug

# Log a message using the `puts` function and with a priority
# corresponding to the `Logger.DEBUG` level.
debug = (string) -> puts prefix(string, inverse blue " DEBUG "), Logger.DEBUG

#### Other Utilities

##### missing

# Generates a message for a missing resources.
missing = (path) ->
  _ = require('../../neat').i18n.getHelper()
  red _('neat.errors.missing', missing: path)

##### notOutsideNeat

# Generates a messages for a neat command that can't run outside
# of a Neat project.
notOutsideNeat = (s) ->
  _ = require('../../neat').i18n.getHelper()
  red _('neat.errors.outside_neat', expression: s)

module.exports = {
  blue,
  cyan,
  debug,
  error,
  green,
  info,
  inverse,
  logger,
  magenta,
  missing,
  notOutsideNeat,
  prefix,
  print,
  puts,
  red,
  warn,
  yellow,
}
