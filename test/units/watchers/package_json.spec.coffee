require '../../test_helper'
Neat = require '../../../lib/neat'
{package_json: PackageJson} = Neat.require 'watchers/package_json'

describe 'PackageJson', ->
  subject 'plugin', -> new PackageJson

  it 'should exist', ->
    expect(@plugin).toBeDefined()

  describe 'when a file watched by the plugin changed', ->
    cliRunningPlugin(PackageJson)
    .should.run('neat', 'generate', 'package.json')
    .should.storeProcessAndKillIt()
    .should.bePendingUntilEnd()
