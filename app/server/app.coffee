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



	Screams.allow
		update: ->
			true
		insert: ->
			true
		download: (userID, file) ->
			true
		remove: (userID, doc) ->
			 isAdmin userID