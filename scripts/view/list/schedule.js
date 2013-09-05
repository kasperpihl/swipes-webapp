(function() {
  define(['view/list-view'], function(ListView) {
    return ListView.extend({
      el: "#schedule",
      renderList: function() {
        var items;
        items = new Backbone.Collection(swipy.collection.getScheduled());
        this.$el.find('.list-wrap').html(this.listTmpl({
          items: items.toJSON()
        }));
        return this.afterRenderList(items);
      }
    });
  });

}).call(this);
