fs = require 'fs'
path = require 'path'
Q = require 'q'
Neat = require '../neat'
{error, info, green, red, yellow, cyan, puts, print} = Neat.require 'utils/logs'
{run} = Neat.require 'utils/commands'

existsSync = fs.existsSync or path.existsSync

runOptions =
  stdout: (data) -> print data.toString()
  stderr: (data) -> print data.toString()

module.exports.compile = (match, options, block) -> ->
  defer = Q.defer()
  puts yellow "-- run cake compile"
  run 'cake', ['compile'], runOptions, (status) ->
    defer.resolve status
  defer.promise

module.exports.coffee = (match, options, block) -> ->
  defer = Q.defer()

  [p, file] = match
  if block?
    files = block p, file
  else
    file = file.split '/'
    file.pop()
    files = path.resolve Neat.root, 'lib', file.join '/'

  files ||= []
  files = [files] if typeof files is 'string'

  command = ['coffee', ['-co'].concat(files).concat(p)]
  puts yellow "-- run #{command.flatten().join ' '}"
  run.apply null, command.concat runOptions, (status) ->
    defer.resolve status

  defer.promise

module.exports.jasmine = (match, options, block) -> ->
  defer = Q.defer()

  [p, file] = match
  if block?
    files = block p, file
  else
    file = file.split '/'
    file.pop()
    files = path.resolve Neat.root, 'lib', file.join '/'

  files ||= []
  files = [files] if typeof files is 'string'
  files = files.select (f) -> existsSync f

  command = ['jasmine-node', ['--coffee', '--color'].concat(files)]
  unless files.empty()
    puts yellow "-- run #{command.flatten().join ' '}"
    run.apply null, command.concat runOptions, (status) ->
      defer.resolve status
  else
    puts yellow "-- no tests to run for #{p}"
    defer.resolve 0

  defer.promise

module.exports.lint = (match, options, block) -> ->

module.exports.manifest = (match, options, block) -> ->

