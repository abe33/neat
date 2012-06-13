require './object'
require './string'
require './number'
require './array'
mod = require './module'
mix = require './mixin'

module.exports =
  Module: mod.Module
  Mixin: mix.Mixin
