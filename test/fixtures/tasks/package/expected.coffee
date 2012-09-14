@neat ||= {}
@neat.fixtures ||= {}

`// #{file[0]}`
# require should have been removed, but this comment is preserved

`// #{file[1]}`
@neat.fixtures.d = 0
@neat.fixtures['e'] = 1

exportsFunction = -> [ "exports", "module.exports" ]

@neat.fixtures.a = a
@neat.fixtures.b = b
@neat.fixtures.c = foo
@neat.fixtures.f = 10
@neat.fixtures.g = false
@neat.fixtures.h = 'foo'
@neat.fixtures.Image = Image
