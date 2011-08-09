Backbone = SS.shared.models.Backbone

Backbone.sync = (method, model, options) ->  

  console.log 'SYNC'

  successCallback = options.success
  errorCallback = options.error
  
  M.collection model.get('collection'), (error, collection) ->    
    
    if error?
      errorCallback error
    else    
      switch method      
        when "create"
          collection.save model.toJSON(), (error, doc) ->
            if error?
              errorCallback error
            else
              # model.set 
              console.log doc
              successCallback JSON.parse(JSON.stringify(doc))
        when "update"
          model.set
            _id: M.bson_serializer.ObjectID.createFromHexString(model.attributes._id)            
          collection.save model.toJSON(), (error, doc) ->
            if error?
              errorCallback error
            else
              successCallback()
        when "read"
          collection.findOne 
            _id: M.bson_serializer.ObjectID.createFromHexString(model.attributes._id)
          , (error, doc) ->
            if error?
              errorCallback error
            else
              # This is a hack for now because mongo is returnin id not in string form
              successCallback JSON.parse(JSON.stringify(doc))
        when "delete"
          collection.remove
            _id: M.bson_serializer.ObjectID.createFromHexString(model.attributes._id)
            , (error, doc) ->
              if error?
                errorCallback error
              else
                successCallback()
                
          