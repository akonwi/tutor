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
    watch:
      source:
        files: '**/*.coffee'
      html:
        files: 'index.html'

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['watch']
