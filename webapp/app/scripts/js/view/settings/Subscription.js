(function() {
  define(["js/view/settings/BaseSubview", "text!templates/settings-subscription.html"], function(BaseView, Tmpl) {
    return BaseView.extend({
      className: "subscription",
      setTemplate: function() {
        return this.template = _.template(Tmpl);
      }
    });
  });

}).call(this);
