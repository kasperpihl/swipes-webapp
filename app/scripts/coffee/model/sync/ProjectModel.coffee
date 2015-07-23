define ["js/model/sync/BaseModel"], (BaseModel) ->
	BaseModel.extend
		className: "Project"
		attrWhitelist: [ "name" ]
		defaults: { name: "Untitled Project" }