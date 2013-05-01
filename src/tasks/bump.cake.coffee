fs = require 'fs'
path = require 'path'
Neat = require '../neat'
{namespace} = Neat.require 'utils/exports'
{run, neatTask, asyncErrorTrap} = Neat.require 'utils/commands'
{error, info, green, red, puts} = Neat.require 'utils/logs'
_ = Neat.i18n.getHelper()

existsSync = fs.existsSync or path.existsSync

bump = (majorBump=0, minorBump=0, buildBump=1, callback) ->
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
  replaceVersion = (cb) -> (err, data) ->
    return cb? new Error _('neat.tasks.bump.no_neat') if err?
    replaceFunc = (match, key, majv, minv, build) ->
      build = parseInt(build) + buildBump

      # Bumping the minor version reset the build to 0.
      minv = parseInt(minv)
      if minorBump isnt 0
        build = 0
        minv += minorBump

      # Bumping the major version reset both the build
      # and the minor version to 0.
      majv = parseInt(majv)
      if majorBump isnt 0
        build = 0
        minv = 0
        majv += majorBump

      newVersion = "#{majv}.#{minv}.#{build}"
      "#{key}: \"#{newVersion}\""

    cb? null, data.toString().replace(re, replaceFunc)

  err = -> callback? 1

  # Here starts the bumping
  fs.readFile ".neat", replaceVersion asyncErrorTrap err, (res) ->
    fs.writeFile ".neat", res, asyncErrorTrap err, ->

      unless existsSync 'package.json'
        info green _('neat.tasks.bump.version_bumped', version: newVersion)
        return callback? 0

      fs.readFile "package.json", asyncErrorTrap err, (data) ->
        output = data.toString().replace re, "\"version\": \"#{newVersion}\""

        fs.writeFile "package.json", output, asyncErrorTrap err, ->
          info green _('neat.tasks.bump.version_bumped', version: newVersion)
          callback? 0

module.exports = namespace 'bump',
  index:  neatTask
    name:'bump'
    description: _('neat.tasks.bump.description')
    action: (callback) -> bump 0, 0, 1, callback
  minor: neatTask
    name:'bump:minor'
    description: _('neat.tasks.bump.minor_description')
    action: (callback) -> bump 0, 1, 0, callback
  major: neatTask
    name:'bump:major'
    description: _('neat.tasks.bump.major_description')
    action: (callback) -> bump 1, 0, 0, callback
