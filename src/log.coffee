colors = require './colors'
date = require './date'

log = (args...) ->
  time = colors.grey "[#{date new Date(), 'HH:MM:ss'}]"
  args.unshift time
  console.log args...
  @

log.error = (err) ->
  failed = true

  err =
    if not err.err
      err.message
    else if typeof err.err is 'string'
      new Error(err.err).stack
    else if typeof e.err.showStack is 'boolean'
      err.err.toString()
    else
      err.err.stack

  log colors.red err

module.exports = log
