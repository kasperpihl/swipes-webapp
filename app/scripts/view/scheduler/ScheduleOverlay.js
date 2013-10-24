(function() {
  define(["underscore", "backbone", "view/Overlay", "text!templates/schedule-overlay.html"], function(_, Backbone, Overlay, ScheduleOverlayTmpl) {
    return Overlay.extend({
      className: 'overlay scheduler',
      events: {
        "click .grid > a:not(.disabled)": "selectOption",
        "click .overlay-bg": "hide",
        "click .date-picker .back": "hideDatePicker"
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
        var option;
        option = e.currentTarget.getAttribute('data-option');
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
          return require(["view/modules/DatePicker"], function(DatePicker) {
            _this.datePicker = new DatePicker();
            _this.$el.find(".overlay-content").append(_this.datePicker.el);
            return _this.$el.addClass("show-datepicker");
          });
        } else {
          return this.$el.addClass("show-datepicker");
        }
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
