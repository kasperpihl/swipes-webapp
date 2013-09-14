(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.View.extend({
      tagName: "li",
      initialize: function() {
        var _this = this;
        _.bindAll(this, "handleSelected");
        this.model.on("change:selected", this.handleSelected);
        return this.setTemplate().then(function() {
          _this.init();
          _this.content = _this.$el.find('.todo-content');
          return _this.render();
        });
      },
      setTemplate: function() {
        var dfd,
          _this = this;
        dfd = new $.Deferred();
        require(["text!templates/list-item.html"], function(ListItemTmpl) {
          _this.template = _.template(ListItemTmpl);
          return dfd.resolve();
        });
        return dfd.promise();
      },
      init: function() {},
      handleSelected: function(model, selected) {
        console.log("BaseListItem selected changed to: ", selected);
        return this.$el.toggleClass("selected", selected);
      },
      render: function() {
        if (this.template == null) {
          return this.el;
        }
        this.$el.html(this.template(this.model.toJSON()));
        return this.el;
      },
      remove: function() {
        return this.cleanUp();
      },
      cleanUp: function() {
        return this.model.off();
      }
    });
  });

}).call(this);
