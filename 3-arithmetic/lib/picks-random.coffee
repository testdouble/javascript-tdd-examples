_ = require('lodash')

module.exports = (items) ->
  _(items).shuffle()[0]
