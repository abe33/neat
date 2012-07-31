require '../../../test_helper'
Neat = require '../../../../lib/neat'

withProject 'foo', 'when outside of a project', ->
  describe 'running `neat generate project foo`', ->
    beforeEach -> process.chdir FIXTURES_ROOT
    it 'should generates the neat manifest for the new project', ->
      path = inProject ".neat"
      expect(path).toExist()
      expect(path).toContain('name: "foo"')
      expect(path).toContain('version: "0.0.1"')
      expect(path).toContain('author: "John Doe"')
      expect(path).toContain('description: "a description"')
      expect(path).toContain('keywords: ["foo", "bar", "baz"]')

    it 'should generates a Nemfile depending on the current neat version', ->
      path = inProject "Nemfile"
      expect(path).toExist()
      expect(path).toContain("npm 'neat', '#{Neat.meta.version}'")

    it 'should generates a project in the current directory', ->
      expect(inProject ".gitignore").toExist()
      expect(inProject ".npmignore").toExist()
      expect(inProject "Cakefile").toExist()

      expect(inProject "src/tasks/.gitkeep").toExist()
      expect(inProject "src/commands/.gitkeep").toExist()
      expect(inProject "src/generators/.gitkeep").toExist()

      expect(inProject "src/config/initializers/.gitkeep").toExist()
      expect(inProject "src/config/environments/.gitkeep").toExist()

      expect(inProject "templates/.gitkeep").toExist()

      expect(inProject "test/test_helper.coffee").toExist()
      expect(inProject "test/units/.gitkeep").toExist()
      expect(inProject "test/functionals/.gitkeep").toExist()
      expect(inProject "test/integrations/.gitkeep").toExist()
      expect(inProject "test/fixtures/.gitkeep").toExist()
