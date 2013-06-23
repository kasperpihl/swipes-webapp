(function() {
  define(['view/list-view'], function(ListView) {
    return ListView.extend({
      el: "#schedule",
      renderList: function() {
        var itemsJSON;
        itemsJSON = new Backbone.Collection(swipy.collection.getScheduled()).toJSON();
        return this.$el.find('.list-wrap').html(this.listTmpl({
          items: itemsJSON
        }));
      }
    });
  });

}).call(this);
