{readFileSync} = require 'fs'
Neat = require 'neat'

{run, neatTask, asyncErrorTrap} = Neat.require 'utils/commands'
{error, info, green, red, puts} = Neat.require 'utils/logs'
{ensure, rm, find, readFiles} = Neat.require 'utils/files'
{read} = Neat.require 'utils/cup'

exports['package'] = neatTask
  name: 'package'
  description: 'Generates packages for this projects'
  environment: 'default'
  action: (callback) ->
    {dir, conf} = Neat.config.tasks.package
    rm dir, asyncErrorTrap ->
      ensure dir, asyncErrorTrap ->
        find 'cup', conf, asyncErrorTrap (files) ->
          readFiles files, (err, res) ->
            console.log read c for p,c of res

          callback?()
