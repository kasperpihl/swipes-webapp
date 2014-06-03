var App = {
	views: {},
	models: {},
	collections: {},
	routers: {}
};
var historyObj = {pushState:true,root:'/'};
$(document).ready(function(){
	App.routers.router = new App.routers.Router();
	App.views.menu = new App.views.Menu();
	Parse.history.start(historyObj);

	//App.routers.router.start();
});
function cloud(options,callback){
	var cloudFunction = options ? (options.functionName ? options.functionName : 'admin_dashboard') : 'admin_dashboard';
	Parse.Cloud.run(cloudFunction,options,{
		success:function(result,error){
			if(callback) callback(result,error);
		},
		error:function(error){
			if(callback) callback(false,error);
			if(error.message == "You have to be logged in") navigate('login',true);
		}
	});
}
function getAge(dateString) {
    var today = new Date();
    var birthDate = new Date(dateString);
    var age = today.getFullYear() - birthDate.getFullYear();
    var m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
        age--;
    }
    return age;
}
function getPlace(number){
	switch(number){
		case 1:
			return '1st';
		case 2:
			return '2nd';
		case 3:
			return '3rd';
		default:
			return number + 'th';
	}
}
function navigate(destination,options){
	if(!options) options = {trigger:true};
	Parse.history.navigate(destination,options);
}
function isFunction(possibleFunction) {
  return (typeof(possibleFunction) == typeof(Function));
}
function readableDate(d){
	return $.format.date(d,"dd/MM - HH:mm");
}
function capitaliseFirstLetter(string)
{
    return string.charAt(0).toUpperCase() + string.slice(1);
}
function renderStats(statObj){
	return _.template($('#tplStatNumbers').html(),{statistics:statObj});
}