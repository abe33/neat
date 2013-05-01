(function() {
  var CONFIG, Neat, PAGES_DIR, PAGES_TEMP_DIR, Q, TASK_DIR, TPL_TOC, applyLayout, asyncErrorTrap, checkGitStatus, compileStylus, createIndex, createPages, createTOC, createTempDir, cup, currentBranch, e, ensurePath, error, exec, find, findMarkdownFiles, findSiblingFileSync, findTitle, fs, getGitInfo, green, handleError, hasUnstagedChanges, hasUntrackedFile, highlight, info, loadConfig, marked, neatTask, parallel, puts, read, readFiles, red, relative, render, resolve, run, t, writeFiles, _ref, _ref1, _ref2, _ref3,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  fs = require('fs');

  _ref = require('path'), relative = _ref.relative, resolve = _ref.resolve;

  exec = require('child_process').exec;

  Neat = require('../neat');

  parallel = Neat.require('async').parallel;

  _ref1 = Neat.require('utils/commands'), neatTask = _ref1.neatTask, asyncErrorTrap = _ref1.asyncErrorTrap;

  _ref2 = Neat.require('utils/logs'), error = _ref2.error, info = _ref2.info, green = _ref2.green, red = _ref2.red, puts = _ref2.puts;

  _ref3 = Neat.require('utils/files'), find = _ref3.find, ensurePath = _ref3.ensurePath, readFiles = _ref3.readFiles, findSiblingFileSync = _ref3.findSiblingFileSync;

  render = Neat.require('utils/templates').render;

  cup = Neat.require('utils/cup');

  t = Neat.i18n.getHelper();

  try {
    Q = require('q');
  } catch (_error) {
    e = _error;
    return error(t('neat.errors.missing_module', {
      missing: missing('q')
    }));
  }

  try {
    highlight = require('highlight.js').highlight;
  } catch (_error) {
    e = _error;
    return error(t('neat.errors.missing_module', {
      missing: missing('highlight')
    }));
  }

  try {
    marked = require('marked');
  } catch (_error) {
    e = _error;
    return error(t('neat.errors.missing_module', {
      missing: missing('marked')
    }));
  }

  PAGES_DIR = "" + Neat.root + "/pages";

  PAGES_TEMP_DIR = "" + Neat.root + "/.pages";

  CONFIG = "" + Neat.root + "/config/pages.cup";

  TASK_DIR = "" + Neat.neatRoot + "/src/tasks/github/pages";

  handleError = function(err) {
    error(red(err.message));
    return puts(err.stack);
  };

  marked.setOptions({
    gfm: true,
    pedantic: false,
    sanitize: false,
    highlight: function(code, lang) {
      return highlight(lang || 'coffeescript', code).value;
    }
  });

  run = function(command) {
    var defer;

    defer = Q.defer();
    exec(command, function(err, stdout, stderr) {
      if (err != null) {
        console.log(stderr);
        return defer.reject(stderr);
      } else {
        console.log(stdout);
        return defer.resolve(stdout);
      }
    });
    return defer.promise;
  };

  getGitInfo = function() {
    var o;

    o = {};
    return run('git status').then(function(status) {
      o.branch = currentBranch(status);
      o.status = status;
      return run('git branch');
    }).then(function(branches) {
      o.branches = branches.split('\n').map(function(b) {
        return b.slice(2);
      });
      return o;
    });
  };

  checkGitStatus = function(status) {
    if (hasUnstagedChanges(status)) {
      throw new Error(t('neat.tasks.github_pages.unstaged_changes'));
    }
    if (hasUntrackedFile(status)) {
      throw new Error(t('neat.tasks.github_pages.untracked_files'));
    }
  };

  read = function(files) {
    var defer;

    defer = Q.defer();
    readFiles(files, function(err, buf) {
      if (err != null) {
        return defer.reject(err);
      } else {
        return defer.resolve(buf.sort());
      }
    });
    return defer.promise;
  };

  loadConfig = function() {
    var defer;

    defer = Q.defer();
    fs.readFile(CONFIG, function(err, conf) {
      if (err != null) {
        return defer.reject(err);
      } else {
        return defer.resolve(cup.read(conf.toString()));
      }
    });
    return defer.promise;
  };

  createTempDir = function() {
    var defer;

    defer = Q.defer();
    ensurePath(PAGES_TEMP_DIR, function(err, created) {
      if (err != null) {
        return defer.reject(err);
      } else {
        return defer.resolve(created);
      }
    });
    return defer.promise;
  };

  findMarkdownFiles = function() {
    var defer;

    defer = Q.defer();
    find('md', [PAGES_DIR], function(err, files) {
      if (err != null) {
        return defer.reject(err);
      } else {
        return defer.resolve(files);
      }
    });
    return defer.promise;
  };

  compileStylus = function() {
    var defer, gen;

    defer = Q.defer();
    gen = function(path, content) {
      return function(callback) {
        if (typeof err !== "undefined" && err !== null) {
          return (defer.reject(err), typeof callback === "function" ? callback() : void 0);
        }
        return fs.readFile(path, function(err, content) {
          var css;

          if (err != null) {
            return (defer.reject(err), typeof callback === "function" ? callback() : void 0);
          }
          css = Neat.config.engines.templates.stylus.render(content.toString());
          path = path.replace(PAGES_DIR, PAGES_TEMP_DIR).replace('stylus', 'css');
          return fs.writeFile(path, css, function(err) {
            if (err != null) {
              return (defer.reject(err), typeof callback === "function" ? callback() : void 0);
            }
            return typeof callback === "function" ? callback() : void 0;
          });
        });
      };
    };
    find('stylus', [PAGES_DIR], function(err, files) {
      var file;

      return parallel((function() {
        var _i, _len, _results;

        _results = [];
        for (_i = 0, _len = files.length; _i < _len; _i++) {
          file = files[_i];
          _results.push(gen(file));
        }
        return _results;
      })(), function() {
        return defer.resolve();
      });
    });
    return defer.promise;
  };

  writeFiles = function(files) {
    var defer, gen, k, v;

    defer = Q.defer();
    gen = function(path, content) {
      return function(callback) {
        var dir;

        dir = resolve(path, '..');
        return ensurePath(dir, function(err) {
          return fs.writeFile(path, content, function(err) {
            if (err) {
              defer.reject(err);
            }
            return typeof callback === "function" ? callback() : void 0;
          });
        });
      };
    };
    parallel((function() {
      var _results;

      _results = [];
      for (k in files) {
        v = files[k];
        _results.push(gen(k, v));
      }
      return _results;
    })(), function() {
      return defer.resolve();
    });
    return defer.promise;
  };

  createIndex = function(files) {
    var content, index, path, title, _ref4;

    index = "# " + (t('neat.tasks.github_pages.pages_index.title')) + "\n";
    for (path in files) {
      content = files[path];
      title = ((_ref4 = /^\#\s+(.+)/g.exec(content.toString())) != null ? _ref4[1] : void 0) || '';
      index += "\n  1. [" + title + "](" + (relative(PAGES_DIR, path).replace('md', 'html')) + ")";
    }
    files["" + PAGES_DIR + "/pages_index.md"] = index;
    return files;
  };

  findTitle = function(content) {
    var res;

    res = /<h1[^>]*>(.*)<\/h1>/g.exec(content);
    return (res != null ? res[1] : void 0) || '';
  };

  applyLayout = function(files) {
    return loadConfig().then(function(config) {
      var content, dir, footer, getTemplate, hamlc, header, layout, navigation, newFiles, path, paths;

      hamlc = Neat.config.engines.templates.hamlc.render;
      getTemplate = function(name, partial) {
        var tplPath, _ref4;

        if (partial == null) {
          partial = true;
        }
        if (((_ref4 = config.templates) != null ? _ref4[name] : void 0) != null) {
          tplPath = resolve(Neat.root, config.templates[name]);
        } else {
          if (partial) {
            name = "_" + name;
          }
          tplPath = findSiblingFileSync("" + TASK_DIR + "/" + name, paths, 'templates', 'hamlc');
        }
        return fs.readFileSync(tplPath);
      };
      paths = Neat.paths;
      header = getTemplate('header');
      footer = getTemplate('footer');
      navigation = getTemplate('navigation');
      layout = getTemplate('layout', false);
      newFiles = {};
      for (path in files) {
        content = files[path];
        dir = resolve(path, '..');
        newFiles[path] = hamlc(layout.toString(), {
          Neat: Neat,
          dir: dir,
          path: path,
          relative: relative,
          config: config,
          title: "" + Neat.project.name + " - " + (findTitle(content)),
          header: hamlc(header.toString(), {
            Neat: Neat,
            dir: dir,
            path: path,
            relative: relative,
            config: config
          }),
          footer: hamlc(footer.toString(), {
            Neat: Neat,
            dir: dir,
            path: path,
            relative: relative,
            config: config
          }),
          navigation: hamlc(navigation.toString(), {
            Neat: Neat,
            dir: dir,
            path: path,
            relative: relative,
            config: config,
            navigation: config.navigation
          }),
          body: content
        });
      }
      return newFiles;
    });
  };

  TPL_TOC = resolve(Neat.root, 'templates/commands/docco/_toc');

  createTOC = function(files) {
    var commands, content, defer, path, r;

    r = function(path, content) {
      return function(callback) {
        var END_TAG, START_TAG, endMatch, id, level, match, replacement, startMatch, title, titles;

        if (content.indexOf('@toc') === -1) {
          return typeof callback === "function" ? callback() : void 0;
        }
        START_TAG = /<h(\d)>/g;
        END_TAG = /<\/h(\d)>/g;
        titles = [];
        while (startMatch = START_TAG.exec(content)) {
          level = parseInt(startMatch[1]);
          endMatch = END_TAG.exec(content);
          title = content.substring(START_TAG.lastIndex, endMatch.index);
          id = title.parameterize();
          match = "<h" + level + ">" + title + "</h" + level + ">";
          replacement = "<h" + level + " id='" + id + "'>" + title + "</h" + level + ">";
          content = content.replace(match, replacement);
          titles.push({
            id: id,
            content: title,
            level: level
          });
          START_TAG.lastIndex += id.length + 6;
          END_TAG.lastIndex += id.length + 6;
        }
        return render(TPL_TOC, {
          titles: titles
        }, function(err, toc) {
          content = content.replace('@toc', toc);
          files[path] = content;
          return typeof callback === "function" ? callback() : void 0;
        });
      };
    };
    commands = (function() {
      var _results;

      _results = [];
      for (path in files) {
        content = files[path];
        _results.push(r(path, content));
      }
      return _results;
    })();
    defer = Q.defer();
    parallel(commands, function() {
      if (typeof err !== "undefined" && err !== null) {
        return defer.reject(err);
      }
      return defer.resolve(files);
    });
    return defer.promise;
  };

  createPages = function() {
    return findMarkdownFiles().then(read).then(createIndex).then(function(files) {
      var content, newFiles, path;

      newFiles = {};
      for (path in files) {
        content = files[path];
        path = path.replace(PAGES_DIR, PAGES_TEMP_DIR);
        path = path.replace('md', 'html');
        newFiles[path] = marked(content);
      }
      return newFiles;
    }).then(createTOC).then(applyLayout).then(writeFiles).then(compileStylus);
  };

  currentBranch = function(status) {
    return status.split('\n').shift().replace(/\# On branch (.+)$/gm, '$1');
  };

  hasUntrackedFile = function(status) {
    return status.indexOf('Untracked files:') !== -1;
  };

  hasUnstagedChanges = function(status) {
    return status.indexOf('Changes not staged') !== -1;
  };

  exports['github:pages'] = neatTask({
    name: 'github:pages',
    description: t('neat.tasks.github_pages.description'),
    environment: 'default',
    action: function(callback) {
      var branch, git, p;

      git = null;
      branch = null;
      return p = getGitInfo().then(function(g) {
        git = g;
        checkGitStatus(git.status);
        branch = currentBranch(git.status);
        return run('neat docco');
      }).then(createTempDir, handleError).then(function() {
        return run("cp -r " + Neat.root + "/docs " + PAGES_TEMP_DIR);
      }).then(function() {
        return run("rm -rf " + Neat.root + "/docs");
      }).then(createPages).then(function() {
        if (__indexOf.call(git.branches, 'gh-pages') >= 0) {
          return run('git checkout gh-pages');
        } else {
          return run('git checkout -b gh-pages');
        }
      }).then(function() {
        return run('cp .gitignore .gitignore_safe &&\
           git ls-files -z | xargs -0 rm -f &&\
           git ls-tree --name-only -d -r -z HEAD | sort -rz | xargs -0 rmdir &&\
           mv .gitignore_safe .gitignore');
      }, handleError).then(function() {
        return run("mv .pages/* . &&           rm -rf .pages &&           git add . &&           git commit -am 'Updates gh-pages branch' &&           git checkout " + branch);
      }).then(function() {
        return typeof callback === "function" ? callback(0) : void 0;
      }, function(err) {
        handleError(err);
        return typeof callback === "function" ? callback(1) : void 0;
      });
    }
  });

  exports['github:pages:preview'] = neatTask({
    name: 'github:pages:preview',
    description: t('neat.tasks.github_pages.description'),
    environment: 'default',
    action: function(callback) {
      var branch, git;

      git = null;
      branch = null;
      return createTempDir().then(function() {
        return run('neat docco').then(function() {
          return run("cp -r " + Neat.root + "/docs " + PAGES_TEMP_DIR + " &&                  rm -rf " + Neat.root + "/docs").then(createPages).then(function() {
            return typeof callback === "function" ? callback(0) : void 0;
          }, function(err) {
            handleError(err);
            return typeof callback === "function" ? callback(1) : void 0;
          });
        });
      });
    }
  });

}).call(this);
