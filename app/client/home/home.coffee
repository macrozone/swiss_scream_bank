MAX_SCREAMS_IN_LIST = Meteor.settings?.public?.MAX_SCREAMS_IN_LIST ? 10

Router.map ->
	@route 'home', 
		path: '/'
		waitOn: -> Meteor.subscribe "latestScreams"
		data: ->
			navigation: [
				(link: "#rec", label: "REC")
				(link: "#what", label: "WHAT")
				
				(link: "#infos", label: "INFOS")
				(link: "#partners", label: "PARTNERS")
			]

			screams: Screams.find {}, 
				sort: itime: -1
				limit: MAX_SCREAMS_IN_LIST
			maxScreams: MAX_SCREAMS_IN_LIST

Template.home_navigation.rendered = ->
	@$ "li a"
	.on "click", (event) ->
		
		href = $(@).attr "href"
		$(window).scrollTo href, 400


