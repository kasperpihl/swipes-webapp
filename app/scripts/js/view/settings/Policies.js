(function() {
  define(["js/view/settings/BaseSubview", "text!templates/settings-policies.html"], function(BaseView, Tmpl) {
    return BaseView.extend({
      className: "policy",
      setTemplate: function() {
        return this.template = _.template(Tmpl);
      }
    });
  });

}).call(this);
