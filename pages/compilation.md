# Compilation and Packaging

`Neat` is clearly opiniated and favor `CoffeeScript` over pure `JavaScript`.
As result, Neat provides tools to deal with compilation and packaging of
`coffee` files for both node and browsers.

These tools will allow you to perform operation on files at any point
of the process. And you can even easily build your own operators.

Most of the hard work is handled by the `cake package` task,
also aliased as `cake compile`. Basically, it takes a bunch
of compilation configuration files, loaded from the
`config/packages` directory, and process them.

@toc

## Package Configuration

Compilation configuration file are [cup files](cup.html) defining
the files to include in the package, in which order, and what to do with
them.

The default compilation configuration file (the one created for a new project)
look like that:

```
name: "myProject"
path: 'lib'
includes: [
  'src/**/*.coffee'
]
operators: [
  'path:change'
  'path:reset'
  'compile'
  'create:file'
]
```

The first property `name` is only used to define the final filename when using
the `join` operator, but is also useful as reminder.

The `path` property is an option for the `path:change` and `path:reset`
operators, it defines the relative path, inside the project, where place
the packaged files. By default the package tasks place output files in
the `packages` directory, this operator allow you to change that from
a configuration file.

The `includes` property is an array that contains
[`glob`](https://github.com/isaacs/node-glob) patterns of files to include
in the package. These files are read and then stored in a hash with the file
path as key and its content as value as returned by `fs.readFile`.
This `buffer` will be passed sequencially to the specified `operators`.

The `operators` property is an arrays containing the identifier of the
operators to apply to the packaged files. See below for the details about
operators.

## Custom Configuration

Neat provides a generator to create compilation configuration file, run :
```bash
neat generate config:packager my_package_name
```
And then a `my_package_name.cup` will have been generated
in the `config/packages` directory.

You can obviously create your configuration file by hand, just keep
in mind that the minimal requirement a compilation configuration need
to fullfil is to have the following properties:
```
includes: []
operators: []
```

## Operators

Operators are simple asynchronous function with the following signature:
```
my_operator = (buffer, config, errCallback, callback) ->
  # must return a buffer, config and errCallback in the callback for chaining.
  callback buffer, config, errCallback
```
Given the files that were found using the patterns in `includes`, an object
is created with the path of the file as key and its content as value.
This object is then passed to the first operator in the list and processed
all along the stack of operators.

Note that some operators return a buffer where all the paths was changed,
it means that the order of the operators will have an impact on their
utility. For instance the `annotate` operators may allways be placed
before a `join` or any other operator that changes the path or the content
of the file, if not, the files and line numbers present in the annotations
won't make sense.

The following operators are available from start at this time:

##### `annotate:class`
Annotates a class with comments for all its members.
The annotation appears as javascript comments wrapped in backticks.
```
`/* /path/to/file&lt;Class&gt: line: X */`
`/* /path/to/file&lt;Class.member&gt: line: X */`
`/* /path/to/file&lt;Class::member&gt: line: X */`
```
##### `annotate:file`
Annotates the files start with a header comment.
The annotation appears as javascript comments wrapped in backticks.
```
`/* /path/to/file */`
```
##### `compile`
Compiles the files in the buffer through CoffeeScript.
The extension in the file path is replaced with `.js`.
The `compile` operator accept a `bare` property which, when true,
compile the source without the wrapper function.

##### `create:file`
Creates the output files in their respectives path.
This operator can be called anytime, meaning you can, in one config,
produce and output a joined CoffeeScript file, then the compiled
javascript file, and then the minified Javascript file, below an example:
```
operators: [
  # ...
  'create:file' # create the coffee files
  'compile'
  'create:file' # create the js files
  'uglify'
  'create:file' # create the minified js files
]
```

##### `create:directory`
Creates a sub-directory of the packages folder defined with the `directory`
property. All the paths in the buffer will be changed to be included
in the path.
```
path: 'lib'
directory: 'demos'
operators: [
  # ...
  'create:directory' # creates the directory and change files path
  'create:file'      # creates the files at their new path
]
```
##### `exports:package`
Replaces all node exports as package affectation.
The operator require the definition of a package property in the
configuration such as :
```
package: 'path.to.package'
```
It will inject a package declaration at the top of each files in the buffer
such as:
```
@path ||= {}
@path.to ||= {}
@path.to.package ||= {}
```
Below is various use cases and their results:
```
# before
exports.a = -> #...
# after
@path.to.package.a = -> #...
```
```
# before
exports['a'] = -> #...
# after
@path.to.package['a'] = -> #...
```
```
# before
module.exports = {a,b,c: 10}
# after
@path.to.package.a = a
@path.to.package.b = b
@path.to.package.c = 10
```
```
# before
module.exports = MyClass
# after
@path.to.package.MyClass = MyClass
# When a variable name is affected as exports, the variable
# name is used as property name on the package. It's useful
# to have a class available as module in node and accessible
# through its name when stored in a package.
```

##### `header:license`
Insert the content of a license file as header comment in all generated
files. The license file is specfied in a `license` property
in the configuration file.

##### `join`
Joins all the files in the buffer in the order defined in
the include parameter and changes the filename with the specified
name parameter.

##### `path:change`
Changes the path of the files in the buffer with the path
defined in the path property.
For a file such `{root}/src/dir/file.coffee` and a path such as `lib`,
the resulting path will be `{root}/lib/dir/file.coffee`.
The `path` property is mandatory.

##### `path:reset`
Removes and then recreates the defined path.

##### `strip:requires`
Removes all the lines in a CoffeeScript file that
contain a call to `require`. Calls to `require` in comments are preserved.

##### `uglify`
Runs uglification on the buffer. The path of the files contained
in the buffer are then suffixed with `.min.js` rather than `.js`.

## Custom Operators

Operators are defined in the `operatorsMap` of the `tasks.package` config
namespace. To start creating your firsts operators generate a new initializer:

```bash
neat g initializer tasks/package/my_operators
```

Then you can start adding your own operators in the newly created initializer:
```
module.exports = (config) ->
  config.tasks.package.operatorsMap.merge
    my_operator: (buffers, config, errCallback, callback) ->
      for path, content of buffer
        buffer[path] = someOperationOn(content)
      callback buffers, config, errCallback
```
