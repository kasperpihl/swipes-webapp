define ["js/model/sync/BaseModel"], (BaseModel) ->
	BaseModel.extend
		className: "Project"
		idAttribute: "objectId"
		attrWhitelist: [ "name" ]
		defaults: { name: "Untitled Project" }