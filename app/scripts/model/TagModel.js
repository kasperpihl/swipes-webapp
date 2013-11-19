(function() {
  define(function() {
    return Parse.Object.extend({
      className: "Tag",
      defaults: {
        title: "",
        deleted: false
      },
      initialize: function() {
        return console.log("wtf?");
      }
    });
  });

}).call(this);
