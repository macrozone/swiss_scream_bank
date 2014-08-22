
	
Template.home_record_submit.screamAttemps = ->
	ScreamFiles.find clientID: Session.get "clientID"


Template.home_record_submit_oneScream.events
		"click": (event, template) ->
			template.$ "input"
			.prop "checked", true


Template.home_record_submit.events


	"click .btn-submit": (event, template)->
		selectedFileID = template.$("input[name='selection']:checked").val()
		message = template.$("textarea").val()
		email = template.$("[name='email']").val()
		
		unless selectedFileID
			alert "please chose one of your screams"
			return false
		unless message?.length > 0
			alert "please leave a message"
			return false
		unless email?.length > 0
			alert "please leave your email address"
			return false
		file = ScreamFiles.findOne _id: selectedFileID
		ScreamFiles.update {_id: file._id}, {$set: {clientID: null}}, null,  (error, result) ->
			
			unless error?

				Meteor.call "removeTempFiles", Session.get "clientID"
				Screams.insert
					file: file
					message: message
					email: email
					source: file.source

		
