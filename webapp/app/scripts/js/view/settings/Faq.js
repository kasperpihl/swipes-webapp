(function() {
  define(["js/view/settings/BaseSubview", "gsap", "text!templates/settings-faq.html"], function(BaseView, TweenLite, Tmpl) {
    return BaseView.extend({
      className: "faq",
      events: {
        "click header": "toggleQuestion"
      },
      setTemplate: function() {
        return this.template = _.template(Tmpl);
      },
      render: function() {
        BaseView.prototype.render.apply(this, arguments);
        return this.$el.find("li section").each(function() {
          return TweenLite.set($(this), {
            rotationX: -90,
            marginBottom: 0,
            display: "none"
          });
        });
      },
      toggleQuestion: function(e) {
        var li;
        li = $(e.currentTarget.parentNode).toggleClass("toggled");
        if (li.hasClass("toggled")) {
          return TweenLite.to(li.find("section"), 0.55, {
            alpha: 1,
            height: "auto",
            marginBottom: "3.2em",
            rotationX: 0,
            display: "block",
            ease: Back.easeOut
          });
        } else {
          return TweenLite.to(li.find("section"), 0.2, {
            alpha: 0,
            height: 0,
            marginBottom: 0,
            rotationX: -90,
            display: "none"
          });
        }
      }
    });
  });

}).call(this);
