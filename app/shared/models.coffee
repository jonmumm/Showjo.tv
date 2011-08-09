Backbone = exports.Backbone = window?.Backbone or require('backbone')
_ = window?._ or require('underscore')._

Backbone.Model.prototype.idAttribute = "_id"

exports.performance = Backbone.Model.extend
  defaults:
    created_at: new Date()
    collection: 'performances'
  
  ###  
  validate: (attrs) ->
    if attrs.collection isnt 'performances'
      return 'collection type incorrect'
      
    return null
  ###