App.views.Games = Parse.View.extend({
	el:'#activities',
	initialize:function(){

	},
	events:{
		'click #actGames .gameButton': "clickedGame",
		'click #actGames .userRow': 'clickedUserRow',
		'click #actGame .userRow': 'clickedUserRow',
		'click #actGame .thumbnail': "clickedThumbnail"
	},
	clickedUserRow:function(e){
		var userId  = $(e.currentTarget).attr('userId');
		navigate('users/'+userId);
		return false;
	},
	clickedThumbnail:function(){ return false; },
	clickedGame:function(e){
		var gameId  = $(e.currentTarget).attr('gameId');
		navigate('games/g/'+gameId);
		return false;
	},
	fetch:function(type,id){
		var self = this;
		var options = {action:'games'};
		if(id) options.gameId = id;
		cloud(options,function(result,error){
			if(result){
				var gameContainer = self.makeGames(result);
				if(id) self.renderGame(gameContainer);
				else self.render(gameContainer,result);
			}
			if(error) console.log(error);
		});
	},
	makeGames:function(objects){
		var gameContainer = {};
		var gameObjects = objects.Game;
		var gamePlayerObjects = objects.GamePlayer;
		var gameTaskObjects = objects.GameTask;
		var answerObjects = objects.Answer;

		var i;
		for(i = 0 ; i < gameObjects.length ; i++){
			var game = gameObjects[i];
			gameContainer[game.get('gameId')] = {};
			gameContainer[game.get('gameId')].game = game;
			gameContainer[game.get('gameId')].girl = game.get('girl');
			gameContainer[game.get('gameId')].gamePlayers = {};
			gameContainer[game.get('gameId')].answers = {};
			gameContainer[game.get('gameId')].gameTasks = {};
		}
		for(i = 0 ; i < gamePlayerObjects.length ; i++){
			var gamePlayer = gamePlayerObjects[i];

			gameContainer[gamePlayer.get('gameId')].gamePlayers[gamePlayer.id] = gamePlayer;
			gameContainer[gamePlayer.get('gameId')].playerCounter = i+1;
		}
		if(gameTaskObjects){
			for(i = 0 ; i < gameTaskObjects.length ; i++){
				var gameTask = gameTaskObjects[i];
				gameContainer[gameTask.get('gameId')].answers[gameTask.id] = {};
				gameContainer[gameTask.get('gameId')].gameTasks[gameTask.id] = gameTask;
				gameContainer[gameTask.get('gameId')].taskCounter = i+1;
			}

		}
		if(answerObjects){
			for(i = 0 ; i < answerObjects.length ; i++){
				var answer = answerObjects[i];
				gameContainer[answer.get('gameId')].answers[answer.get('gameTaskId')][answer.id] = answer;
			}
		}
		return gameContainer;
	},
	makeActive:function(type,id){
		this.fetch(type,id);
	},
	render:function(gameContainer,objects){
		var stats = {
			'Total games': objects.totalNumberOfGames,
			'Total gametasks': objects.totalGameTaskCount,
			'Total searching players': objects.totalSearchingPlayerCount,
			'Total unstarted games': objects.totalUnstartedGames
		};
		var renderedStatistics = renderStats(stats);
		$(this.el).html(_.template($('#tplGames').html(),{gamesContainer:gameContainer,statistics:renderedStatistics}));
		App.views.menu.removeLoadingScreen();
	},
	renderGame:function(objects){
		counter = 0;
		var gamePlayerFunction = function(gamePlayer){ if(!gamePlayer.get('isEliminated')) return true; };
		var answerReduceFunction = function(memo,answers){ return memo + _.size(answers); };
		for(var index in objects){
			counter++;
			var gameContainer = objects[index];
			var answerCount = _.reduce(gameContainer.answers,answerReduceFunction,0);
			var stats = {
				'Players joined':_.size(gameContainer.gamePlayers)+'/'+gameContainer.game.get('maxPlayers'),
				'Players left':_.size(_.filter(gameContainer.gamePlayers,gamePlayerFunction)),
				'GameTasks':_.size(gameContainer.gameTasks),
				'Answers':answerCount,
				'Game created': readableDate(gameContainer.game.createdAt)
			};
			var renderedStatistics = renderStats(stats);
			$(this.el).html(_.template($('#tplGame').html(),{statistics:renderedStatistics, gameContainer:gameContainer}));
			App.views.menu.removeLoadingScreen();
			if(counter == 1) return;
		}
		
	}

});