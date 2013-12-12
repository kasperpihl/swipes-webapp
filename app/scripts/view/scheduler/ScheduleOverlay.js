(function() {
  define(["underscore", "backbone", "view/Overlay", "text!templates/schedule-overlay.html"], function(_, Backbone, Overlay, ScheduleOverlayTmpl) {
    return Overlay.extend({
      className: 'overlay scheduler',
      events: {
        "click .grid > a:not(.disabled)": "selectOption",
        "click .overlay-bg": "hide",
        "click .date-picker .back": "hideDatePicker",
        "click .date-picker .save": "selectOption"
      },
      initialize: function() {
        Overlay.prototype.initialize.apply(this, arguments);
        this.showClassName = "scheduler-open";
        return this.hideClassName = "hide-scheduler";
      },
      bindEvents: function() {
        _.bindAll(this, "handleResize");
        return $(window).on("resize", this.handleResize);
      },
      setTemplate: function() {
        return this.template = _.template(ScheduleOverlayTmpl);
      },
      render: function() {
        var html;
        if (this.template) {
          html = this.template(this.model.toJSON());
          this.$el.html(html);
        }
        return this;
      },
      afterShow: function() {
        return this.handleResize();
      },
      selectOption: function(e) {
        var moment, option, target, time;
        target = $(e.currentTarget);
        if (target.hasClass("save") && (this.datePicker != null)) {
          moment = this.datePicker.calendar.selectedDay;
          time = this.datePicker.model.get("time");
          moment.millisecond(0);
          moment.second(0);
          moment.hour(time.hour);
          moment.minute(time.minute);
          option = moment;
          this.hideDatePicker();
        } else {
          option = target.attr("data-option");
        }
        return Backbone.trigger("pick-schedule-option", option);
      },
      hide: function(cancelled) {
        if (cancelled == null) {
          cancelled = true;
        }
        if (cancelled && (this.currentTasks != null)) {
          Backbone.trigger("scheduler-cancelled", this.currentTasks);
        }
        return Overlay.prototype.hide.apply(this, arguments);
      },
      showDatePicker: function() {
        var _this = this;
        if (this.datePicker == null) {
          require(["view/modules/DatePicker"], function(DatePicker) {
            _this.datePicker = new DatePicker();
            _this.$el.find(".overlay-content").append(_this.datePicker.el);
            _this.$el.addClass("show-datepicker");
            return _this.datePicker.render();
          });
        } else {
          this.$el.addClass("show-datepicker");
        }
        return setTimeout(function() {
          return _this.handleResize();
        }, 100);
      },
      hideDatePicker: function() {
        return this.$el.removeClass("show-datepicker");
      },
      handleResize: function() {
        var content, offset;
        if (!this.shown) {
          return;
        }
        content = this.$el.find(".overlay-content");
        offset = (window.innerHeight / 2) - (content.height() / 2);
        return content.css("margin-top", offset);
      },
      cleanUp: function() {
        $(window).off("resize", this.handleResize);
        this.datePicker.remove();
        return Overlay.prototype.cleanUp.apply(this, arguments);
      }
    });
  });

}).call(this);
