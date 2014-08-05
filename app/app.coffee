@Screams = new FS.Collection "screams",
	stores: [new FS.Store.FileSystem "screams", path: "~/screams"]
	filter:
		allow: 
			contentTypes: ['audio/*']


if Meteor.isClient
	Meteor.startup ->
		AccountsEntry.config
			showSignupCode: true
			dashboardRoute: '/admin'  



	
		