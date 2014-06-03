var taskModel = Parse.Object.extend('Task');
var taskCollectionQuery = new Parse.Query(taskModel);
taskCollectionQuery.descending('createdAt');
taskCollectionQuery.doesNotExist('user');
taskCollectionQuery.doesNotExist('replaced');
App.collections.Tasks = Parse.Collection.extend({
	model: taskModel,
	query: taskCollectionQuery
});