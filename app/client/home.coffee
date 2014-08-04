Router.map ->
	@route 'home', 
		path: '/'
		data: ->
			navigation: [
				(link: "#explication", label: "SBB")
				(link: "#fonctionement", label: "HOW?")
				(link: "#communaute", label: "LISTEN")
				(link: "#contact", label: "CONTACT")
			]


Template.home_navigation.rendered = ->
	@$ "li a"
	.on "click", (event) ->
		
		href = $(@).attr "href"
		$(window).scrollTo href, 400