MAX_SCREAMS_IN_LIST = Meteor.settings?.public?.MAX_SCREAMS_IN_LIST ? 10
SCREAMS_COUNT_OFFSET = Meteor.settings?.public?.SCREAMS_COUNT_OFFSET ? 0
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
				(link: "#partners", label: "PARTNERS")
				(link: "#infos", label: "INFOS")
				(link: "#tagboard", label: "TAGBOARD")
			]

			screams: Screams.find {}, 
				sort: itime: -1
				limit: MAX_SCREAMS_IN_LIST
			maxScreams: MAX_SCREAMS_IN_LIST
			numberOfScreams: SCREAMS_COUNT_OFFSET+parseInt(ScreamCount.findOne()?.count,10)

Template.home_navigation.rendered = ->
	@$ "li a"
	.on "click", (event) ->
		
		href = $(@).attr "href"
		$(window).scrollTo href, 400


UI.registerHelper "equals", (a, b) -> a is b
  
Template.tag_board.rendered = ->
	$('head').append '<script>var tagboardOptions = {tagboard:"SCREAMSWISS/188458", fixedHeight:false};</script><script src="https://tagboard.com/public/js/embed.js"></script>'