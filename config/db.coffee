# Place your Database config here
mongodb = require('mongodb')   # installed by NPM
Db = mongodb.Db
Connection = mongodb.Connection
Server = mongodb.Server

global.M = new Db('showjo', new Server('localhost', 27017))
M.ObjectID = mongodb.ObjectID
M.open (err, client) -> 
  console.error(err) if err?