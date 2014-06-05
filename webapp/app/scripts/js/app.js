(function() {
  define(["backbone", "js/model/ClockWork", "js/controller/ViewController", "js/controller/AnalyticsController", "js/router/MainRouter", "js/collection/ToDoCollection", "js/collection/TagCollection", "js/view/nav/ListNavigation", "js/controller/TaskInputController", "js/controller/SidebarController", "js/controller/ScheduleController", "js/controller/FilterController", "js/controller/SettingsController", "js/controller/ErrorController", "js/controller/SyncQueue", "js/controller/SyncController", "gsap", "localytics-sdk"], function(Backbone, ClockWork, ViewController, AnalyticsController, MainRouter, ToDoCollection, TagCollection, ListNavigation, TaskInputController, SidebarController, ScheduleController, FilterController, SettingsController, ErrorController, SyncQueue, SyncController) {
    var Swipes;
    return Swipes = (function() {
      Swipes.prototype.UPDATE_INTERVAL = 30;

      Swipes.prototype.UPDATE_COUNT = 0;

      function Swipes() {
        this.hackParseAPI();
        this.queue = new SyncQueue();
        this.analytics = new AnalyticsController();
        this.errors = new ErrorController();
        this.todos = new ToDoCollection();
        this.updateTimer = new ClockWork();
        this.tags = new TagCollection();
        this.tags.once("reset", this.init, this);
        this.sync = new SyncController();
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
        if (this.queue.isBusy()) {
          return true;
        }
        return false;
      };

      Swipes.prototype.hackParseAPI = function() {
        var method, _i, _len, _ref, _results;
        _ref = ["where", "findWhere"];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          method = _ref[_i];
          if (Parse.Collection.prototype[method] == null) {
            _results.push(Parse.Collection.prototype[method] = Backbone.Collection.prototype[method]);
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };

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
        Parse.history.start({
          pushState: false
        });
        $("body").removeClass("loading");
        return this.startAutoUpdate();
      };

      Swipes.prototype.update = function() {
        if (!this.isBusy()) {
          this.fetchTodos();
          this.UPDATE_COUNT++;
        }
        this.lastUpdate = new Date();
        return TweenLite.delayedCall(this.UPDATE_INTERVAL, this.update, null, this);
      };

      Swipes.prototype.startAutoUpdate = function() {
        return TweenLite.delayedCall(this.UPDATE_INTERVAL, this.update, null, this);
      };

      Swipes.prototype.stopAutoUpdate = function() {
        return TweenLite.killDelayedCallsTo(this.update);
      };

      Swipes.prototype.cleanUp = function() {
        var _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8;
        this.stopAutoUpdate();
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
        if ((_ref8 = this.queue) != null) {
          _ref8.destroy();
        }
        if (Parse.History.started) {
          return Parse.history.stop();
        }
      };

      Swipes.prototype.fetchTodos = function() {
        return this.sync.sync();
      };

      return Swipes;

    })();
  });

}).call(this);
