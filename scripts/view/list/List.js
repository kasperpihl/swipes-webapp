(function() {
  define(['view/default-view', 'view/listitem-view'], function(DefaultView, ListItemView) {
    return DefaultView.extend({
      init: function() {
        this.listTmpl = _.template($("#template-list").html());
        return swipy.collection.on("change", this.renderList, this);
      },
      render: function() {
        return this.renderList();
      },
      renderList: function() {
        var items;
        items = new Backbone.Collection(swipy.collection.getActive());
        this.$el.find('.list-wrap').html(this.listTmpl({
          items: items.toJSON()
        }));
        return this.afterRenderList(items);
      },
      afterRenderList: function(models) {
        var _this = this;
        return this.$el.find('ol.todo > li').each(function(i, el) {
          return new ListItemView({
            el: el,
            model: models.at(i)
          });
        });
      },
      customCleanUp: function() {
        return swipy.collection.off();
      }
    });
  });

}).call(this);
