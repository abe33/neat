@neat ||= {}
@neat.fixtures ||= {}

`/* #{file[0]} */`
# require should have been removed, but this comment is preserved

`/* #{file[1]} */`
@neat.fixtures.d = 0
@neat.fixtures['e'] = 1

exportsFunction = -> [ "exports", "module.exports" ]

`/* #{file[2]} */`
# Comments with exemple should be preserved
#
#     class Foo extends Map
#       get: (k) ->
`/* #{file[2]}<Map> line:5 */`
class Map
  `/* #{file[2]}<Map.static> line:6 */`
  @static: ->
  `/* #{file[2]}<Map::constructor> line:7 */`
  constructor: ->
  `/* #{file[2]}<Map::get> line:8 */`
  get: (k) ->
  `/* #{file[2]}<Map::set> line:9 */`
  set: (k,v) ->


@neat.fixtures.a = a
@neat.fixtures.b = b
@neat.fixtures.c = foo
@neat.fixtures.f = 10
@neat.fixtures.g = false
@neat.fixtures.h = 'foo'
@neat.fixtures.Image = Image
