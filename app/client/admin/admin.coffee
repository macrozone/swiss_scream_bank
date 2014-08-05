

Router.map ->
	@route 'admin',
		path: "/admin" 
		layoutTemplate: "layout_admin"
		
		onBeforeAction: ->
			AccountsEntry.signInRequired @
		
	@route 'admin_users', 
		path: "/admin/users"
		layoutTemplate: "layout_admin"
		template: "accountsAdmin"
		onBeforeAction: ->
			AccountsEntry.signInRequired @


	@route 'admin_screams',
		path: "/admin/screams" 
		layoutTemplate: "layout_admin"
		waitOn: -> Meteor.subscribe "allScreams"
		onBeforeAction: ->
			AccountsEntry.signInRequired @
		data: ->
			
			screams: Screams.find {}, 
				sort: uploadedAt: -1


