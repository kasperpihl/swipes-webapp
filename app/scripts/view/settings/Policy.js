(function() {
  define(["view/settings/BaseSubview", "text!templates/settings-policy.html"], function(BaseView, Tmpl) {
    return BaseView.extend({
      className: "policy",
      setTemplate: function() {
        return this.template = _.template(Tmpl);
      }
    });
  });

}).call(this);
