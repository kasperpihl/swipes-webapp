(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["jquery", "backbone"], function($, Backbone) {
    var ListNavigation;
    return ListNavigation = (function() {
      function ListNavigation() {
        this.updateNavigation = __bind(this.updateNavigation, this);
        this.handleClick = __bind(this.handleClick, this);
        this.navLinks = $(".list-nav a");
        this.navLinks.on("click", this.handleClick);
        Backbone.on("navigate/view", this.updateNavigation, this);
      }

      ListNavigation.prototype.handleClick = function(e) {
        e.preventDefault();
        return swipy.router.navigate(e.currentTarget.hash.slice(1), true);
      };

      ListNavigation.prototype.updateNavigation = function(slug) {
        return this.navLinks.each(function() {
          var isCurrLink, link;
          link = $(this);
          isCurrLink = link.attr("href").slice(1) === slug ? true : false;
          return link.toggleClass("active", isCurrLink);
        });
      };

      return ListNavigation;

    })();
  });

}).call(this);
