(function() {
  define(["underscore", "backbone", "jquery", "gsap", "timelinelite"], function(_, Backbone, $) {
    return Backbone.View.extend({
      shown: false,
      className: "sync-indicator",
      initialize: function() {
        _.bindAll(this, "checkStatus");
        this.render();
        return this.buildAnimationTimeline();
      },
      checkStatus: function() {
        if ($.active > 0) {
          return this.show();
        } else {
          return this.hide();
        }
      },
      buildAnimationTimeline: function() {
        var _this = this;
        this.tl = new TimelineLite({
          paused: true,
          onStart: function() {
            return TweenLite.set(_this.el, {
              display: "block"
            });
          },
          onComplete: function() {
            return TweenMax.fromTo(_this.$('.icon'), 1, {
              rotation: 0
            }, {
              rotation: 360,
              repeat: -1,
              transformOrigin: "55% 43%",
              ease: Power1.easeInOut
            });
          },
          onReverseComplete: function() {
            return TweenLite.set(_this.el, {
              display: "none"
            });
          }
        });
        this.tl.fromTo(this.$('.icon'), 0.3, {
          scale: 0,
          opacity: 0
        }, {
          scale: 1,
          opacity: 1
        });
        return this.tl.fromTo(this.$('.sync-text'), 0.2, {
          opacity: 0
        }, {
          opacity: 1
        });
      },
      show: function() {
        if (!!this.shown) {
          return;
        }
        $("body").addClass("syncing");
        this.tl.play();
        return this.shown = true;
      },
      hide: function() {
        if (!this.shown) {
          return;
        }
        $("body").removeClass("syncing");
        TweenMax.from(this.$('.icon'), 0.5, {
          rotation: 360,
          overwrite: "all"
        });
        this.tl.reverse();
        return this.shown = false;
      },
      getHTML: function() {
        return "<div class='icon-wrap'>\n	<div class=\"icon icon-repeat\"></div>\n</div>\n<p class='sync-text'>Syncing</p>";
      },
      render: function() {
        this.$el.html(this.getHTML());
        return TweenLite.set(this.el, {
          display: "none"
        });
      }
    });
  });

}).call(this);
