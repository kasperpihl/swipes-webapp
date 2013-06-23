(function() {
  define(['view/list-view'], function(ListView) {
    return ListView.extend({
      el: "#completed",
      renderList: function() {
        var itemsJSON;
        itemsJSON = new Backbone.Collection(swipy.collection.getCompleted()).toJSON();
        return this.$el.find('.list-wrap').html(this.listTmpl({
          items: itemsJSON
        }));
      }
    });
  });

}).call(this);
