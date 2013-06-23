(function() {
  define(['view/list-view'], function(ListView) {
    return ListView.extend({
      el: "#todo",
      events: {
        'tap .add-new': 'addNew',
        'click .add-new': 'addNew'
      },
      init: function() {
        this.listTmpl = _.template($('#template-list').html());
        return swipy.collection.on('add remove reset change', this.renderList, this);
      },
      addNew: function() {
        var todo;
        todo = prompt("Todo title:");
        if (todo) {
          return log(swipy.collection.add({
            title: todo
          }));
        }
      }
    });
  });

}).call(this);
