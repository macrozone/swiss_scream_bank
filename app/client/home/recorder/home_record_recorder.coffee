jsRecorder = null
STOP_DELAY = MAX_SCREAMS_IN_LIST = Meteor.settings?.public?.STOP_DELAY ? 600
Session.setDefault "clientID", Meteor.uuid()
Session.setTemporary "recording", false
Session.setTemporary "waitingForAudioCheck", true
Session.setTemporary "hasUserMediaSupport", false


tryFlashAudio = ->

	Wami.setup
		id: "flashWami"
		onReady: ->
			
			Session.setTemporary "waitingForAudioCheck", false
			Session.setTemporary "hasUserMediaSupport", true
			Session.setTemporary "recorder", "flash"

Template.home_record_recorder.rendered = ->

	Session.setTemporary "waitingForAudioCheck", true
	Session.setTemporary "hasUserMediaSupport", false
	Session.setTemporary "recording", false
	Session.setTemporary "recorder", ""
	
	#webkit shim
	window.AudioContext = window.AudioContext || window.webkitAudioContext || window.mozAudioContext;
	navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;
	window.URL = window.URL || window.webkitURL || window.mozURL;
	audioContext = new AudioContext;
	
	onError = (error) ->
		Session.setTemporary "waitingForAudioCheck", false
		Session.setTemporary "hasUserMediaSupport", false
		
	onAudioAvailable = (stream) ->
		#by set the stream as global variable 
		#will stop firefox cut the recording..., see https://github.com/mattdiamond/Recorderjs/issues/49
		window.__FIREFOX_HACK_RECORDER_JS__ = stream
		input = audioContext.createMediaStreamSource stream
		jsRecorder = new JsRecorder input, 
			bufferLen: 4096 # default 4096
			#sampleRate: 2000

		Session.setTemporary "waitingForAudioCheck", false
		Session.setTemporary "hasUserMediaSupport", true
		Session.setTemporary "recorder", "js"

	if navigator?.getUserMedia?

		navigator.getUserMedia {audio: true}, onAudioAvailable, onError
	else 
		tryFlashAudio()


Template.home_record_recorder.waitingForAudioCheck = ->
	Session.get "waitingForAudioCheck"
Template.home_record_recorder.hasUserMediaSupport = ->
	Session.get "hasUserMediaSupport"


handleError = (error) ->
	if error?
		alert "an error occured, see console.log"
		
saveScreamBlob = (blob, source, done) ->

	file = new FS.File blob
	file.source = source
	file.clientID = Session.get "clientID"
	unless file.name()?.length > 0
		file.name "record.wav"

	ScreamFiles.insert file, (error, file) ->
		handleError error
		done error, file



startRecording = ->
	
	switch Session.get "recorder"
		when "js" then startRecordingJs()
		when "flash" then startRecordingFlash()
	
startRecordingJs = ->

	jsRecorder.record()

startRecordingFlash = ->
	clientID = Session.get "clientID"
	Wami.startRecording "/api/record/"+clientID
	
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
			unless error?
				jsRecorder?.clear()

Template.home_record_recorder.events
	"change .audioFileInput": (event) ->
		for file in event.target.files
			saveScreamBlob file, "upload", (error, file)->
				console.log "done"

	"click .btn-record": (event)->
		recording = Session.get "recording"
		Session.setTemporary "recording", !recording
		if recording
			_.delay stopRecording, STOP_DELAY
		else
			startRecording()

Template.home_record_recorder.buttonLabel = ->
	if Session.get "recording" then "Stop" else "Record"

Template.home_record_recorder.glyphicon = ->
	if Session.get "recording" then "glyphicon-stop" else "glyphicon-record"
