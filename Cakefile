fs      = require 'fs'
{print} = require 'util'
{spawn} = require 'child_process'

try
  colors  = require 'colors'
catch e
  print """Can't find colors module

           Run cake install to install the dependencies.
           """

path    = require 'path'

option '-v', '--verbose', 'Enable verbose output mode'

NPM_TOKEN = '###_NPM_DECLARATION_###'
NPM_TEMPLATE = 'templates/commands/install.plain'
NEMFILE = 'Nemfile'
COFFEE = 'coffee'
NPM = 'npm'
JASMINE = './node_modules/.bin/jasmine-node'

green = (str) -> if str.green? then str.green else str
yellow = (str) -> if str.yellow? then str.yellow else str
red = (str) -> if str.red? then str.red else str

run = (command, options, callback) ->
  exe = spawn command, options
  exe.stdout.on 'data', (data) -> print data.toString()
  exe.stderr.on 'data', (data) -> print data.toString()
  exe.on 'exit', (status)-> callback? status

asyncFailureTrap = (callback) -> (err, args...) ->
  return print "#{err.stack}\n" if err?
  callback?.apply null, args

puts = (str) -> print "#{str}\n"

install = (options, callback) ->
  # The content of the `Nemfile` file is inserted in a placeholder in
  # the `templates/commands/install.plain` file that contains the `npm`
  # function declaration.

  fs.readFile NPM_TEMPLATE, asyncFailureTrap (nem) ->
    fs.readFile NEMFILE, asyncFailureTrap (nemfile) ->
      source = nem.toString().replace NPM_TOKEN, nemfile.toString()

      # The produced source code is then executed by `coffee`.
      run COFFEE, [ '-e', source ], ->
        puts green 'Neat dependencies installed'

deploy = (options, callback) ->
  [callback, options] = [options, {}] if typeof options is 'function'
  run NPM, ['install', '-g'], ->
    puts green 'Neat installed'
    callback?()

test = (options, callback) ->
  [callback, options] = [options, {}] if typeof options is 'function'

  unless path.existsSync JASMINE
    return puts """#{red "Can't find jasmine-node module"}

      Run #{yellow 'cake install'} to install the dependencies."""
  run JASMINE,
      ['.', '--color', '--coffee', '--test-dir', "#{__dirname}/test/spec"],
      callback

compile = (options, callback) ->
  [callback, options] = [options, {}] if typeof options is "function"

  run COFFEE, ['-c', '-o', 'lib', 'src'], (status)->
    # if err? then puts 'Compilation failed'.red
    # else
      # print output
    switch status
      when 0 then puts green 'Compilation done'
      when 1 then puts red 'Compilation failed'

    callback? status

recursiveWatch = (dir, watcher) ->
  fs.readdir dir, asyncFailureTrap (files)->
    files.forEach (file) ->
      file = path.resolve dir, file
      fs.lstat file, asyncFailureTrap (stats) ->
        if stats.isDirectory()
          # Watch the directory and traverse the child file.
          fs.watch file, watcher
          recursiveWatch file, watcher

compiling = false
watch = (options, callback) ->
  [callback, options] = [options, {}] if typeof options is 'function'
  recursiveWatch path.resolve('.', 'src'), (e, f) ->
    return if compiling
    compiling = true
    compile options, -> compiling = false

  callback?()

bump = (majorBump=0, minorBump=0, buildBump=1, options, callback) ->
  # The RegExp that match the module version declaration in both
  # the `.neat` file and the `package.json` file.
  re = ///
    ("?version"?): # Match the specific 'version' attribute
    \s*
    ["']{1}        # Version should be a string
    (\d+)\.        # Version has the form x.y.z
    (\d+)\.
    (\d+)
    ["']{1}        # String termination
  ///g

  # Used to store the new version from the `.neat` file to insert
  # in the `package.json` file.
  newVersion = null

  # That function generates a callback for a `readFile` call that
  # bump and then replace the version within the file's content.
  replaceVersion = (callback) -> (err, data) ->
    return callback? new Error "Can't find .neat file" if err?
    replaceFunc = (match, key, majv, minv, build) ->
      majv = parseInt(majv) + majorBump
      minv = parseInt(minv) + minorBump
      build = parseInt(build) + buildBump

      newVersion = "#{majv}.#{minv}.#{build}"
      "#{key}: \"#{newVersion}\""

    callback? null, data.toString().replace(re, replaceFunc)

  # Here starts the bumping
  fs.readFile ".neat", replaceVersion asyncFailureTrap (res) ->
    fs.writeFile ".neat", res, asyncFailureTrap ->

      unless path.existsSync 'package.json'
        return puts green "Version bumped to #{newVersion}"

      fs.readFile "package.json", asyncFailureTrap (data) ->
        output = data.toString().replace re, "\"version\": \"#{newVersion}\""

        fs.writeFile "package.json", output, asyncFailureTrap ->
          puts green "Version bumped to #{newVersion}"
          callback?()

task 'compile', 'Compiles the application',
      (opt) -> compile opt

task 'test',    'Tests Nails',
      (opt) -> compile opt, (e) -> test opt if e is 0

task 'deploy',  'Installs the application',
      (opt) -> bump 0, 0, 1, opt, -> compile opt, (e) -> deploy opt if e is 0

task 'install', 'Installs the application dependencies in the current project',
      (opt) -> install opt

task 'watch',   'Watches for changes in the src directory and run compile',
      (opt) -> watch opt

task 'bump',    'Bump version of the module',
      (opt) -> bump 0, 0, 1, opt
