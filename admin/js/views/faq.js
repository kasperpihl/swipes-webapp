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