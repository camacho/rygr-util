colors = require './colors'
date = require './date'

module.exports = (args...) ->
  time = colors.grey "[#{date new Date(), 'HH:MM:ss'}]"
  args.unshift time
  console.log args...
  @
