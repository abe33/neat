
module.exports = (config) ->
  config.tasks.compile =
    coffee: "#{config.neatRoot}/node_modules/.bin/coffee"
    src: "#{config.root}/src"
    lib: "#{config.root}/lib"
    args: ['-c', '-o', "#{config.root}/lib", "#{config.root}/src"]
