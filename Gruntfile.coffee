module.exports = (grunt) ->
  grunt.initConfig
    watch:
      options:
        livereload: 3000
      source:
        files: '**/*.coffee'
      html:
        files: 'index.html'

  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['watch']
