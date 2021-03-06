jsRecorder = null
STOP_DELAY = MAX_SCREAMS_IN_LIST = Meteor.settings?.public?.STOP_DELAY ? 600
Session.setDefaultPersistent "clientID", Meteor.uuid()
Session.setTemp "recording", false
Session.setTemp "waitingForAudioCheck", true
Session.setTemp "hasUserMediaSupport", false


tryFlashAudio = ->
	Session.setTemp "recorder", "flash"
	Wami.setup
		id: "flashWami"
		onReady: ->
			
			Session.setTemp "waitingForAudioCheck", false
			Session.setTemp "hasUserMediaSupport", true
			


Template.home_record_recorder.rendered = ->
	Session.setTemp "isInitialized", false

initAudio = ->
	Session.setTemp "isInitialized", true
	Session.setTemp "waitingForAudioCheck", true
	Session.setTemp "hasUserMediaSupport", false
	Session.setTemp "recording", false
	Session.setTemp "recorder", ""
	
	#webkit shim
	window.AudioContext = window.AudioContext || window.webkitAudioContext || window.mozAudioContext;
	navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;
	window.URL = window.URL || window.webkitURL || window.mozURL;
	audioContext = new AudioContext;
	
	onError = (error) ->
		Session.setTemp "waitingForAudioCheck", false
		Session.setTemp "hasUserMediaSupport", false
		
		
	onAudioAvailable = (stream) ->
		#by set the stream as global variable 
		#will stop firefox cut the recording..., see https://github.com/mattdiamond/Recorderjs/issues/49
		window.__FIREFOX_HACK_RECORDER_JS__ = stream
		input = audioContext.createMediaStreamSource stream
		jsRecorder = new JsRecorder input, 
			bufferLen: 4096 # default 4096
			#sampleRate: 2000

		Session.setTemp "waitingForAudioCheck", false
		Session.setTemp "hasUserMediaSupport", true
		

	if navigator?.getUserMedia?
		Session.setTemp "recorder", "js"
		navigator.getUserMedia {audio: true}, onAudioAvailable, onError
	else 
		tryFlashAudio()


Template.home_record_recorder.helpers
	notInitialized: -> not Session.get "isInitialized"
	recorderType: -> Session.get "recorder"
	waitingForAudioCheck: -> Session.get "waitingForAudioCheck"
	hasUserMediaSupport: -> Session.get "hasUserMediaSupport"
	buttonLabel: -> if Session.get "recording" then "Stop" else "Record"
	recording: -> Session.get "recording"
	glyphicon: -> if Session.get "recording" then "glyphicon-stop" else "glyphicon-record"

Template.home_record_recorder.events
	"change .audioFileInput": (event) ->
		for file in event.target.files
			saveScreamBlob file, "upload", (error, file)->
				console.log "done"

	"click .btn-record-initial": initAudio

	"click .btn-record": (event)->
		recording = Session.get "recording"
		Session.setTemp "recording", !recording
		if recording
			_.delay stopRecording, STOP_DELAY
		else
			startRecording()


handleError = (error) ->
	if error?
		alert "an error occured, see console.log"
		
saveScreamBlob = (blob, source, done) ->

	file = new FS.File blob
	file.source = source
	file.type "audio/wav"
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




