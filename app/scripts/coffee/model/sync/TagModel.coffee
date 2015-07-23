define ["js/model/sync/BaseModel"], (BaseModel) ->
	BaseModel.extend
		className: "Tag"
		attrWhitelist: [ "title" ]
		defaults: { title: "", deleted: no }