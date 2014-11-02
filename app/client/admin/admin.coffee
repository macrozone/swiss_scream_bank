

Router.map ->
	@route 'admin',
		path: "/admin" 
		layoutTemplate: "layout_admin"
		
		onBeforeAction: ->
			unless Meteor.userId()?
				@redirect '/sign-in'
			else
				@next()
			
		
	@route 'admin_users', 
		path: "/admin/users"
		layoutTemplate: "layout_admin"
		template: "accountsAdmin"
		onBeforeAction: ->
			unless Meteor.userId()?
				@redirect '/sign-in'
			else
				@next()


	@route 'admin_screams',
		path: "/admin/screams" 
		template: "admin_screams"
		layoutTemplate: "layout_admin"
		subscriptions: -> Meteor.subscribe "allScreams"
		onBeforeAction: ->
			unless Meteor.userId()?
				@redirect '/sign-in'
			else
				@next()
		data: ->
			
			screams: Screams.find {}, 
				sort: itime: -1

Template.admin_aScream.events
	'click .btn-delete': (event, template) ->
		if window.confirm "Are you sure to delete this Scream? It can't be undone"
			Meteor.call "deleteScream", template.data._id

