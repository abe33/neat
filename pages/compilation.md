# Compilation and Packaging

`Neat` is clearly opiniated and favor `CoffeeScript` over pure `JavaScript`.
As result, Neat provides tools to deal with compilation and packaging of
`coffee` files for both node and browsers.

These tools will allow you to perform operation on files at any point
of the process. And you can even easily build your own operators.

Most of the hard work is handled by the `cake build` task,
also aliased as `cake compile`. Builds are defined in the project `Neatfile`.

@toc

## Neatfile

Every Neat project have a `Neatfile` at its root. The `Neatfile` describes
the build process to operate for a project.

The default `Neatfile` look like this:

```
build 'lib', (build) ->
  # Use glob like expression to source the build
  build.source 'src/**/*.coffee'

  # Invoke the processors you need
  build
  .do(compile bare: false)      # compile all the files
  .then(remove 'lib')           # removes the lib directory
  .then(relocate 'src', 'lib')  # relocate the compiled file to lib
  .then(writeFiles)             # write files to their path
```

The `build` call initiate a new build with the name `lib`. The build is then
passed as argument to the block.

The `build.source` method allow to defines the patterns for files to process
in this build. As for the example, all the files with a coffee extension
will be processed by the build.

The `build.do` and `build.then` add operations in the build stack.
Each of these operation will be executed sequentially, passing from one
to another their results.

### Build Operators

Operators are promise that operates on a file buffer. A file buffer
is a simple object where keys contains the file's path and values are
the content of these files. Such as

```
buffer = {
  '/path/to/file_1': 'Content file 1'
  '/path/to/file_2': 'Content file 2'
}
```

The following operators are currently available:

**Note:** Some processors requires a configuration, they'll be listed with
their arguments in the list below such as `compile(options)`. Processors
that don't needs arguments must be passed direcly without calling them.

#### Common

  * `fileFooter(footer)`: Appends the given `footer` to each files in the
    buffer.

  * `fileHeader(header)`: Prepends the given `header` to each files in the
    buffer.

    Given a file `templates/LICENSE` containing:
    ```javascript
    /*
     * This is the license file.
     */
    ```

    You can prepend it to all files in the build with:
    ```
    build.do(fileHeader load 'templates/LICENSE')
    ```
  * `join(filename)`: Joins all the files in the buffer into a single file
    whose path is `filename`.
  * `processExtension(ext, process)`: Performs operations on files that matches
    the passed-in extension. The `process` argument is a promise returning
    function that takes a promise whose value is a filtered buffer.
    The function must return a promise whose value is a buffer as well.
    ```
    build 'documentation', (build) ->
      build.source 'src/**/*.coffee'
      build.source 'src/**/*.js'
      build.source 'templates/**/*.html'

      build
      .do(remove 'docs')
      .then(processExtension 'coffee', (unit) ->
        unit.then(compile bare: true)

      ).then(processExtension 'js', (unit) ->
        unit
        .then(uglify)
        .then(fileHeader load 'templates/LICENSE')
        .then(relocate 'src', 'docs/js')

      ).then(processExtension 'html', (unit) ->
        unit.then(relocate 'templates', 'docs')

      ).then(writeFiles)

    ```
  * `readFiles(paths)`: Loads the specified files and return a files buffer.
    This processor is automatically added at the build start provides the
    buffer containing all the files matching the patterns defined with the
    `build.source` method.
  * `relocate(from, to)`: Replace the `from` pattern with the `to` pattern
    in the files paths.
  * `remove(path)`: Removes the given path.
  * `writeFiles`: Writes all the files in the buffer at their respective
    path. Missing directories are created.

    The processor can be placed severla time in the processing stack.
    For instance you can write the files berfore and minification it will
    give you files with `min.js` extension for the minified versions.

#### CoffeeSCript

  * `annotate`: Add JavaScript annotation comments in the coffee script files.
    The results looks as:
    ```
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
    ```
  * `compile(options)`: Compiles the files in the buffer through the
    the CoffeeScript compiler and change the path extension from `coffee`
    to `js`.
  * `exportsToPackage(package)`: Replace the module exports of nodejs code
    with a packaged version.

    For instance:
    ```
    build.do(exportsToPackage 'path.to.package')
    ```
    Will prepend the following snippet in all files:
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

  * `stripRequires`: Removes all lines that contains a call to `require`.

#### JavaScript

  * `uglify`: Minify the javascripts file through `uglify-js` and changes
    the file extension from `js` to `min.js`.

### Build Utilities

  * `load`: Loads the given file from the project root and returns its
    content as a string.

### Custom Build Operators

Custom build operators should be placed in the `lib/processing` directory.

#### Without Configuration

```
myCustomOperator = (buffer) ->
  # Either return a new buffer synchronously
  # or a promise whose value is a buffer
```

#### With Configuration

```
myCustomOperator = (args...) ->
  # The operator function returns a promise returning function
  # taking the buffer as argument.

  return (buffer) ->
    # Either return a new buffer synchronously
    # or a promise whose value is a buffer
```

