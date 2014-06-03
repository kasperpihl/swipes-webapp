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