(function() {
  define(function() {
    return Parse.Object.extend({
      className: "Tag",
      defaults: {
        title: "",
        deleted: false
      }
    });
  });

}).call(this);
