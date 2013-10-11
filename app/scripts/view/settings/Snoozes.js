(function() {
  define(["view/settings/BaseSubview", "gsap-draggable", "slider-control", "text!templates/settings-snoozes.html"], function(BaseView, Draggable, SliderControl, Tmpl) {
    return BaseView.extend({
      className: "snoozes",
      events: {
        "click button": "toggleSection"
      },
      initialize: function() {
        BaseView.prototype.initialize.apply(this, arguments);
        _.bindAll(this, "setupSliders", "updateStartDay");
        this.transitionInDfd.then(this.setupSliders);
        return this.listenTo(swipy.settings.model, "change:snoozes", this.render);
      },
      getFloatFromTime: function(hour, minute) {
        return 0.8;
      },
      getTimeFromFloat: function(val) {
        return {
          hour: 23,
          minute: 0
        };
      },
      getSliderVal: function(sliderId) {
        var snoozes;
        snoozes = swipy.settings.get("snoozes");
        switch (sliderId) {
          case "start-day":
            return this.getFloatFromTime(snoozes.weekday.morning.hour, snoozes.weekday.morning.minute);
        }
      },
      setupSliders: function() {
        var startDayEl, startDayOpts;
        startDayOpts = {
          onDrag: this.updateStartDay,
          onDragEnd: this.updateStartDay
        };
        startDayEl = this.el.querySelector(".day .range-slider");
        return this.startDaySlider = new SliderControl(startDayEl, startDayOpts, this.getSliderVal("start-day"));
      },
      updateStartDay: function() {
        return console.log(this.startDaySlider.value);
      },
      setTemplate: function() {
        return this.template = _.template(Tmpl);
      },
      render: function() {
        console.log("Rendering snoozes");
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
