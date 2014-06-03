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