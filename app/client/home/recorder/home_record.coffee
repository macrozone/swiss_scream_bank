jsRecorder = null
STOP_DELAY = MAX_SCREAMS_IN_LIST = Meteor.settings?.public?.STOP_DELAY ? 600
Session.set "recording", false
Session.set "waitingForAudioCheck", true
Session.set "hasUserMediaSupport", false
audioContext = null;

tryFlashAudio = ->

	Wami.setup
		id: "flashWami"
		onReady: ->
			alert "flash ready"
			Session.set "waitingForAudioCheck", false
			Session.set "hasUserMediaSupport", true
			Session.set "recorder", "flash"

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
		
		Session.set "hasUserMediaSupport", false
		tryFlashAudio()
	onAudioAvailable = (stream) ->
		input = audioContext.createMediaStreamSource stream
		jsRecorder = new JsRecorder input, 
			bufferLen: 4096 # default 4096
			#sampleRate: 2000
		Session.set "waitingForAudioCheck", false
		Session.set "hasUserMediaSupport", true
		Session.set "recorder", "js"

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

startRecording = ->
	switch Session.get "recorder"
		when "js" then startRecordingJs()
		when "flash" then startRecordingFlash()
	
startRecordingJs = ->
	jsRecorder.record()
startRecordingFlash = ->

	Wami.startRecording "/api/record"

stopRecording = ->
	switch Session.get "recorder"
		when "js" then stopRecordingJs()
		when "flash" then stopRecordingFlash()

stopRecordingFlash = ->
	Wami.stopRecording()

stopRecordingJs = ->

	jsRecorder.stop()
	jsRecorder.exportWAV (blob) ->
		saveScreamBlob blob, "record", (error, file)->

			jsRecorder?.clear()



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
			startRecording()

Template.home_record.buttonLabel = ->
	if Session.get "recording" then "Stop" else "Record"

Template.home_record.glyphicon = ->
	if Session.get "recording" then "glyphicon-stop" else "glyphicon-record"
