(function() {
  define(["view/List"], function(ListView) {
    return ListView.extend({
      init: function() {
        return console.log("init'ing list view");
      }
    });
  });

}).call(this);
