define ["js/model/sync/BaseModel"], (BaseModel) ->
	BaseModel.extend
		className: "Work"
		attrWhitelist: [ "startTime", "endTime", "taskLocalId", "completionTime", "cancelTime", "hasChosenCompleted" ]
		defaults: { "hasChosenCompleted": no }
		initialize: ->
			@reviveDate "startTime"
			@reviveDate "endTime"
			@reviveDate "completionTime"
			@reviveDate "cancelTime"
		secondsLeft: ->
			endTime = Math.floor(@get("endTime").getTime()/1000)
			nowTime = Math.floor(new Date().getTime()/1000)
			secondsLeft = endTime - nowTime
			secondsLeft
		isRunning: ->
			now = new Date()
			return no if @get("endTime").getTime() < now.getTime() and @get("hasChosenCompleted")
			return no if @get("cancelTime")
			return no if @get("completionTime")
			yes