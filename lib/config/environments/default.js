(function() {
  module.exports = function(config) {
    return config.merge({
      verbosity: 0,
      engines: {
        templates: {},
        databases: {},
        tests: {},
        logging: {}
      },
      tasks: {},
      templatesDirectoryName: 'templates',
      defaultLoggingEngine: 'console'
    });
  };

}).call(this);
