App.views.Users = Parse.View.extend({
	el:'#activities',
	currentUser:false,
	initialize:function(){
	},
	events:{
		'click #actUsers .userRow': 'clickedUserRow',
		'click #actUser .blockBtn': 'clickedBlockBtn',
		'click #actUser .adjustCoinsButton': 'clickedAdjust'
	},
	clickedUserRow:function(e){
		var userId  = $(e.currentTarget).attr('userId');
		navigate('users/'+userId);
		return false;
	},
	clickedAdjust:function(e){
		
		var user = this.currentUser;
		var amount = parseInt($('#actUser #addCoins .coins').val(),10);
		if(!amount || amount === 0) {
			alert('Please set the amount of coins');
			return false;
		}
		var confirmMessage = "Add " + amount + " to this user?";
		if(amount < 0) confirmMessage = "Remove " + amount + " from this user?";
		var answer = confirm(confirmMessage);
		if(!answer) return false;
		var options = {userId:user.id,amount:amount,functionName:"coins"};
		var check = $('#actUser #addCoins #sendPushCheck').is(':checked');
		if(check){
			var message = $("#actUser #addCoins .pushMessage").val();
			if(message) options.pushMessage = message;
		}
		App.views.menu.setLoadingScreen();
		cloud(options,function(result,error){
			App.views.menu.removeLoadingScreen();
			if(result){
				$('#actUser #addCoins .coins').val("");
				$("#actUser #addCoins .pushMessage").val("");
				$("table.statTable #points").html(result);
				$("#actUser #addCoins #currentCoins").html(result);
			}
			else console.log(error);
		});
		return false;
	},
	clickedBlockBtn:function(e){

		var user = this.currentUser;
		var unblock = user.get('blocked') ? true : false;

		var cssClass = unblock ? "btn-danger" : "btn-warning";
		var oldCssClass = unblock ? "btn-warning" : "btn-danger";
		var btnText = unblock ? "Block" : "Unblock";
		var tableClass = unblock ? 'success' : "error";
		var oldTableClass = unblock ? "error" : "success";
		var answer = confirm(unblock ? "unblock user?" : "block user?");
		if(!answer) return false;
		var options = {userId:user.id,unblock:unblock,functionName:"blockUser"};
		App.views.menu.setLoadingScreen();
		cloud(options,function(result,error){
			App.views.menu.removeLoadingScreen();
			if(result){
				user.set('blocked',!unblock);
				$("#blockBtn").html(btnText);
				$('#blockBtn').addClass(cssClass);
				$('#blockBtn').removeClass(oldCssClass);
				
				$('table.statTable #blockBtn').parent().parent().removeClass(oldTableClass);
				$('table.statTable #blockBtn').parent().parent().addClass(tableClass);

			}
			else console.log(error);
		});
		return false;
	},
	fetch:function(id){
		var self = this;
		var options = {action:'users'};
		if(id) options.userId = id;
		cloud(options,function(result,error){
			if(result){
				if(id) self.renderUser(result);
				else self.render(result);
			}
			if(error) console.log(error);
		});
	},
	makeUser:function(objects){
		var objectsContainer = {};
		var userObjects = objects._User;
	},
	makeActive:function(id){
		this.fetch(id);
	},
	render:function(objects){
		var stats = {
			'Total users':objects.totalUserCount,
			'Female users':objects.femaleUserCount,
			'Male users':objects.maleUserCount
		};
		var renderedStatistics = renderStats(stats);
		$(this.el).html(_.template($('#tplUsers').html(),{statistics:renderedStatistics, users:objects._User,timeAgo:$.timeago,getAge:getAge}));
	
		App.views.menu.removeLoadingScreen();
	},
	renderUser:function(objects){
		var user = objects._User;
		this.currentUser = user;
			
		var invitationPoints = _.reduce(objects.Invitation,function(memo,invitation){ return memo + parseInt(invitation.get('amount'),10); },0);
		var purchasesPoints = _.reduce(objects.Purchase,function(memo,purchase){ return memo + parseInt(purchase.get('amount'),10); },0);
		var chatPoints = _.reduce(objects.Chat,function(memo,chat){ if(chat.get('charged')) return memo + parseInt(chat.get('charged'),10); else return memo;},0);
		var cssClass = user.get('blocked') ? "btn-warning" : "btn-danger";
		var btnText = user.get("blocked") ? "Unblock" : "Block";
		var html = '<button id="blockBtn" class="btn '+ cssClass +  ' blockBtn">' + btnText + '</button>';
		var stats = {
			'objectId': user.id,
			'Member since': readableDate(user.createdAt),
			'Current points': "<span id='points'>" + user.get('points') + "</span>",
			'Number of invitations': _.size(objects.Invitation),
			'Invitations': invitationPoints+'p',
			'Number of purchases': _.size(objects.Purchase),
			'Purchases': purchasesPoints+'p',
			'Number of games': objects.numberOfGames,
			'Number of chats': _.size(objects.Chat),
			'Chatting': chatPoints+'p',
			'Sent messages': objects.totalSendMessages,
			'Received messages': objects.totalReceivedMessages,
			"Blocked": html

		};
		
		var renderedStatistics = renderStats(stats);
		$(this.el).html(_.template($('#tplUser').html(),{statistics:renderedStatistics,user:user}));
		var tableClass = user.get('blocked') ? 'error' : 'success';
		$('table.statTable #blockBtn').parent().parent().addClass(tableClass);
		
		App.views.menu.removeLoadingScreen();
	}

});