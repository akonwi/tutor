module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        files:
          'tutor.js': 'src/tutor.coffee'

  grunt.loadNpmTasks 'grunt-contrib-coffee'
