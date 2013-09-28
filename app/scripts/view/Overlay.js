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
            return _this.hide();
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
        $("body").toggleClass('overlay-open', true);
        return this.afterShow();
      },
      afterShow: function() {},
      hide: function() {
        if (!this.shown) {
          return;
        }
        this.shown = false;
        $("body").toggleClass('overlay-open', false);
        return this.afterHide();
      },
      afterHide: function() {},
      destroy: function() {
        var _this = this;
        return this.hide().done(function() {
          _this.stopListening();
          $(document).off();
          return _this.$el.empty();
        });
      }
    });
  });

}).call(this);
