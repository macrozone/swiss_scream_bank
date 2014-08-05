recorder = null
STOP_DELAY = MAX_SCREAMS_IN_LIST = Meteor.settings?.public?.STOP_DELAY ? 600
Session.set "recording", false
Session.set "waitingForAudioCheck", true
Session.set "hasUserMediaSupport", false
audioContext = null;


initAudio = ->
	Session.set "waitingForAudioCheck", true
	Session.set "hasUserMediaSupport", false
	Session.set "recording", false
	#webkit shim
	window.AudioContext = window.AudioContext || window.webkitAudioContext || window.mozAudioContext;
	navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;
	window.URL = window.URL || window.webkitURL;
	audioContext = new AudioContext;
	
	onError = (error) ->
		Session.set "waitingForAudioCheck", false
		Session.set "hasUserMediaSupport", false
	onAudioAvailable = (stream) ->
		input = audioContext.createMediaStreamSource stream
		recorder = new Recorder input
		Session.set "waitingForAudioCheck", false
		Session.set "hasUserMediaSupport", true

	if navigator?.getUserMedia?

		navigator.getUserMedia {audio: true}, onAudioAvailable, onError
	else 
		onError()

Template.home_record.rendered = ->
	initAudio()

Template.home_record.waitingForAudioCheck = ->
	Session.get "waitingForAudioCheck"
Template.home_record.hasUserMediaSupport = ->
	Session.get "hasUserMediaSupport"

handleError = (error) ->
	if error?
		alert "an error occured, see console.log"
		console.error error
saveScreamBlob = (blob, source, done) ->

	file = new FS.File blob
	file.source = source

	unless file.name()?.length > 0
		file.name "record.wav"
	Screams.insert file, (error, file) ->
		handleError error
		done error, file
stopRecording = ->
	recorder.stop()
	recorder.exportWAV (blob) ->
		saveScreamBlob blob, "record", (error, file)->

			recorder?.clear()



Template.home_record.events
	"change .audioFileInput": (event) ->

		for file in event.target.files
			saveScreamBlob file, "upload", (error, file)->
				console.log "done"
	"click .btn-record": (event)->
		recording = Session.get "recording"
		Session.set "recording", !recording
		if recording
			_.delay stopRecording, STOP_DELAY
		else
			recorder.record()

Template.home_record.buttonLabel = ->
	if Session.get "recording" then "Stop" else "Record"

Template.home_record.glyphicon = ->
	if Session.get "recording" then "glyphicon-stop" else "glyphicon-record"
