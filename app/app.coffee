@ScreamStore = new FS.Store.FileSystem "screams", path: "~/screams"
@ScreamFiles = new FS.Collection "screamFiles",
	stores: [ScreamStore]
	filter:
		allow: 
			contentTypes: ['audio/*']

@Screams = new Meteor.Collection "screams"

if Meteor.isClient
	Meteor.startup ->
		AccountsEntry.config
			showSignupCode: true
			dashboardRoute: '/admin'  



	
		