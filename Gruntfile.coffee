module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        options:
          bare: true
        files: [
          expand: true
          flatten: true
          cwd: 'src'
          src: ['*.coffee']
          dest: 'js'
          ext: '.js'
        ]
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
