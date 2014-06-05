define ["js/model/BaseModel"], (BaseModel) ->
	BaseModel.extend
		className: "Tag"
		defaults: { title: "", deleted: no }
		set: ->
			BaseModel.prototype.handleForSync.apply( @ , arguments )
			Backbone.Model.prototype.set.apply( @ , arguments )