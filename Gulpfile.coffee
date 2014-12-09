# ------------------------------------------------------------------------------
# Load in modules
# ------------------------------------------------------------------------------
gulp = require 'gulp'
$ = require('gulp-load-plugins')()
runSequence = require 'run-sequence'

# ------------------------------------------------------------------------------
# Custom vars and methods
# ------------------------------------------------------------------------------
alertError = $.notify.onError (error) ->
  message = error?.message or error?.toString() or 'Something went wrong'
  "Error: #{ message }"

cleanDir = (dir, cb) ->
  require('del') ["#{ dir }/**", "!#{dir}"], cb

# ------------------------------------------------------------------------------
# Directory management
# ------------------------------------------------------------------------------
gulp.task 'clean', cleanDir.bind null, 'lib'

# ------------------------------------------------------------------------------
# Compile
# ------------------------------------------------------------------------------
gulp.task 'compile', ->
  gulp.src('src/**/*.coffee')
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed 'lib')
    .pipe($.coffee bare: true)
    .pipe(gulp.dest 'lib')

# ------------------------------------------------------------------------------
# Build
# ------------------------------------------------------------------------------
gulp.task 'build', (cb) ->
  runSequence 'clean', 'compile', cb

# ------------------------------------------------------------------------------
# Build
# ------------------------------------------------------------------------------
gulp.task 'test', ['build'], ->
  gulp.src('tests/specs/*')
    .pipe($.plumber errorHandler: alertError)
    .pipe($.jasmine())

# ------------------------------------------------------------------------------
# Watch
# ------------------------------------------------------------------------------
gulp.task 'watch', (cb) ->
  gulp.watch 'src/**/*.coffee', ['compile', 'test']
  gulp.watch 'tests/**/*.coffee', ['test']
  cb()

# ------------------------------------------------------------------------------
# Release
# ------------------------------------------------------------------------------
(->
  types = [
    'patch'
    'prerelease'
    'minor'
    'major'
  ]

  bump = (type) ->
    ->
      gulp.src('./package.json')
        .pipe($.bump type: type)
        .pipe(gulp.dest './')

  publish = (type) ->
    (cb) ->
      sequence = ['build']
      sequence.push "bump:#{ type }" if type
      sequence.push ->
        spawn = require('child_process').spawn
        spawn('npm', ['publish'], stdio: 'inherit').on 'close', cb

      runSequence sequence...

  for type, index in types
    gulp.task "bump:#{ type }", bump type
    gulp.task "publish:#{ type }", publish type
    gulp.task 'bump', bump type unless index

  gulp.task 'publish', publish()
)()

# ------------------------------------------------------------------------------
# Default
# ------------------------------------------------------------------------------
gulp.task 'default', ->
  runSequence 'build', 'test', 'watch'
