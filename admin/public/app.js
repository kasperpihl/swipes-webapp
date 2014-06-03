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

/* **********************************************
     Begin router.js
********************************************** */

App.routers.Router = Parse.Router.extend({
	routes: {
		'login':			'openLogin',
		'games':			'openGames',
		'games/:type/:id':	'openGames',
		'users':			'openUsers',
		'users/:id':		'openUsers',
		'chats':			'openChats',
		'chats/:type/:id':	'openChats',
		'statistics':		'openStatistics',

		'reported':			'openReported',
		'answers':			'openAnswers',
		'invitations':		'openInvitations',

		'tasks':			'openTasks',
		'faq':				'openFAQ',

		'logout':			'performLogout',
		
		'*all':				'openAll'
	},
	activeMenuString:false,
	openAll:function(){
		this.navigate('games',{trigger:true});
	},
	openLogin:function(){
		this.changeToMenu('login');
	},
	
	openGames:function(type,identifier){
		this.changeToMenu('games',type,identifier);
	},
	openUsers:function(userId){
		this.changeToMenu('users',userId);
	},
	openChats:function(type,identifier){
		this.changeToMenu('chats',type,identifier);
	},
	openStatistics:function(){
		this.changeToMenu('statistics');
	},

	openReported:function(){
		this.changeToMenu('reported');
	},
	openAnswers:function(){
		this.changeToMenu('answers');
	},
	openInvitations:function(){
		this.changeToMenu('invitations');
	},

	openTasks:function(){
		this.changeToMenu('tasks');
	},
	openFAQ:function(){
		this.changeToMenu('faq');
	},
	changeToMenu:function(menu,param1,param2){
		var currentUser = Parse.User.current();

		var activeMenuString = menu;
		if(param1) activeMenuString = menu+'/'+param1;
		if(param2) activeMenuString += '/' + param2;
		if(activeMenuString == this.activeMenuString) return;
		App.views.menu.setSelected(menu);
		if (!currentUser && menu != 'login' && !test) {
			navigate('login');
			return;
		}
		this.activeMenuString = activeMenuString;
		if(!App.views[menu]) App.views[menu] = new App.views[capitaliseFirstLetter(menu)]();
		if(isFunction(App.views[menu].makeActive)) App.views[menu].makeActive(param1,param2);
	},
	performLogout:function(){
		Parse.User.logOut();
		navigate('login');
	}
});

/* **********************************************
     Begin menu.js
********************************************** */

App.views.Menu = Parse.View.extend({
	el:'#leftMenu',
	initialize:function(){
		this.render();
	},
	render:function(){
		$(this.el).html(_.template($('#tplMenu').html()));
	},
	setLoadingScreen:function(text){
		$('#loadingScreen').show();
		if(!text) text = "Loading";
		$('#loadingScreen #loadingText').html(text);
	},
	removeLoadingScreen:function(){
		$('#loadingScreen').hide();
	},
	setSelected:function(destination){
		this.setLoadingScreen();
		$('#leftMenu .active').removeClass('active');
		if(destination == 'login') $(this.el).hide();
		else{
			$(this.el).show();
			$('#leftMenu [href='+destination+']').parent().addClass('active');
		}
	},
	events:{
		'click li a': 'menuClicked'
	},
	menuClicked:function(e){
		var destination = $(e.currentTarget).attr('href');
		if(destination == App.routers.router.activeMenuString) return false;
		if(destination) navigate(destination);
		return false;
	}
});

/* **********************************************
     Begin statistics.js
********************************************** */

