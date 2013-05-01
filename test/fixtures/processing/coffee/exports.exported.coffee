@path ||= {}
@path.to ||= {}
@path.to.package ||= {}

@path.to.package.foo = ->
@path.to.package['foo'] = ->

@path.to.package.foo = foo
@path.to.package.bar = bar
@path.to.package.foo = 'bar'
@path.to.package.bar = 'foo'
@path.to.package.Foo = Foo
