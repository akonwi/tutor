module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        files:
          'config.js': 'config.coffee'
          'main.js': 'main.coffee'
          'libs/views.js': 'libs/views.coffee'
          'libs/word.js': 'libs/word.coffee'

  grunt.loadNpmTasks 'grunt-contrib-coffee'
