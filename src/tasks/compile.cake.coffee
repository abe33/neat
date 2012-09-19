Neat = require '../neat'
{run, neatTask} = require '../utils/commands'
{error, info, green, red} = require '../utils/logs'
{rm} = require '../utils/files'
_ = Neat.i18n.getHelper()

exports.compile = neatTask
  name:'compile'
  description: 'Compiles the sources'
  action: (callback) ->
    Neat.beforeCompilation.dispatch ->
      {coffee, args, lib} = Neat.config.tasks.compile
      rm lib, (err) ->
        run coffee, args, (status) ->

          if status is 0
            info green _('neat.messages.tasks.compile.compilation_done')
          else
            error red _('neat.messages.tasks.compile.compilation_failed')

          Neat.afterCompilation.dispatch ->
            callback? status
