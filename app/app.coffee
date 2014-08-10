@ScreamStore = new FS.Store.FileSystem "screams", path: "~/screams"
@Screams = new FS.Collection "screams",
	stores: [ScreamStore]
	filter:
		allow: 
			contentTypes: ['audio/*']


if Meteor.isClient
	Meteor.startup ->
		AccountsEntry.config
			showSignupCode: true
			dashboardRoute: '/admin'  



	
		