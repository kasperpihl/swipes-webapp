(function() {
  define(["backbone", "model/ClockWork", "controller/ViewController", "controller/AnalyticsController", "router/MainRouter", "collection/ToDoCollection", "collection/TagCollection", "view/nav/ListNavigation", "controller/TaskInputController", "controller/SidebarController", "controller/ScheduleController", "controller/FilterController", "controller/SettingsController", "controller/ErrorController", "controller/SyncQueue", "gsap", "localytics-sdk"], function(Backbone, ClockWork, ViewController, AnalyticsController, MainRouter, ToDoCollection, TagCollection, ListNavigation, TaskInputController, SidebarController, ScheduleController, FilterController, SettingsController, ErrorController, SyncQueue) {
    var Swipes;
    return Swipes = (function() {
      Swipes.prototype.UPDATE_INTERVAL = 30;

      Swipes.prototype.UPDATE_COUNT = 0;

      function Swipes() {
        var _this = this;
        this.hackParseAPI();
        this.queue = new SyncQueue();
        this.analytics = new AnalyticsController();
        this.errors = new ErrorController();
        this.todos = new ToDoCollection();
        this.updateTimer = new ClockWork();
        this.tags = new TagCollection();
        this.tags.once("reset", function() {
          return _this.fetchTodos();
        });
        this.todos.once("reset", this.init, this);
        this.tags.fetch();
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
        var _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
        this.stopAutoUpdate();
        if ((_ref = this.tags) != null) {
          _ref.destroy();
        }
        if ((_ref1 = this.viewController) != null) {
          _ref1.destroy();
        }
        if ((_ref2 = this.nav) != null) {
          _ref2.destroy();
        }
        if ((_ref3 = this.router) != null) {
          _ref3.destroy();
        }
        if ((_ref4 = this.scheduler) != null) {
          _ref4.destroy();
        }
        if ((_ref5 = this.input) != null) {
          _ref5.destroy();
        }
        if ((_ref6 = this.sidebar) != null) {
          _ref6.destroy();
        }
        if ((_ref7 = this.filter) != null) {
          _ref7.destroy();
        }
        if ((_ref8 = this.settings) != null) {
          _ref8.destroy();
        }
        if ((_ref9 = this.queue) != null) {
          _ref9.destroy();
        }
        if (Parse.History.started) {
          return Parse.history.stop();
        }
      };

      Swipes.prototype.fetchTodos = function() {
        return this.todos.fetch();
      };

      return Swipes;

    })();
  });

}).call(this);