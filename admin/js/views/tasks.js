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