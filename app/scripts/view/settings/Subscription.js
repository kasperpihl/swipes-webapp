(function() {
  define(["view/settings/BaseSubview", "text!templates/settings-subscription.html"], function(BaseView, Tmpl) {
    return BaseView.extend({
      setTemplate: function() {
        return this.template = _.template(Tmpl);
      }
    });
  });

}).call(this);
