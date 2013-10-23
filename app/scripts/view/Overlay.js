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
        this.showClassName = "overlay-open";
        this.hideClassName = "hide-overlay";
        return $(document).on('keyup.overlay', function(e) {
          if (e.keyCode === 27 && _this.$el.html) {
            return _this.hide(true);
          }
        });
      },
      setTemplate: function() {},
      bindEvents: function() {},
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
        $("body").removeClass(this.hideClassName);
        if (this.hideTimer != null) {
          clearTimeout(this.hideTimer);
        }
        $("body").toggleClass(this.showClassName, true);
        return this.afterShow();
      },
      afterShow: function() {},
      hide: function(cancelled) {
        var dfd,
          _this = this;
        if (cancelled == null) {
          cancelled = false;
        }
        dfd = new $.Deferred();
        if (!this.shown) {
          dfd.resolve();
          return dfd.promise();
        }
        this.shown = false;
        $("body").addClass(this.hideClassName);
        this.hideTimer = setTimeout(function() {
          $("body").toggleClass(_this.showClassName, false);
          _this.afterHide();
          return dfd.resolve();
        }, 400);
        return dfd.promise();
      },
      afterHide: function() {},
      cleanUp: function() {
        this.stopListening();
        return $(document).off(".overlay");
      },
      destroy: function() {
        var _this = this;
        return this.hide().done(function() {
          _this.cleanUp();
          return _this.$el.remove();
        });
      }
    });
  });

}).call(this);
