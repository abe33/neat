`/* foo.coffee */`
Generator = ->
  `/* foo.coffee<Foo> line:2 */`
  class Foo
    `/* foo.coffee<Foo.static> line:3 */`
    @static: ->
    `/* foo.coffee<Foo::constructor> line:4 */`
    constructor: ->
    `/* foo.coffee<Foo::method> line:5 */`
    method: ->
