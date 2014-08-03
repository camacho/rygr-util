_ = require 'underscore'

module.exports = (args, callbacks, done) ->
  stack = []

  args = [args] unless _.isArray args
  baseArity = args.length + 1

  unless _.isArray callbacks
    if _.isFunction callbacks
      callbacks = [callbacks]
    else
      throw new Error "Callbacks must be an array of functions"

  for callback in callbacks
    if _.isFunction callback
      stack.push {handle: callback}
    else
      throw new Error "Callback is not a function"

  handle = ->
    index = 0

    next = (err) ->
      layer = stack[index++]

      unless layer
        done? err
        return

      try
        arity = layer.handle.length

        if err
          if arity is baseArity + 1
            layer.handle.apply undefined, [err].concat args, [next]
          else
            next err
        else if arity < baseArity + 1
          layer.handle.apply undefined, args.concat [next]
        else
          next()

      catch e
        next e

    next()

  handle()
