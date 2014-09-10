module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        options:
          bare: true
        files:
          'background.js': 'background.coffee'
          'app.js': [
            'js/space-pen.coffee'
            'libs/*.coffee'
          ]
          'main.js': 'main.coffee'
    sass:
      dist:
        options:
          style: 'compressed'
          noCache: true
          sourcemap: false
        files:
          'css/styles.css': 'sass/styles.sass'
    watch:
      source:
        files: ['**/*.coffee', 'sass/*.sass']
        tasks: ['coffee', 'sass']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-sass'

  grunt.registerTask 'default', ['watch']
