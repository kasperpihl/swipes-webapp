(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["backbone", "gsap"], function(Backbone, TweenLite) {
    var ViewController;
    return ViewController = (function() {
      function ViewController(opts) {
        this.updateNavigation = __bind(this.updateNavigation, this);
        this.init();
        this.navLinks = $(".list-nav a");
      }

      ViewController.prototype.init = function() {
        var _this = this;
        Backbone.on('navigate/view', function(slug) {
          return _this.goto(slug);
        });
        return Backbone.on('edit/task', function(taskId) {
          return _this.editTask(taskId);
        });
      };

      ViewController.prototype.goto = function(slug) {
        console.log("Go to " + slug);
        this.updateNavigation(slug);
        return this.transitionViews(slug);
      };

      ViewController.prototype.editTask = function(taskId) {
        var m, model, _i, _len, _ref,
          _this = this;
        _ref = swipy.todos.models;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          m = _ref[_i];
          if (m.cid === taskId) {
            model = m;
          }
        }
        if (model == null) {
          return console.warn("Model with id " + taskId + " couldn't be foudn");
        }
        if (this.currView != null) {
          return this.transitionOut(this.currView).then(function() {
            return require(["view/list/EditTask"], function(EditTaskView) {
              var editView;
              editView = new EditTaskView({
                model: model
              });
              $("#main-content").prepend(editView.el);
              return _this.transitionIn(editView);
            });
          });
        } else {
          return require(["view/list/EditTask"], function(EditTaskView) {
            var editView;
            editView = new EditTaskView({
              model: model
            });
            $("#main-content").prepend(editView.el);
            return _this.transitionIn(editView);
          });
        }
      };

      ViewController.prototype.updateNavigation = function(slug) {
        return this.navLinks.each(function() {
          var isCurrLink, link;
          link = $(this);
          isCurrLink = link.attr("href").slice(1) === slug ? true : false;
          return link.toggleClass("active", isCurrLink);
        });
      };

      ViewController.prototype.transitionViews = function(slug) {
        var viewName,
          _this = this;
        viewName = slug[0].toUpperCase() + slug.slice(1);
        return require(["view/" + viewName], function(View) {
          var newView;
          newView = new View({
            el: "ol.todo-list." + slug
          });
          if (_this.currView != null) {
            return _this.transitionOut(_this.currView).then(function() {
              return _this.transitionIn(newView);
            });
          } else {
            return _this.transitionIn(newView);
          }
        });
      };

      ViewController.prototype.transitionOut = function(view) {
        var dfd, opts,
          _this = this;
        dfd = new $.Deferred();
        opts = {
          alpha: 0,
          onComplete: function() {
            view.$el.addClass("hidden");
            view.cleanUp();
            return dfd.resolve();
          }
        };
        TweenLite.to(view.$el, 0.15, opts);
        return dfd.promise();
      };

      ViewController.prototype.transitionIn = function(view) {
        var dfd, opts;
        dfd = new $.Deferred();
        opts = {
          alpha: 1,
          onComplete: dfd.resolve
        };
        view.$el.removeClass("hidden");
        TweenLite.fromTo(view.$el, 0.4, {
          alpha: 0
        }, opts);
        this.currView = view;
        return dfd.promise();
      };

      return ViewController;

    })();
  });

}).call(this);
