(function() {
  define(["backbone"], function(Backbone) {
    return Backbone.View.extend({
      tagName: 'article',
      className: 'overlay',
      events: {
        "click a.close": "hide"
      },
      initialize: function() {
        var _this = this;
        this.setTemplate();
        this.bindEvents();
        this.init();
        return $(document).on('keyup', function(e) {
          if (e.keyCode === 27 && _this.$el.html) {
            return _this.hide(true);
          }
        });
      },
      setTemplate: function() {},
      bindEvents: function() {},
      init: function() {},
      render: function() {
        var html;
        if (this.template) {
          html = this.template({});
          this.$el.html(html);
        }
        return this;
      },
      show: function() {
        if (this.shown) {
          return;
        }
        this.shown = true;
        $("body").removeClass("hide-overlay");
        if (this.hideTimer != null) {
          clearTimeout(this.hideTimer);
        }
        $("body").toggleClass('overlay-open', true);
        return this.afterShow();
      },
      afterShow: function() {},
      hide: function(cancelled) {
        var _this = this;
        if (cancelled == null) {
          cancelled = false;
        }
        if (!this.shown) {
          return;
        }
        this.shown = false;
        $("body").addClass("hide-overlay");
        return this.hideTimer = setTimeout(function() {
          $("body").toggleClass('overlay-open', false);
          return _this.afterHide();
        }, 400);
      },
      afterHide: function() {},
      cleanUp: function() {
        this.stopListening();
        return $(document).off();
      },
      destroy: function() {
        var _this = this;
        return this.hide().done(function() {
          _this.cleanUp();
          return _this.$el.empty();
        });
      }
    });
  });

}).call(this);
