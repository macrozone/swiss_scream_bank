MAX_SCREAMS_IN_LIST = Meteor.settings?.public?.MAX_SCREAMS_IN_LIST ? 10
SCREAMS_COUNT_OFFSET = Meteor.settings?.public?.SCREAMS_COUNT_OFFSET ? 0
# client collection for totalScreams

ScreamCount = new Meteor.Collection "totalScreams"
Router.map ->
	@route 'home', 
		path: '/'
		subscriptions: -> [
			Meteor.subscribe "latestScreams",
			Meteor.subscribe "totalScreams"
		]
		data: ->
			navigation: [
				(link: "#rec", label: "REC")
				(link: "#what", label: "WHAT")
				(link: "#partners", label: "PARTNERS")
				(link: "#infos", label: "INFOS")
				(link: "#videos", label: "VIDEOS")
			]
			socialLinks: [
				(icon: "images/facebook.png", url: i18n "urls.facebook")
				(icon: "images/twitter.png", url: i18n "urls.twitter")
				(icon: "images/instagram.png", url: i18n "urls.instagram")
				(icon: "images/tumblr.png", url: i18n "urls.tumblr")
			]

			screams: Screams.find {}, 
				sort: itime: -1
				limit: MAX_SCREAMS_IN_LIST
			maxScreams: MAX_SCREAMS_IN_LIST
			numberOfScreams: SCREAMS_COUNT_OFFSET+parseInt(ScreamCount.findOne()?.count,10)

Template.home_header.rendered = ->
	@$ ".nav li a"
	.on "click", (event) ->
		
		href = $(@).attr "href"
		$(window).scrollTo href, 400


Template.registerHelper "equals", (a, b) -> a is b