App.views.Statistics = Parse.View.extend({
	el:'#activities',
	initialize:function(){
		
	},
	events:{
		'click #loadStatButton': 'loadStatistics'
	},
	loadStatistics:function(button){
		if($('#loadStatButton').attr("disabled")) return;
		var pick1From = $('#pick1-from').datepicker("getDate");
		var pick1To = $('#pick1-to').datepicker("getDate");
		var pick2From = $('#pick2-from').datepicker("getDate");
		var pick2To = $('#pick2-to').datepicker("getDate");
		if(!pick1From || !pick1To) return alert('Please input span 1 dates');
		var self = this;
		var options1 = {functionName:'statistics',startDate:pick1From,endDate:pick1To};
		var options2 = (pick2From && pick2To) ? {functionName:'statistics',startDate:pick2From,endDate:pick2To} : null;
		$('#loadStatButton').attr("disabled",true);
		cloud(options1,function(pick1Result,error){
			if(pick1Result){
				console.log(pick1Result);
				if(options2){
					cloud(options2,function(pick2Result,error){
						$('#loadStatButton').attr("disabled",false);
						console.log(pick2Result);
						if(pick2Result){
							self.loadStatisticResult(pick1Result,pick2Result);
						}
						if(error){
							console.log(error);
							$('#loadStatButton').attr("disabled",false);
						}
					});
				}
				
				else{
					$('#loadStatButton').attr("disabled",false);
					self.loadStatisticResult(pick1Result);
				}
			}
			if(error){
				console.log(error);
				$('#loadStatButton').attr("disabled",false);
			}
		});
	},
	makeActive:function(){
		this.render();
	},
	render:function(objects){
		$(this.el).html(_.template($('#tplStatistics').html()));
		$(".datepicker").datepicker({dateFormat:"dd/mm/yy"});
		App.views.menu.removeLoadingScreen();
	},
	loadStatisticResult:function(pick1Result,pick2Result){
		if(!pick2Result) pick2Result = {};
		var structure = {
			totalUsers:"Total Users",
			newUsers:"New Users",
			activeUsers:'Active Users (current month)',
			activeGuys: "Active Guys (current month)",
			activeGirls:"Active Girls (current month)",
			joinGames:'Joined Games',
			gamePerGuy:'Games Per Guy',
			createGames:"Created Games",
			gamePerGirl:"Games Per Girl",
			answers:"Answers To Tasks",
			eliminations:"Eliminations",
			connections:"Number Of Connections",
			connectionsPerUser:"Connections Per Active User",
			invitations:"Number of Invitations",
			invitationsPerUser:"Invitations Per User",
			userWhoInvite:"Users Who Send Invites",
			userWhoCameFromInvites:"Users Who Came From Invites"
		};
		$('#statisticResults').html(_.template($('#tplStatisticResults').html(),{structure:structure,pick1Result:pick1Result,pick2Result:pick2Result}));
	}
});

/* **********************************************
     Begin reported.js
********************************************** */

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


/* **********************************************
     Begin login.js
********************************************** */

App.views.Login = Parse.View.extend({
	el:'#activities',
	events:{
		'click #loginBtn': 'doLogin'
	},
	makeActive:function(){
		$(this.el).html(_.template($('#tplLogin').html()));
		App.views.menu.removeLoadingScreen();
	},
	doLogin:function(){
		Parse.FacebookUtils.logIn(null, {
			success: function(user) {
				if (!user.get('admin')) {
					alert("You are not admin");
				} else {
					navigate('dashboard');
				}
			},
			error: function(user, error) {
				alert("User cancelled the Facebook login or did not fully authorize.");
			}
		});
	}
});

/* **********************************************
     Begin answers.js
********************************************** */

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

/* **********************************************
     Begin faq.js
********************************************** */

