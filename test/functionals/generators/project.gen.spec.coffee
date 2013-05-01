require '../../test_helper'
Neat = require '../../../lib/neat'

{run} = Neat.require 'utils/commands'
{print} = require 'util'

describe 'when outside a project', ->
  beforeEach -> process.chdir TEST_TMP_DIR

  describe 'running `neat generate project`', ->
    it "should return a status of 1 and don't generate anything", (done) ->
      # options =
      #   stderr: (data)-> print data
      #   stdout: (data)-> print data
      run 'node', [NEAT_BIN, 'generate', 'project'], (status) ->
        expect(status).toBe(1)
        done()

withProject 'neat_project', 'when outside a project', ->
  describe 'running `neat generate project foo`', ->
    beforeEach -> process.chdir TEST_TMP_DIR

    it 'should return a status code of 0', ->
      expect(@status).toBe(0)

    it 'should generates the neat manifest for the new project', ->
      path = inProject ".neat"
      expect(path).toExist()
      expect(path).toContain('name: "neat_project"')
      expect(path).toContain('version: "0.0.1"')
      expect(path).toContain('author: "John Doe"')
      expect(path).toContain('description: "a description"')
      expect(path).toContain('keywords: ["foo", "bar", "baz"]')

    it 'should generates a Nemfile depending on the current neat version', ->
      path = inProject "Nemfile"
      expect(path).toExist()
      expect(path).toContain("npm 'neat', '#{Neat.meta.version}'")

    it 'should generates a configuration file for default environment', ->
      path = inProject "src/config/environments/default.coffee"
      expect(path).toExist()
      expect(path).toContain('module.exports = (config) ->')

    it 'should generates a configuration file for test environment', ->
      path = inProject "src/config/environments/test.coffee"
      expect(path).toExist()
      expect(path).toContain('module.exports = (config) ->')

    it 'should generates a configuration file for development environment', ->
      path = inProject "src/config/environments/development.coffee"
      expect(path).toExist()
      expect(path).toContain('module.exports = (config) ->')

    it 'should generates a configuration file for production environment', ->
      path = inProject "src/config/environments/production.coffee"
      expect(path).toExist()
      expect(path).toContain('module.exports = (config) ->')

    it 'should generates a project in the current directory', ->
      expect(inProject ".gitignore").toExist()
      expect(inProject ".npmignore").toExist()

      expect(inProject "src/tasks/.gitkeep").toExist()
      expect(inProject "src/commands/.gitkeep").toExist()
      expect(inProject "src/generators/.gitkeep").toExist()

      expect(inProject "src/config/initializers/.gitkeep").toExist()

      expect(inProject "templates/.gitkeep").toExist()

      expect(inProject "test/test_helper.coffee").toExist()
      expect(inProject "test/units/.gitkeep").toExist()
      expect(inProject "test/helpers/.gitkeep").toExist()
      expect(inProject "test/functionals/.gitkeep").toExist()
      expect(inProject "test/integrations/.gitkeep").toExist()
      expect(inProject "test/fixtures/.gitkeep").toExist()

      expect(inProject "config").not.toExist()
      expect(inProject "config/packages").not.toExist()
      expect(inProject "config/packages/compile.cup").not.toExist()

      expect(inProject "Cakefile")
      .toContain(loadFixture 'generators/project/Cakefile')

      expect(inProject "Neatfile")
      .toContain(loadFixture 'generators/project/Neatfile')

      expect(inProject "Watchfile")
      .toContain(loadFixture 'generators/project/Watchfile')




