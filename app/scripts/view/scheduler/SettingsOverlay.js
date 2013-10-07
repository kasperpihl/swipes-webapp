(function() {
  define(["underscore", "backbone", "view/Overlay", "text!templates/settings-overlay.html"], function(_, Backbone, Overlay, SettingsOverlayTmpl) {
    return Overlay.extend({
      className: 'overlay settings',
      initialize: function() {
        Overlay.prototype.initialize.apply(this, arguments);
        this.showClassName = "settings-open";
        return this.hideClassName = "hide-settings";
      },
      bindEvents: function() {
        _.bindAll(this, "handleResize");
        return $(window).on("resize", this.handleResize);
      },
      setTemplate: function() {
        return this.template = _.template(SettingsOverlayTmpl);
      },
      render: function() {
        var html;
        html = this.template({});
        this.$el.html(html);
        return this;
      },
      afterShow: function() {
        return this.handleResize();
      },
      handleResize: function() {
        var content, offset;
        if (!this.shown) {
          return;
        }
        content = this.$el.find(".overlay-content");
        offset = (window.innerHeight / 2) - (content.height() / 2);
        return content.css("margin-top", offset);
      }
    });
  });

}).call(this);
