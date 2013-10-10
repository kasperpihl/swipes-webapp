(function() {
  define(["view/settings/BaseSubview", "text!templates/settings-snoozes.html"], function(BaseView, Tmpl) {
    return BaseView.extend({
      className: "snoozes",
      events: {
        "click button": "toggleSection"
      },
      setTemplate: function() {
        return this.template = _.template(Tmpl);
      },
      render: function() {
        this.$el.html(this.template({
          snoozes: swipy.settings.get("snoozes")
        }));
        return this.transitionIn();
      },
      toggleSection: function(e) {
        return $(e.currentTarget.parentNode.parentNode).toggleClass("toggled");
      }
    });
  });

}).call(this);
