module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        files:
          'config.js': 'config.coffee'
          'main.js': 'main.coffee'
          'libs/views.js': 'libs/views.coffee'
          'libs/word.js': 'libs/word.coffee'
    watch:
      source:
        files: '**/*.coffee'
        tasks: 'coffee'
        options:
          livereload: 3000

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['watch']
