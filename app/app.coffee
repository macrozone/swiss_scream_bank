@Screams = new FS.Collection "screams",
	stores: [new FS.Store.FileSystem "screams", path: "~/screams"]
	filter:
		allow: 
			contentTypes: ['audio/*']

if Meteor.isServer

	MAX_SCREAMS_IN_LIST = Meteor.settings?.public?.MAX_SCREAMS_IN_LIST ? 5
	Meteor.publish "latestScreams", ->

		Screams.find {}, 
			sort: uploadedAt: -1
			limit: MAX_SCREAMS_IN_LIST


	
	Screams.allow
		update: ->
			true
		insert: ->
			true
		download: (userID, file) ->
			true