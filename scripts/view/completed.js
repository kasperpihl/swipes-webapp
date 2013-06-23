(function() {
  define(['view/default-view'], function(DefaultView) {
    return DefaultView.extend({
      init: function() {
        this.listTmpl = _.template($('#template-list').html());
        return swipy.collection.on('change', this.renderList, this);
      },
      render: function() {
        return this.renderList();
      },
      renderList: function() {
        var itemsJSON;
        itemsJSON = new Backbone.Collection(swipy.collection.getCompleted()).toJSON();
        return this.$el.find('.list-wrap').html(this.listTmpl({
          items: itemsJSON
        }));
      },
      customCleanUp: function() {
        return swipy.collection.off();
      }
    });
  });

}).call(this);
