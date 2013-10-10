(function() {
  define(["view/settings/BaseSubview", "gsap-draggable", "slider-control", "text!templates/settings-snoozes.html"], function(BaseView, Draggable, SliderControl, Tmpl) {
    return BaseView.extend({
      className: "snoozes",
      events: {
        "click button": "toggleSection"
      },
      initialize: function() {
        BaseView.prototype.initialize.apply(this, arguments);
        return this.setupSliders();
      },
      getPercentFromTime: function(hour, minute) {
        return 0.8;
      },
      getSliderVal: function(sliderId) {
        var snoozes;
        snoozes = swipy.settings.get("snoozes");
        switch (sliderId) {
          case "start-day":
            return this.getPercentFromTime(snoozes.weekday.morning.hour, snoozes.weekday.morning.minute);
        }
      },
      setupSliders: function() {
        var startDayEl, startDayOpts, startDaySlider;
        startDayOpts = {};
        startDayEl = this.el.querySelector(".day .range-slider");
        return startDaySlider = new SliderControl(startDayEl, startDayOpts, this.getSliderVal("start-day"));
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
