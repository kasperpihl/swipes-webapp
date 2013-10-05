(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.View.extend({
      events: {
        "submit form": "search",
        "keyup input": "search",
        "change input": "search"
      },
      initialize: function() {
        console.log("New Search Filter view created");
        return this.input = $("form input");
      },
      search: function(e) {
        var eventName, value;
        e.preventDefault();
        value = this.input.val();
        eventName = value.length ? "apply-filter" : "remove-filter";
        return Backbone.trigger(eventName, "search", value.toLowerCase());
      }
    });
  });

}).call(this);
