(function() {
  define(["js/view/settings/BaseSubview", "text!templates/settings-support.html"], function(BaseView, Tmpl) {
    return BaseView.extend({
      className: "support",
      setTemplate: function() {
        return this.template = _.template(Tmpl);
      }
    });
  });

}).call(this);
