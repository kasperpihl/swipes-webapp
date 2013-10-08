(function() {
  define(["view/settings/BaseSubview", "text!templates/settings-faq.html"], function(BaseView, Tmpl) {
    return BaseView.extend({
      className: "faq",
      setTemplate: function() {
        return this.template = _.template(Tmpl);
      }
    });
  });

}).call(this);
