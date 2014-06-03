App.views.Reported = Parse.View.extend({
	el:'#activities',
	initialize:function(){
		
	},
	events:{
		'click #actAnswers.reported .gameButton': "clickedGame",
		'click #actAnswers.reported .blockButton': "clickedBlock"
	},
	clickedGame:function(e){
		var gameId  = $(e.currentTarget).attr('gameId');
		navigate('games/g/'+gameId);
		return false;
	},
	clickedBlock:function(e){
		var answerId  = $(e.currentTarget).attr('answerId');
		var buttonHtml = $(e.currentTarget).html();
		var unblock = (buttonHtml == 'Unblock');
		var answer = confirm(unblock ? "unblock answer?" : "block answer?");
		if(!answer) return false;
		var options = {answerId:answerId,unblock:unblock,functionName:"blockAnswer"};
		App.views.menu.setLoadingScreen();
		cloud(options,function(result,error){
			App.views.menu.removeLoadingScreen();
			if(result){
				var newHtml = unblock ? 'Block' : 'Unblock';
				$(e.currentTarget).toggleClass('btn-danger',unblock);
				$(e.currentTarget).toggleClass('btn-warning',!unblock);
				$(e.currentTarget).parent().toggleClass('blocked',!unblock);
				$(e.currentTarget).html(newHtml);

			}
			else console.log(error);
		});
		return false;
	},
	makeActive:function(){
		this.fetch();
	},
	fetch:function(){
		var self = this;
		var options = {action:'reported'};
		cloud(options,function(result,error){
			if(result) self.render(result.Answer);
		});
	},
	render:function(objects){
		$(this.el).html(_.template($('#tplAnswers').html(),{answers:objects,reported:true,blockButton:true}));
		App.views.menu.removeLoadingScreen();
	}
});
