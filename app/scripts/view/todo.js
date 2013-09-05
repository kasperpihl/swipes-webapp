(function() {
  define(["view/List"], function(ListView) {
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
        var title;
        title = prompt("Todo title:");
        if (title) {
          return console.log(swipy.collection.add({
            title: title
          }));
        }
      }
    });
  });

}).call(this);
