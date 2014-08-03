_ = require 'underscore'
glob = require 'glob'
path = require 'path'
fs = require 'fs'

_.mixin deepExtend: require('underscore-deep-extend')(_)

initialize = (queries, options = {}) ->
  # Ensure we have an array or string for the directory name
  unless _.isArray(queries) or _.isString queries
    return throw new Error 'Config queries must be a string or array'

  # Set defaults
  defaults =
    env: process.env.NODE_ENV or 'development'
    freeze: true
    cwd: process.cwd()
    root: path.resolve options.cwd, '/'
    inMemory: true

  _.defaults options, defaults
  options.debug ?= if options.env is 'development' then true else false

  [errors, files] = queryAndReadFiles queries, options
  console.error errors... if errors and options.debug

  if options.inMemory
    delete attributes.initialize
    files = [attributes].concat files

  configs = _.deepExtend files...
  deepFreeze configs unless options.deepFreeze? and not options.deepFreeze

  configs

queryAndReadFiles = (queries, options) ->
  errors = []
  configs = []

  queries = [queries] if _.isString queries

  for query in queries
    try
      filenames = glob.sync query, _.pick options, 'root', 'cwd'
    catch e
      errors.push e
      continue

    [fileErrors, files] = readFiles filenames, options
    errors = errors.concat fileErrors if fileErrors
    configs.push files

  if errors.length then [errors, configs] else [null, configs]

readFiles = (filenames, options) ->
  files = {}
  errors = []

  for filename in filenames
    fullPath = path.resolve filename

    try
      file = require fullPath
    catch e
      errors.push e
      continue

    unless _.isObject file
      errors.push new Error "File <#{ fullPath }> is not an object"
      continue

    key = path.basename filename, path.extname filename
    files[key] = parseAttributes file, options.env

  if errors.length
    [errors, files]
  else
    [null, files]

parseAttributes = (data, env) ->
  _.extend data, options if options = data.environments?[env]
  delete data.environments
  data

deepFreeze = (object) ->
  Object.freeze object

  for key, value of object
    property = object[key]

    if object.hasOwnProperty(property) and
    _.isObject(property) and
    not Object.isFrozen property
      deepFreeze property

attributes = initialize: initialize
module.exports = attributes
