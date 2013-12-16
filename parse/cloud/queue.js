var queue = [];
var options = {
	recurring:1
};
exports.addToQueue = function(query,count,title){
	var queueObj = {query:query};
	if(count) queueObj.count = true;
	queueObj.title = title ? title : query.className;
	queueObj.skip = 0;
	queue[queue.length] = queueObj;
};
exports.getQueue = function(){
	return queue;
};
exports.set = function(name,value){
	if(name == 'recurring'){
		value = parseInt(value,10);
		if(!(value >= 1 && value <= 3)) return;
	}
	options[name] = value;
};
exports.runQueue = function(callback){
	function performQuery(object,callback){
		var query = object.query;
		var optionObject = {
			success:function(result){
				callback(object,result);
			},
			error:function(error){
				callback(object,null,error);
			}
		};
		if(object.count) query.count(optionObject);
		else query.find(optionObject);
	}
	var k = 0;
	var doneCounter = 0;
	var target = queue.length;
	if(target === 0) return callback(false,null);
	var returnObj = {};
	function checkDone(){
		if(doneCounter == target){
			callback(returnObj,null);
		}
		else next();
	}
	function next(){
		if(k>=target){
			return;
		}
		performQuery(queue[k],function(object,result,error){
			if(error) callback(null,error);
			else{
				returnObj[object.title] = result;
				doneCounter++;
				checkDone();
			}
			
		});
		k++;
	}
	for(var i = 0 ; i < options.recurring ; i++){
		next();
	}
};