define ["js/model/sync/BaseModel"], (BaseModel) ->
	BaseModel.extend
		className: "Tag"
		idAttribute: "objectId"
		attrWhitelist: [ "title" ]
		defaults: { title: "", deleted: no }