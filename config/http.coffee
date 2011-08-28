# HTTP Middleware Config
# ----------------------

# Version 2.0

# This file defines how incoming HTTP requests are handled
# Note: The default configuration will probably change a lot in the future. Be warned!


# CUSTOM MIDDLEWARE

# Hook-in your own custom HTTP middleware to modify or respond to requests before they're passed to the SocketStream HTTP stack
# See README for more details and example middleware code

custom = ->

  (request, response, next) ->
    # console.log 'This is my custom middleware. The URL requested is', request.url
    # Unless you're serving a response you'll need to call next() here 
    # next()


# CONNECT MIDDLEWARE

connect = require('connect')
everyauth = require('everyauth')

everyauth.facebook
	.appId('220525971333346')
	.appSecret('7760b9dfe554f4768e66cd70aaa30617')
	.handleAuthCallbackError (req, res) ->
		console.log 'authcallback'
	.findOrCreateUser (session, accessToken, accessTokExtra, fbUserMetaData) ->
		console.log fbUserMetaData
	.redirectPath '/'

routes = (app) ->
	app.get '/test', (req, res, next) ->
		console.log 'test'
    # next()

# Stack for Primary Server
exports.primary =
  [
    connect.bodyParser()
		connect.cookieParser()
		connect.session( { secret: 'mysecret '} )
		everyauth.middleware()
		connect.router(routes)
  ]

# Stack for Secondary Server
exports.secondary = []
