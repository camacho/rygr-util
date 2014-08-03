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
  fs = require 'fs'

  if fs.existsSync dir
    gulp.src("#{ dir }/*", read: false)
      .pipe($.plumber errorHandler: alertError)
      .pipe $.rimraf force: true
      .end cb
  else
    fs.mkdir dir, cb

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
# Watch
# ------------------------------------------------------------------------------
gulp.task 'watch', (cb) ->
  gulp.watch 'src/**/*.coffee', ['compile']
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
  runSequence 'build', 'watch'