App.views.Faq = Parse.View.extend({
	el:'#activities',
	initialize:function(){

	},
	events:{
		'click #actFaq .openAddFaq': 'openAddFaq',
		'click #actFaq .addFaqBtn': 'addFaq',
		'click #actFaq .editButton': 'editFaq',
		'click #actFaq .cancelButton': 'cancelFaq'
	},
	showEditor:function(){
		if(!this.isShowingEditor){
			$('#addFaqContainer').slideDown();
			this.isShowingEditor = true;
		}
	},
	hideEditor:function(){
		if(this.isShowingEditor){
			$('#addFaqContainer').slideUp();
			this.isShowingEditor = false;
			$('#actFaq .openAddFaq').attr('disabled',null);
			$('#actFaq .editButton[disabled=disabled]').attr('disabled',null);
		}
	},
	cancelFaq:function(e){
		this.hideEditor();
	},
	openAddFaq:function(e){
		$('#faqQuestion').val('');
		$('#faqAnswer').val('');
		$('#faqOrder').val('');
		$('#actFaq .addFaqBtn').html('Add');
		$('#actFaq .editButton[disabled=disabled]').attr('disabled',null);
		this.editingModel = false;
		$(e.currentTarget).attr('disabled','disabled');
		this.showEditor();
		
	},
	editFaq:function(e){

		var model = this.collection.get($(e.currentTarget).attr('objectId'));
		if(model){
			$('#actFaq .editButton[disabled=disabled]').attr('disabled',null);
			$(e.currentTarget).attr('disabled','disabled');
			$('#actFaq .openAddFaq').attr('disabled',null);
			$('#faqQuestion').val(model.get('question'));
			$('#faqAnswer').val(model.get('answer'));
			$('#faqOrder').val(model.get('order'));
			$('#actFaq .addFaqBtn').html('Edit');

			this.editingModel = model;
			this.showEditor();
		}
		
	},
	addFaq:function(e){
		var question = $('#faqQuestion').val();
		var answer = $('#faqAnswer').val();
		var order = parseInt($('#faqOrder').val(),10);
		if(!answer || !question) return alert('Please fill out both answer and question');
		var fAQ;
		if(!this.editingModel){
			var FAQ = Parse.Object.extend("FAQ");
			fAQ = new FAQ();
		}
		else{
			fAQ = this.editingModel;
		}
		// Create a new instance of that class.
		var self = this;
		var buttonEl = $(e.currentTarget);
		buttonEl.attr('disabled','disabled');
		fAQ.save({question:question,answer:answer,order:order},{
			success:function(object){
				var test = self.collection.get(object.id);
				if(!test){
					self.collection.add(object);
				}
				else{
					self.collection.sort();
				}
				buttonEl.attr('disabled',null);
				self.hideEditor();
				self.render();
				
			},
			error:function(object,error){
				console.log(error);
			}
		});
	},
	
	fetch:function(){
		if(!this.collection){
			var self = this;
			this.collection = new App.collections.Faqs();
			this.collection.comparator = function(object){
				var order = parseInt(object.get('order'),10);
				return order ? order : 0;
			};
			this.collection.fetch({
				success:function(collection){
					self.collection = collection;
					self.render(true);
				},
				error:function(collection,error){
					console.log(error);
				}
			});
		}
		else this.render(true);
	},
	makeActive:function(type,id){
		this.fetch(type,id);
	},
	render:function(first){
		if(first) $(this.el).html(_.template($('#tplFaq').html(),{}));
		$('#faqTable').html(_.template($('#tplFaqTable').html(),{faqs:this.collection.models}));
		App.views.menu.removeLoadingScreen();
	}
});

/* **********************************************
     Begin games.js
********************************************** */

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

/* **********************************************
     Begin tasks.js
********************************************** */

