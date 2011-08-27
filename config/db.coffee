mongoose = require('mongoose')
mongoose.connect('mongodb://localhost/showjo')

Schema = mongoose.Schema
ObjectId = Schema.ObjectId
global.M = {}

VoteSchema = new Schema
  points: 
    type: Number
  user_id:
    type: ObjectId
  performer_id:
    type: ObjectId
  created_at:
    type: Date
    default: Date.now()

mongoose.model 'votes', VoteSchema
M.Vote = mongoose.model 'votes'

PerformanceSchema = new Schema
  name:
    type: String
  user_id: 
    type: ObjectId
  desc:
    type: String
  staged_at:
    type: Date
  performed_at:
    type: Date
  length_sec:
    type: Number
  created_at:
    type: Date
    default: Date.now()
  votes:
    type: [VoteSchema]
  stream:
    type: Schema.Types.Mixed

MessageSchema = new Schema
  name: 
    type: String
  user_id: 
    type: ObjectId
  type:
    type: String
  message:
    type: String
  created_at:
    type: Date
    default: Date.now()

mongoose.model 'messages', MessageSchema
M.Message = mongoose.model 'messages'

###
PerformanceSchema.path('name').validate (v) ->
  return v.length > 4
, 'length too short'
###

mongoose.model 'performances', PerformanceSchema
M.Performance = mongoose.model 'performances'

UserSchema = new Schema
  name:
    type: String
    default: "Anonymous"
  created_at:
    type: Date
    default: Date.now()

mongoose.model 'users', UserSchema
M.User = mongoose.model 'users'

{EventEmitter} = require 'events'
global.emitter = new EventEmitter