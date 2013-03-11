{readFileSync} = require 'fs'

Neat = require '../../neat'
Packager = require './packager'
op = require './operators'

{parallel} = Neat.require 'async'
{run, neatTask, asyncErrorTrap} = Neat.require 'utils/commands'
{error, info, green, red, puts, error} = Neat.require 'utils/logs'
{ensure, rm, find, readFiles} = Neat.require 'utils/files'
{read} = Neat.require 'utils/cup'
_ = Neat.i18n.getHelper()

exports['package'] = neatTask
  name: 'package'
  description: _('neat.tasks.package.description')
  environment: 'default'
  action: (callback) ->
    {dir, conf, tmp} = Neat.config.tasks.package

    err = -> callback? 1
    rm dir, asyncErrorTrap err, ->
      ensure dir, asyncErrorTrap err, ->
        find 'cup', conf, asyncErrorTrap err, (files) ->
          readFiles files, asyncErrorTrap err, (res) ->
            commands = (Packager.asCommand read(c), p for p,c of res)
            parallel commands, (res) ->
              failed = 0
              succeed = 0
              res.forEach (status) ->
                if status is 1
                  failed += 1
                  true
                else
                  succeed += 1
                  false

              if failed > 0
                error red _('neat.tasks.package.package_failed',
                            {succeed, failed})
                callback? 1
              else
                info green _('neat.tasks.package.packages_done',
                              packages: res.length)
                callback? 0