App.views.Tasks = Parse.View.extend({
	el:'#activities',
	initialize:function(){

	},
	events:{
		'click #actTasks .openAddTask': 'openAddTask',
		'click #actTasks .addTaskBtn': 'addTask',
		'click #actTasks .editButton': 'editTask',
		'click #actTasks .cancelButton': 'cancelTask',
		'click #actTasks .acdetivateButton': 'acdetivateTask'
	},
	showEditor:function(){
		if(!this.isShowingEditor){
			$('#addTaskContainer').slideDown();
			this.isShowingEditor = true;
		}
	},
	hideEditor:function(){
		if(this.isShowingEditor){
			$('#addTaskContainer').slideUp();
			this.isShowingEditor = false;
			$('#actTasks .openAddTask').attr('disabled',null);
			$('#actTasks .editButton[disabled=disabled]').attr('disabled',null);
		}
	},
	cancelTask:function(e){
		this.hideEditor();
	},
	openAddTask:function(e){
		$('#taskTitle').val('');
		$('#taskType').val('choose');
		$('#actTasks .addTaskBtn').html('Add');
		$('#actTasks .editButton[disabled=disabled]').attr('disabled',null);
		this.editingModel = false;
		$(e.currentTarget).attr('disabled','disabled');
		this.showEditor();
		
	},
	editTask:function(e){
		var model = this.collection.get($(e.currentTarget).attr('objectId'));
		if(model){
			$('#actTasks .editButton[disabled=disabled]').attr('disabled',null);
			$(e.currentTarget).attr('disabled','disabled');
			$('#actTasks .openAddTask').attr('disabled',null);
			$('#taskTitle').val(model.get('title'));
			$('#taskOrder').val(model.get('order'));
			$('#taskType').val(model.get('type'));
			$('#actTasks .addTaskBtn').html('Edit');
			this.editingModel = model;
			this.showEditor();
		}
		
	},
	acdetivateTask:function(e){
		var objectId = $(e.currentTarget).attr('objectId');
		var model = this.collection.get(objectId);
		var activated = model.get('standard');
		if(activated) model.set('standard',false);
		else model.set('standard',true);
		var self = this;
		model.save({
			success:function(object){
				self.render();
			},
			error:function(object,error){
				console.log(error);
			}
		});
		console.log(model.get('title'));
	},
	addTask:function(e){
		var title = $('#taskTitle').val();
		var type = $('#taskType').val();
		var order = parseInt($('#taskOrder').val(),10);
		console.log(order);
		if(!title) return alert('Please fill out title');
		if(!type || type == 'choose') return alert('Please choose a type');
		var savingObjects = [];
		var Task = Parse.Object.extend("Task");
		var newTask;
		

		if(this.editingModel){
			var oldTask = this.editingModel;
			if(oldTask.get('type') != type) return alert('You can\'t change type of a task');
			if(oldTask.get('title') == title && oldTask.get('order') == order) return this.hideEditor();
			if(oldTask.get('deployed') && title != oldTask.get('title')){
				newTask = new Task();
				newTask.set('title',title);
				newTask.set('order',order);
				newTask.set('type',type);
				savingObjects[savingObjects.length] = newTask;
				oldTask.set('standard',false);
				oldTask.set('replaced',newTask);
			}
			else{
				if(!oldTask.get('deployed')){
					oldTask.set('title',title);
				}
				oldTask.set('order',order);
			}
			savingObjects[savingObjects.length] = oldTask;
		}
		else{
			newTask = new Task();
			newTask.set('title',title);
			newTask.set('type',type);
			newTask.set('order',order);
			savingObjects[savingObjects.length] = newTask;
		}
		
		// Create a new instance of that class.
		var self = this;
		var buttonEl = $(e.currentTarget);
		buttonEl.attr('disabled','disabled');
		Parse.Object.saveAll(savingObjects,{
			success:function(objects){
				console.log(objects);
				for(var index in objects){
					var object = objects[index];
					console.log(object);
					var inCollection = self.collection.get(object.id);
					if(inCollection){
						if(object.get('replaced')) self.collection.remove(object);
					}
					else{
						self.collection.add(object);
					}
				}
				self.collection.sort();
				buttonEl.attr('disabled',null);
				self.hideEditor();
				self.render();
				
			},
			error:function(object,error){
				console.log(error);
			}
		});
	},
	
	fetch:function(){
		if(!this.collection){
			var self = this;
			this.collection = new App.collections.Tasks();
			this.collection.comparator = function(object){
				var order = parseInt(object.get('order'),10);
				return order ? order : 1337;
			};
			this.collection.fetch({
				success:function(collection){
					self.collection = collection;
					self.render(true);
				},
				error:function(collection,error){
					console.log(error);
				}
			});
		}
		else this.render(true);
	},
	makeActive:function(type,id){
		this.fetch(type,id);
	},
	render:function(first){
		if(first) $(this.el).html(_.template($('#tplTasks').html(),{}));
		var groupedCollection = this.collection.groupBy(function(obj){
			return obj.get('type');
		});
		groupedCollection = {
			'Photos': groupedCollection['photo'],
			'Questions': groupedCollection['question']
		};
		$('#taskTable').html(_.template($('#tplTaskTable').html(),{groups:groupedCollection}));
		App.views.menu.removeLoadingScreen();
	}
});

/* **********************************************
     Begin users.js
********************************************** */

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

/* **********************************************
     Begin invitations.js
********************************************** */



/* **********************************************
     Begin faqs.js
********************************************** */

var faqModel = Parse.Object.extend('FAQ');
var faqCollectionQuery = new Parse.Query(faqModel);
faqCollectionQuery.descending('createdAt');
App.collections.Faqs = Parse.Collection.extend({
	model: faqModel,
	query: faqCollectionQuery
});

/* **********************************************
     Begin tasks.js
********************************************** */

var taskModel = Parse.Object.extend('Task');
var taskCollectionQuery = new Parse.Query(taskModel);
taskCollectionQuery.descending('createdAt');
taskCollectionQuery.doesNotExist('user');
taskCollectionQuery.doesNotExist('replaced');
App.collections.Tasks = Parse.Collection.extend({
	model: taskModel,
	query: taskCollectionQuery
});

/* **********************************************
     Begin chats.js
********************************************** */

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