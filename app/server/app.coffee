MAX_SCREAMS_IN_LIST = Meteor.settings?.public?.MAX_SCREAMS_IN_LIST ? 10


isAdmin = (userID) ->
	Roles.userIsInRole(userID, ['admin'])



Meteor.startup ->
	AccountsEntry.config
		signupCode: 'd79EH24B'

	getFilesForScreams = (cursor) ->
		ScreamFiles.find {}

	Meteor.smartPublish "latestScreams", ->

		screams = Screams.find {}, 
			sort: itime: -1
			limit: MAX_SCREAMS_IN_LIST

		files = getFilesForScreams screams

		[screams, files]

	Meteor.smartPublish "allScreams", ->
		unless isAdmin @userId
			throw new Meteor.Error 403
		screams = Screams.find {}, sort: uploadedAt: -1
		files = getFilesForScreams screams

		[screams, files]

	Meteor.publish "totalScreams", (params = {}) ->
		Meteor.publishCounter
			handle: this
			name: 'totalScreams'
			collection: Screams
			filter: params


	update =->
			true
	insert = ->
			true
	remove = (userID, doc) ->
			 if isAdmin userID
			 	return true
			 console.log doc
			 return false


	Screams.allow
		update: update
		insert: insert
		remove: remove
	Screams.deny
		# little hack to add itime
		insert: (userId, doc) -> 
			doc.itime = new Date().valueOf()
			false


	ScreamFiles.allow
		update: update
		insert: insert
		remove: remove
		download: (userID, file) ->
			true
		

	Meteor.methods
		removeTempFiles: (clientID) ->
			ScreamFiles.remove clientID: clientID
		deleteScream: (clientID, screamID) ->
			ScreamFiles.remove _id: screamID, clientID: clientID

	request = Npm.require("request");


# server side route to store recordings from flash (Wami)

	Router.map ->
		@route "api-record", 
			path: '/api/record/:clientID'
			where: "server"
			action: ->
				clientID = @params.clientID
				payload = []
				@request.on 'data', (data) =>
					payload.push data
				@request.on 'end', Meteor.bindEnvironment =>
					buffer = new Buffer(payload.reduce (prev, current) ->
            			return prev.concat(Array.prototype.slice.call(current))
        			, [])
					
					file = new FS.File()
				
					file.attachData buffer, {type: "audio/wav"}, =>
						file.source = "record"
						file.name "record.wav"
						file.clientID = clientID
						result = ScreamFiles.insert file
						
						@response.writeHead 200, {'Content-Type': 'application/json'}
						@response.end('hello from server');

