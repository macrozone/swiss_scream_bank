MAX_SCREAMS_IN_LIST = Meteor.settings?.public?.MAX_SCREAMS_IN_LIST ? 10
# client collection for totalScreams
ScreamCount = new Meteor.Collection "totalScreams"
Router.map ->
	@route 'home', 
		path: '/'
		waitOn: -> [Meteor.subscribe "latestScreams", Meteor.subscribe "totalScreams"]
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
			numberOfScreams: ScreamCount.findOne().count

Template.home_navigation.rendered = ->
	@$ "li a"
	.on "click", (event) ->
		
		href = $(@).attr "href"
		$(window).scrollTo href, 400


