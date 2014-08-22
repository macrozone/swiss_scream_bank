

Router.map ->
	@route 'admin',
		path: "/admin" 
		layoutTemplate: "layout_admin"
		
		onBeforeAction: ->
			unless Roles.userIsInRole Meteor.userId(), ['admin']
				@redirect '/sign-in'
			
		
	@route 'admin_users', 
		path: "/admin/users"
		layoutTemplate: "layout_admin"
		template: "accountsAdmin"
		onBeforeAction: ->
			unless Roles.userIsInRole Meteor.userId(), ['admin']
				@redirect '/sign-in'


	@route 'admin_screams',
		path: "/admin/screams" 
		layoutTemplate: "layout_admin"
		waitOn: -> Meteor.subscribe "allScreams"
		onBeforeAction: ->
			unless Roles.userIsInRole Meteor.userId(), ['admin']
				@redirect '/sign-in'
		data: ->
			
			screams: Screams.find {}, 
				sort: uploadedAt: -1


