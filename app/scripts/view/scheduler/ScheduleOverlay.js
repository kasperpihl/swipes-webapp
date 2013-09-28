(function() {
  define(["underscore", "backbone", "view/Overlay", "text!templates/schedule-overlay.html"], function(_, Backbone, Overlay, ScheduleOverlayTmpl) {
    return Overlay.extend({
      className: 'overlay scheduler',
      bindEvents: function() {},
      init: function() {
        return console.log("New Schedule Overlay created");
      },
      setTemplate: function() {
        return this.template = _.template(ScheduleOverlayTmpl);
      },
      afterShow: function() {
        return console.log("Schedule overlay shown");
      }
    });
  });

}).call(this);
