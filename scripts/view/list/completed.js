(function() {
  define(["view/list/List"], function(ListView) {
    return ListView.extend({
      el: "#completed",
      renderList: function() {
        var items;
        console.warn("Rendering completed todo list");
        items = new Backbone.Collection(swipy.collection.getCompleted());
        this.$el.find('.list-wrap').html(this.listTmpl({
          items: items.toJSON()
        }));
        return this.afterRenderList(items);
      }
    });
  });

}).call(this);
