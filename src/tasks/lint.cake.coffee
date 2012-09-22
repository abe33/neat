path = require 'path'
Neat = require '../neat'
{run, neatTask, asyncErrorTrap} = Neat.require 'utils/commands'
{
  error, info, green, red, puts, print, yellow, missing
} = Neat.require 'utils/logs'
{find, findSiblingFile} = Neat.require 'utils/files'
{queue} = Neat.require 'async'
_ = Neat.i18n.getHelper()

COFFEE_LINT = "#{Neat.neatRoot}/node_modules/.bin/coffeelint"

exports['lint'] = neatTask
  name:'lint'
  description: _('neat.tasks.lint.description')
  environment: 'default'
  action: (callback) ->
    unless path.existsSync COFFEE_LINT
      error _('neat.errors.missing_module', missing: missing 'coffeelint')
      return callback?()

    path = __filename
    dir = 'config'
    findSiblingFile path, Neat.paths, dir, 'json', asyncErrorTrap (conf) ->
      unless conf?
        error missing "config/tasks/lint.json"
        return callback?()

      errors = []
      allfiles = 0
      linted = 0
      failed = 0
      allerrors = 0
      # Generates a command function that lint the specified `file`.
      lint = (file) -> (callback) ->
        allfiles += 1
        params = ["-f", conf, file]

        logs = []
        opts =
          noStdout: true
          stderr: (data) -> logs.push -> print data

        run 'coffeelint', params, opts, (status) ->
          if status is 0
            print green '.'
            linted += 1
          else
            print red 'F'
            failed += 1
            errors.push ->
              puts red _('neat.tasks.lint.lint_error',
                         file: file.replace "#{Neat.root}/", ''), 3
              allerrors += logs.length
              log() for log in logs

          callback?()

      paths = ["#{Neat.root}/src", "#{Neat.root}/test"]

      files = find 'coffee', paths, (err, files) ->
        queue (lint file for file in files), ->
          puts ''

          if errors.length is 0
            info green _('neat.tasks.lint.files_linted', files: allfiles)
          else
            error() for error in errors

            puts "\n
                  #{allfiles} files,
                  #{green "#{linted} linted"},
                  #{red "#{failed} failed"},
                  #{red "#{allerrors} error#{'s' if allerrors > 0}"}
                 ".squeeze()

          callback?()
