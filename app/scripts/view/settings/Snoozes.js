(function() {
  define(["view/settings/BaseSubview", "text!templates/settings-snoozes.html"], function(BaseView, Tmpl) {
    return BaseView.extend({
      className: "snoozes",
      setTemplate: function() {
        return this.template = _.template(Tmpl);
      }
    });
  });

}).call(this);
