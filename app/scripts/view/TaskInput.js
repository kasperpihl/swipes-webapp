(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.View.extend({
      el: "#add-task",
      events: {
        "submit": "triggerAddTask",
        "keyup input": "resizeText"
      },
      initialize: function() {
        this.input = this.$el.find("input");
        _.bindAll(this, "resizeText");
        return $(window).on("resize.taskinput", this.resizeText);
      },
      triggerAddTask: function(e) {
        e.preventDefault();
        if (this.input.val() === "") {
          return;
        }
        Backbone.trigger("create-task", this.input.val());
        return this.input.val("");
      },
      getFontSizeRange: function() {
        if (window.innerHeight < 768) {
          return {
            min: 20,
            max: 40,
            charLimit: 20,
            minChars: 8
          };
        } else if (window.innerHeight < 1024) {
          return {
            min: 35,
            max: 70,
            charLimit: 24,
            minChars: 15
          };
        } else {
          return {
            min: 35,
            max: 100,
            charLimit: 20,
            minChars: 15
          };
        }
      },
      getFontSize: function() {
        var diff, numChars, range, shrinkage;
        numChars = this.input.val().length;
        range = this.getFontSizeRange();
        if (numChars < range.minChars) {
          return "";
        }
        shrinkage = (numChars - range.minChars) / range.charLimit;
        diff = range.max - range.min;
        return Math.max(range.max - (diff * shrinkage), range.min);
      },
      resizeText: function() {
        return this.input.css("font-size", this.getFontSize());
      },
      remove: function() {
        this.undelegateEvents();
        this.$el.remove();
        return $(window).off("resize.taskinput");
      }
    });
  });

}).call(this);
