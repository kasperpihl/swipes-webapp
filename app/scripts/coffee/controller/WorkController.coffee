define ["underscore"], () ->
    class WorkController
        constructor: ->
        	Backbone.on( "request-work-task", @requestWorkTask, @ )
        requestWorkTask: ( task ) ->
        	