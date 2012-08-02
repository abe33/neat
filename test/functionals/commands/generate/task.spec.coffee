require '../../../test_helper'
Neat = require '../../../../lib/neat'
{run} = require '../../../../lib/utils/commands'

withProject 'foo', ->
  describe 'running `neat generate task foo`', ->
    it 'should generate a new task foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'task', 'foo'], (status) ->
        expect(inProject "src/tasks/foo.cake.coffee").toExist()

        done()

    it 'should defines the properties of the task according
        to the hash arguments provided'.squeeze(), (done) ->
      args = [
        NEAT_BIN,
        'generate',
        'task',
        'foo',
        'description:"a description"',
        'environment:production',
      ]
      run 'node', args, (status) ->
        path = inProject "src/tasks/foo.cake.coffee"
        expect(path).toContain("exports['foo'] = neatTask")
        expect(path).toContain("name: 'foo'")
        expect(path).toContain("description: 'a description'")
        expect(path).toContain("environment: 'production'")
        done()


  describe 'running `neat generate task bar/foo`', ->
    it 'should generate a new task foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'task', 'bar/foo'], (status) ->
        expect(inProject "src/tasks/bar/foo.cake.coffee").toExist()

        done()
