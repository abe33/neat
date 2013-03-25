# Cup Files

Cup files are simple CoffeeScript code compiled and then evaluated with the
`eval` function.

For instance, in the exemple below, the cup string will be evaluated
as an object:

```
cup = Neat.require 'utils/cup'

source = """
firstName: 'Cédric'
lastName: 'Néhémie'
age: 31
"""

object = cup.read source
# object = {firstName: 'Cédric', lastName: 'Néhémie', age: 31}
```

Any CoffeeScript expression can be used as a cup content,
as long as it return a value. All the following forms are valid cup string:

An object literal:
```
firstName: 'Cédric'
lastName: 'Néhémie'
age: 31
```

A function declaration:
```
-> "Hello World"
```

A self-called function that return a value:
```
(->
  Faker = require 'Faker'

  Faker.Helpers.createCard() for i in [0..20]
)()
```
The only constraint is that the value must be returned synchronously.
