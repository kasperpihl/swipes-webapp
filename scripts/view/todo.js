(function() {
  define(['view/default-view'], function(DefaultView) {
    return DefaultView.extend({
      el: "#todo",
      events: {
        'tap .add-new': 'addNew',
        'click .add-new': 'addNew'
      },
      init: function() {
        this.listTmpl = _.template($('#template-list').html());
        return swipy.collection.on('add remove reset', this.renderList, this);
      },
      addNew: function() {
        var todo;
        todo = prompt("Todo title:");
        if (todo) {
          return log(swipy.collection.add({
            title: todo
          }));
        }
      },
      render: function() {
        return this.renderList();
      },
      renderList: function() {
        var itemsJSON;
        itemsJSON = new Backbone.Collection(swipy.collection.getActive()).toJSON();
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
