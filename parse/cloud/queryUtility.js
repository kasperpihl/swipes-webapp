exports.queriesForUpdating = function(user,lastUpdate,nowTime){
  	if(!user) user = Parse.User.current();
	if(!user) return false;
	var tagQuery = new Parse.Query('Tag');
	tagQuery.equalTo('owner',user);
	if(lastUpdate) tagQuery.greaterThanOrEqualTo('updatedAt',lastUpdate);
	else tagQuery.notEqualTo('deleted',true);
	if(nowTime) tagQuery.lessThanOrEqualTo('updatedAt',nowTime);

	var taskQuery = new Parse.Query('ToDo');
	taskQuery.equalTo('owner',user);
	if(lastUpdate) taskQuery.greaterThanOrEqualTo('updatedAt',lastUpdate);
	else taskQuery.notEqualTo('deleted',true);
	if(nowTime) taskQuery.lessThanOrEqualTo('updatedAt',nowTime);
	return [tagQuery,taskQuery];
};
exports.queriesForDuplications = function(user,tempIds){
	if(!user) user = Parse.User.current();
	if(!user) return false;
	var queries = [];
	var tagTempIds = tempIds["Tag"];
	if(tagTempIds && tagTempIds.length > 0){
		var tagQuery = new Parse.Query('Tag');
		tagQuery.equalTo('owner',user);
		tagQuery.containedIn('tempId',tagTempIds);
		queries.push(tagQuery);
	}

	var taskTempIds = tempIds['ToDo'];
	if(taskTempIds && taskTempIds.length > 0){
		var taskQuery = new Parse.Query('ToDo');
		taskQuery.equalTo('owner',user);
		taskQuery.containedIn('tempId',tempIds);
		queries.push(taskQuery);
	}
	
	return queries;
}