define ["js/model/BaseModel"], (BaseModel) ->
	BaseModel.extend
		className: "Tag"
		defaults: { title: "", deleted: no }
		set: ->
			BaseModel.prototype.handleForSync.apply( @ , arguments )
			Parse.Object.prototype.set.apply( @ , arguments )