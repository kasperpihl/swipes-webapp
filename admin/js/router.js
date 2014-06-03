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