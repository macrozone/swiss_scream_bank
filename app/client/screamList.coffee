

Template.aScream.helpers
	source: ->
	

		switch @source
			when 'upload' then '<span class="glyphicon glyphicon-cloud-upload"></span> '+ @source
			when 'record' then '<span class="glyphicon glyphicon-record"></span> '+ @source
			when 'phone' then '<span class="glyphicon glyphicon-earphone"></span> '+ @source
			else '<span class="glyphicon glyphicon-question-sign"></span> unknown'