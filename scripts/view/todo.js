(function() {
  define(["view/list-view"], function(ListView) {
    return ListView.extend({
      el: "#todo",
      events: {
        'tap .add-new': 'addNew',
        'click .add-new': 'addNew'
      },
      init: function() {
        var _this = this;
        this.listTmpl = _.template($('#template-list').html());
        swipy.collection.on('add remove reset change', this.renderList, this);
        if (!Modernizr.touch) {
          return require(["plugins/jwerty/jwerty"], function() {
            return jwerty.key("cmd+s", _this.addNew);
          });
        }
      },
      addNew: function() {
        var todo;
        todo = prompt("Todo title:");
        if (todo) {
          return console.log(swipy.collection.add({
            title: todo
          }));
        }
      }
    });
  });

}).call(this);
