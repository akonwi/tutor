module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        files:
          'config.js': 'src/config.coffee'
          'main.js': 'src/main.coffee'
          'libs/views.js': 'src/views.coffee'
          'libs/word.js': 'src/word.coffee'

  grunt.loadNpmTasks 'grunt-contrib-coffee'
