App.views.Chats = Parse.View.extend({
	el:'#activities',
	initialize:function(){

	},
	events:{
		'click #actChats .userRow': 'clickedUserRow',
		'click #actChats .chatButton': 'clickedChat',
		'click #actChat .userRow': 'clickedUserRow'
	},
	clickedChat:function(e){
		var chatId  = $(e.currentTarget).attr('chatId');
		navigate('chats/c/'+chatId);
		return false;
	},
	clickedUserRow:function(e){
		var userId  = $(e.currentTarget).attr('userId');
		navigate('users/'+userId);
		return false;
	},
	fetch:function(type,id){
		var self = this;
		var options = {action:'chats'};
		if(id && type == 'c') options.chatId = id;
		else if(id && type == 'u') options.userId = id;
		cloud(options,function(result,error){
			if(result){
				if(id && type == 'c') self.renderChat(result);
				else self.render(result);
			}
			if(error) console.log(error);
		});
	},
	makeChat:function(objects){
		var objectsContainer = {};
		var userObjects = objects._User;
	},
	makeActive:function(type,id){
		this.fetch(type,id);
	},
	render:function(objects){
		var stats = {
			'Total chats':objects.totalChatCount,
			'Total messages': objects.totalMessageCount
		};
		var renderedStatistics = renderStats(stats);
		$(this.el).html(_.template($('#tplChats').html(),{statistics:renderedStatistics, chats:objects.Chat}));
		App.views.menu.removeLoadingScreen();
	},
	renderChat:function(objects){
		counter = 0;
		for(var index in objects.Chat){
			counter++;
			var object = objects.Chat[index];
			var boy = object.get('boy');
			var girl = object.get('girl');
			$(this.el).html(_.template($('#tplChat').html(),{boy:boy,girl:girl,chat:object,messages:objects.Message,timeAgo:$.timeago}));
			App.views.menu.removeLoadingScreen();
			if(counter == 1) return;
		}
	}

});