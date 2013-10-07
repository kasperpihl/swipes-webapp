(function() {
  define(["underscore", "backbone", "view/Overlay", "text!templates/schedule-overlay.html"], function(_, Backbone, Overlay, ScheduleOverlayTmpl) {
    return Overlay.extend({
      className: 'overlay scheduler',
      events: {
        "click .grid > a:not(.disabled)": "selectOption"
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
        if (cancelled && (this.currentTasks != null)) {
          Backbone.trigger("scheduler-cancelled", this.currentTasks);
        }
        return Overlay.prototype.hide.apply(this, arguments);
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
        $(window).off();
        return Overlay.prototype.cleanUp.apply(this, arguments);
      }
    });
  });

}).call(this);
