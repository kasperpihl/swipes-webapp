(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(function() {
    var ViewController;
    return ViewController = (function() {
      function ViewController(opts) {
        this.updateNavigation = __bind(this.updateNavigation, this);
        this.init();
        this.navLinks = $('.list-nav a');
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
          return link.toggleClass('active', isCurrLink);
        });
      };

      ViewController.prototype.transitionViews = function(newViewSlug) {
        return console.log("Tranisiton between views to " + newViewSlug);
      };

      return ViewController;

    })();
  });

}).call(this);
