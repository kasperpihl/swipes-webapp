(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["gsap"], function(TweenLite) {
    var ViewController;
    return ViewController = (function() {
      function ViewController(opts) {
        this.updateNavigation = __bind(this.updateNavigation, this);
        this.init();
        this.navLinks = $(".list-nav a");
      }

      ViewController.prototype.init = function() {
        var _this = this;
        return $(document).on('navigate/page', function(e, slug) {
          return _this.goto(slug);
        });
      };

      ViewController.prototype.goto = function(slug) {
        this.updateNavigation(slug);
        return this.transitionViews(slug);
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
        var dfd, opts,
          _this = this;
        dfd = new $.Deferred();
        opts = {
          alpha: 1,
          onComplete: function() {
            return dfd.resolve();
          }
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
