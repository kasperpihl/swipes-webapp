(function() {
  define(["underscore", "backbone", "view/Overlay", "text!templates/settings-overlay.html"], function(_, Backbone, Overlay, SettingsOverlayTmpl) {
    return Overlay.extend({
      className: 'overlay settings',
      bindEvents: function() {},
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
        return $("body").addClass("settings-open");
      },
      afterHide: function() {
        return $("body").removeClass("settings-open");
      }
    });
  });

}).call(this);
