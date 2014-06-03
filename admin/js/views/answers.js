App.views.Answers = Parse.View.extend({
	el:'#activities',
	initialize:function(){

	},
	events:{
		'click #actAnswers.answers .gameButton': "clickedGame",
		"click #actAnswers.answers .blockButton": "clickedBlock"
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
	clickedGame:function(e){
		var gameId  = $(e.currentTarget).attr('gameId');
		navigate('games/g/'+gameId);
		return false;
	},
	fetch:function(){
		var self = this;
		var options = {action:'answers'};
		cloud(options,function(result,error){
			if(result) self.render(result.Answer);
		});
	},
	makeActive:function(){
		this.fetch();
	},
	render:function(objects){
		$(this.el).html(_.template($('#tplAnswers').html(),{answers:objects,reported:false}));
		App.views.menu.removeLoadingScreen();
	}
});