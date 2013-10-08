(function() {
  define(["underscore", "backbone", "gsap"], function(_, Backbone, TweenLite) {
    return Backbone.View.extend({
      tagName: "article",
      initialize: function() {
        this.setTemplate();
        return this.render();
      },
      setTemplate: function() {},
      render: function() {
        if (this.template != null) {
          this.$el.html(this.template({}));
        }
        return this.transitionIn();
      },
      transitionIn: function() {
        return TweenLite.fromTo(this.$el, 0.2, {
          alpha: 0
        }, {
          alpha: 1
        });
      },
      transitionOut: function() {
        var dfd;
        dfd = new $.Deferred();
        TweenLite.to(this.$el, 0.2, {
          alpha: 0,
          onComplete: dfd.resolve
        });
        return dfd.promise();
      },
      cleanUp: function() {
        this.stopListening();
        this.undelegateEvents();
        return this.$el.remove();
      },
      remove: function() {
        var dfd,
          _this = this;
        dfd = new $.Deferred();
        this.transitionOut().then(function() {
          _this.cleanUp();
          return dfd.resolve();
        });
        return dfd.promise();
      }
    });
  });

}).call(this);
