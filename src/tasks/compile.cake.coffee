Neat = require '../neat'
{run, neatTaskAlias} = require '../utils/commands'
{error, info, green, red} = require '../utils/logs'
{rm} = require '../utils/files'
_ = Neat.i18n.getHelper()

exports.compile = neatTaskAlias 'build', 'compile', 'production'
