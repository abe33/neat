fs = require 'fs'
{relative, resolve} = require 'path'
{exec} = require 'child_process'

Neat = require '../neat'
{parallel} = Neat.require 'async'
{neatTask, asyncErrorTrap} = Neat.require 'utils/commands'
{error, info, green, red, puts} = Neat.require 'utils/logs'
{find, ensurePath, readFiles, findSiblingFileSync} = Neat.require 'utils/files'
cup = Neat.require 'utils/cup'
t = Neat.i18n.getHelper()

try
  Q = require 'q'
catch e
  return error t('neat.errors.missing_module',
                  missing: missing 'q')

try
  {highlight} = require 'highlight.js'
catch e
  return error t('neat.errors.missing_module',
                  missing: missing 'highlight')

try
  marked = require 'marked'
catch e
  return error t('neat.errors.missing_module',
                  missing: missing 'marked')

PAGES_DIR = "#{Neat.root}/pages"
PAGES_TEMP_DIR = "#{Neat.root}/.pages"
CONFIG = "#{Neat.root}/config/pages.cup"
TASK_DIR = "#{Neat.neatRoot}/src/tasks/github/pages"

marked.setOptions
  gfm: true
  pedantic: false
  sanitize: false
  highlight: (code, lang) ->
    highlight(lang or 'coffeescript', code).value

run = (command) ->
  defer = Q.defer()
  exec command, (err, stdout, stderr) ->
    if err? then defer.reject(stderr) else defer.resolve(stdout)
  defer.promise

getGitInfo = ->
  o = {}
  run('git status')
  .then (status) ->
    o.branch = currentBranch status
    o.status = status
    run('git branch')
  .then (branches) ->
    o.branches = branches.split('\n').map (b) -> b[2..]
    o

checkGitStatus = (status) ->
  if hasUnstagedChanges status
    throw new Error t 'neat.tasks.github_pages.unstaged_changes'

  if hasUntrackedFile status
    throw new Error t 'neat.tasks.github_pages.untracked_files'

read = (files) ->
  defer = Q.defer()
  readFiles files, (err, buf) ->
    if err? then defer.reject(err) else defer.resolve(buf)
  defer.promise

loadConfig = ->
  defer = Q.defer()
  fs.readFile CONFIG, (err, conf) ->
    if err?
      defer.reject(err)
    else
      defer.resolve(cup.read conf.toString())
  defer.promise

createTempDir = ->
  defer = Q.defer()
  ensurePath PAGES_TEMP_DIR, (err, created) ->
    if err? then defer.reject(err) else defer.resolve(created)
  defer.promise

findMarkdownFiles = ->
  defer = Q.defer()
  find 'md', [PAGES_DIR], (err, files) ->
    if err? then defer.reject(err) else defer.resolve(files)
  defer.promise

compileStylus = ->
  defer = Q.defer()
  gen = (path, content) -> (callback) ->
    if err? then return (defer.reject(err); callback?())

    fs.readFile path, (err, content) ->
      if err? then return (defer.reject(err); callback?())

      css = Neat.config.engines.templates.stylus.render content.toString()
      path = path.replace(PAGES_DIR, PAGES_TEMP_DIR).replace('stylus', 'css')

      fs.writeFile path, css, (err) ->
        if err? then return (defer.reject(err); callback?())

        callback?()

  find 'stylus', [PAGES_DIR], (err, files) ->
    parallel (gen file for file in files), ->
      defer.resolve()

  defer.promise

writeFiles = (files) ->
  defer = Q.defer()
  gen = (path, content) -> (callback) ->
    dir = resolve path, '..'
    ensurePath dir, (err) ->
      fs.writeFile path, content, (err) ->
        if err then defer.reject(err)
        callback?()

  parallel (gen k,v for k,v of files), ->
    defer.resolve()

  defer.promise

findTitle = (content) ->
  res = /<h1>(.*)<\/h1>/g.exec content
  res?[1] or ''

applyLayout = (files) ->
  loadConfig()
  .then (config) ->
    hamlc = Neat.config.engines.templates.hamlc.render

    rfs = fs.readFileSync
    fsf = findSiblingFileSync

    paths = Neat.paths

    header = rfs fsf "#{TASK_DIR}/_header", paths, 'templates', 'hamlc'
    footer = rfs fsf "#{TASK_DIR}/_footer", paths, 'templates', 'hamlc'
    navigation = rfs fsf "#{TASK_DIR}/_navigation", paths, 'templates', 'hamlc'
    layout = rfs fsf "#{TASK_DIR}/layout", paths, 'templates', 'hamlc'

    newFiles = {}
    for path,content of files
      dir = resolve path, '..'
      newFiles[path] = hamlc layout.toString(), {
        Neat
        dir
        path
        relative
          config
        title: "#{Neat.project.name} - #{findTitle content}"
        header: hamlc header.toString(), {Neat, dir, path, relative, config}
        footer: hamlc footer.toString(), {Neat, dir, path, relative, config}
        navigation: hamlc navigation.toString(), {
          Neat
          dir
          path
          relative
          config
          navigation: config.navigation
        }
        body: content
      }
    newFiles

createPages = ->
  findMarkdownFiles()
  .then(read)
  .then (files) ->
    newFiles = {}
    for path, content of files
      path = path.replace PAGES_DIR, PAGES_TEMP_DIR
      path = path.replace 'md', 'html'
      newFiles[path] = marked content
    newFiles
  .then(applyLayout)
  .then(writeFiles)
  .then(compileStylus)

currentBranch = (status) ->
  status.split('\n').shift().replace /\# On branch (.+)$/gm, '$1'

hasUntrackedFile = (status) -> status.indexOf('Untracked files:') isnt -1
hasUnstagedChanges = (status) -> status.indexOf('Changes not staged') isnt -1

exports['github:pages'] = neatTask
  name: 'github:pages'
  description: t 'neat.tasks.github_pages.description'
  environment: 'default'
  action: (callback) ->
    git = null
    branch = null
    p = getGitInfo()
    .then (g) ->
      git = g
      checkGitStatus git.status
      branch = currentBranch git.status
      run('neat docco')
    .then(createTempDir)
    .then -> run("cp -r #{Neat.root}/docs #{PAGES_TEMP_DIR};
                  rm -rf #{Neat.root}/docs")
    .then(createPages)
    .then ->
      if 'gh-pages' in git.branches
        run('git checkout gh-pages')
      else
        run('git checkout -b gh-pages')
    .then ->
      content = fs.readdirSync Neat.root
      s = ''
      for p in content
        if p not in ['.pages','.git']
          s += "rm -rf #{Neat.root}/#{p};"
      run(s)
    .then ->
      run("mv .pages/* .;
           rm -rf .pages;
           git add .;
           git commit -am 'Updates gh-pages branch';
           git checkout #{branch}")
    .then ->
      callback? 0
    .fail (err) ->
      error red err.message
      callback? 1

exports['github:pages:preview'] = neatTask
  name: 'github:pages:preview'
  description: t 'neat.tasks.github_pages.description'
  environment: 'default'
  action: (callback) ->
    git = null
    branch = null
    createTempDir()
    .then -> run('neat docco')
    .then -> run("cp -r #{Neat.root}/docs #{PAGES_TEMP_DIR};
                  rm -rf #{Neat.root}/docs")
    .then(createPages)
    .then ->
      callback? 0
    .fail (err) ->
      error red err.message
      puts err.stack
      callback? 1
