(function() {
  define(["jquery", "backbone", "js/model/ClockWork", "js/controller/ViewController", "js/controller/AnalyticsController", "js/router/MainRouter", "js/collection/ToDoCollection", "js/collection/TagCollection", "js/view/nav/ListNavigation", "js/controller/TaskInputController", "js/controller/SidebarController", "js/controller/ScheduleController", "js/controller/FilterController", "js/controller/SettingsController", "js/controller/ErrorController", "js/controller/SyncController", "gsap"], function($, Backbone, ClockWork, ViewController, AnalyticsController, MainRouter, ToDoCollection, TagCollection, ListNavigation, TaskInputController, SidebarController, ScheduleController, FilterController, SettingsController, ErrorController, SyncController) {
    var Swipes;
    return Swipes = (function() {
      Swipes.prototype.UPDATE_INTERVAL = 30;

      Swipes.prototype.UPDATE_COUNT = 0;

      function Swipes() {
        Backbone.once("sync-complete", this.init, this);
        this.analytics = new AnalyticsController();
        this.errors = new ErrorController();
        this.todos = new ToDoCollection();
        this.tags = new TagCollection();
        this.sync = new SyncController();
        this.updateTimer = new ClockWork();
        $(window).focus(this.fetchTodos);
      }

      Swipes.prototype.isBusy = function() {
        var tag, task, _i, _j, _len, _len1, _ref, _ref1;
        if (this.todos.length != null) {
          _ref = this.todos.models;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            task = _ref[_i];
            if (task._saving) {
              return true;
            }
          }
        }
        if (this.tags.length != null) {
          _ref1 = this.tags.models;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            tag = _ref1[_j];
            if (tag._saving) {
              return true;
            }
          }
        }
        if (location.href.indexOf("edit/") !== -1) {
          return true;
        }
        if (this.todos.length) {
          if (this.todos.where({
            selected: true
          }).length) {
            return true;
          }
        }
        return false;
      };

      /*hackParseAPI: ->
      			# Add missing mehods to Parse.Collection.prototype
      			for method in ["where", "findWhere"]
      				if not Parse.Collection::[method]?
      					Parse.Collection::[method] = Backbone.Collection::[method]
      */


      Swipes.prototype.init = function() {
        this.cleanUp();
        this.viewController = new ViewController();
        this.nav = new ListNavigation();
        this.router = new MainRouter();
        this.scheduler = new ScheduleController();
        this.input = new TaskInputController();
        this.sidebar = new SidebarController();
        this.filter = new FilterController();
        this.settings = new SettingsController();
        Backbone.history.start({
          pushState: false
        });
        return $("body").removeClass("loading");
      };

      /*update: ->
      			if not @isBusy()
      				@fetchTodos()
      				@UPDATE_COUNT++
      
      			@lastUpdate = new Date()
      			TweenLite.delayedCall( @UPDATE_INTERVAL, @update, null, @ )
      		startAutoUpdate: ->
      			TweenLite.delayedCall( @UPDATE_INTERVAL, @update, null, @ )
      		stopAutoUpdate: ->
      			TweenLite.killDelayedCallsTo @update
      */


      Swipes.prototype.cleanUp = function() {
        var _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7;
        if ((_ref = this.viewController) != null) {
          _ref.destroy();
        }
        if ((_ref1 = this.nav) != null) {
          _ref1.destroy();
        }
        if ((_ref2 = this.router) != null) {
          _ref2.destroy();
        }
        if ((_ref3 = this.scheduler) != null) {
          _ref3.destroy();
        }
        if ((_ref4 = this.input) != null) {
          _ref4.destroy();
        }
        if ((_ref5 = this.sidebar) != null) {
          _ref5.destroy();
        }
        if ((_ref6 = this.filter) != null) {
          _ref6.destroy();
        }
        if ((_ref7 = this.settings) != null) {
          _ref7.destroy();
        }
        if (Parse.History.started) {
          return Parse.history.stop();
        }
      };

      Swipes.prototype.fetchTodos = function() {
        return swipy.sync.sync();
      };

      return Swipes;

    })();
  });

}).call(this);
