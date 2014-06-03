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