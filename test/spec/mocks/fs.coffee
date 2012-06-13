generator = (fileSystem) ->

  mkdirSync = (path, mode) -> fileSystem.mkdirSync path
  mkdir = (path, mode, callback) ->
    [callback, mode] = [mode, null] if typeof mode is "function"
    try
      fileSystem.mkdir path
      callback?()
    catch e
      callback? e

  readdirSync = (path) ->
    o = fileSystem.read path
    throw new Error "#{path} isn't a directory" if typeof o isnt "object"
    o
  readdir = (path, callback) ->
    try
      o = fileSystem.read path
      throw new Error "#{path} isn't a directory" if typeof o isnt 'object'
      callback? o
    catch e
      callback? e

  readFileSync = (path) ->
    o = fileSystem.read path
    throw new Error "#{path} is a directory" if typeof o is 'object'
    o
  readFile = (path, callback) ->
    try
      o = fileSystem.read path
      throw new Error "#{path} is a directory" if typeof o is 'object'
      callback? o
    catch e
      callback? e

  writeFileSync = (path, content) ->
    fileSystem.write path, content

  writeFile = (path, mode, callback) ->
    try
      fileSystem.write path, content
      callback?()
    catch e
      callback? e


  {
    mkdirSync,
    mkdir,
    readdir,
    readdirSync,
    readFile,
    readFileSync,
    writeFile,
    writeFileSync,
  }

module.exports = generator
