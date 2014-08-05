MAX_SCREAMS_IN_LIST = Meteor.settings?.public?.MAX_SCREAMS_IN_LIST ? 5

Router.map ->
	@route 'home', 
		path: '/'
		waitOn: -> Meteor.subscribe "latestScreams"
		data: ->
			navigation: [
				(link: "#explication", label: "SBB")
				(link: "#record", label: "RECORD!")
				(link: "#fonctionement", label: "HOW?")
				(link: "#communaute", label: "LISTEN")
				(link: "#contact", label: "CONTACT")
			]

			screams: Screams.find {}, 
				sort: uploadedAt: -1
				limit: MAX_SCREAMS_IN_LIST
			maxScreams: MAX_SCREAMS_IN_LIST

Template.home_navigation.rendered = ->
	@$ "li a"
	.on "click", (event) ->
		
		href = $(@).attr "href"
		$(window).scrollTo href, 400


