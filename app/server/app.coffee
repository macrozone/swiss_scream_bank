MAX_SCREAMS_IN_LIST = Meteor.settings?.public?.MAX_SCREAMS_IN_LIST ? 5


isAdmin = (userID) ->
	Roles.userIsInRole(userID, ['admin'])



Meteor.startup ->
	AccountsEntry.config
		signupCode: 'd79EH24B'

	Meteor.publish "latestScreams", ->

		Screams.find {}, 
			sort: uploadedAt: -1
			limit: MAX_SCREAMS_IN_LIST

	Meteor.publish "allScreams", ->
		unless isAdmin @userId
			throw new Meteor.Error 403
		Screams.find {}, sort: uploadedAt: -1

	console.log ScreamStore

	Screams.allow
		update: ->
			true
		insert: ->
			true
		download: (userID, file) ->
			true
		remove: (userID, doc) ->
			 isAdmin userID

	request = Npm.require("request");


# server side route to store recordings from flash (Wami)

	Router.map ->
		@route "api-record", 
			path: '/api/record'
			where: "server"
			action: ->
				payload = []
				@request.on 'data', (data) ->
					payload.push data
				@request.on 'end', Meteor.bindEnvironment ->
					buffer = new Buffer(payload.reduce (prev, current) ->
            			return prev.concat(Array.prototype.slice.call(current))
        			, [])
					
					file = new FS.File()

					file.attachData buffer, {type: "audio/wav"}, ->
						file.source = "record"
						file.name "record.wav"
						Screams.insert file