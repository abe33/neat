Signal = require '../core/signal'
Logger = require './logger'

try
  colors = require 'colors'
catch e
  console.log """Can't find colors module

                 Run cake install to install the dependencies."""


logger = new Logger

color = (str, color) ->  if str[color]? then str[color] else str

blue    = (str) -> color str, 'blue'
cyan    = (str) -> color str, 'cyan'
green   = (str) -> color str, 'green'
inverse = (str) -> color str, 'inverse'
magenta = (str) -> color str, 'magenta'
red     = (str) -> color str, 'red'
yellow  = (str) -> color str, 'yellow'

puts = (str, level=0) -> logger.log "#{str}\n", level
print = (str, level=0) -> logger.log str, level

prefix = (string, prefix) -> "#{prefix} #{string}"

error = (string) -> prefix string, inverse red " ERROR "
warn  = (string) -> prefix string, inverse yellow " WARN "
info  = (string) -> prefix string, inverse green " INFO "
debug = (string) -> prefix string, inverse blue " DEBUG "

missing = (path) -> error red "#{path} can't be found."

neatBroken = "Your Neat installation is probably broken."
notOutsideNeat = (s) -> error red "Can't run #{s} outside of a Neat project."

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
  neatBroken,
  notOutsideNeat,
  prefix,
  print,
  puts,
  red,
  warn,
  yellow,
}
