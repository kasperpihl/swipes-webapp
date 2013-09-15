(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.View.extend({
      tagName: "li",
      initialize: function() {
        var _this = this;
        _.bindAll(this, "onSelected");
        this.model.on("change:selected", this.onSelected);
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
      onSelected: function(model, selected) {
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
      customCleanUp: function() {},
      cleanUp: function() {
        this.model.off();
        return this.customCleanUp();
      }
    });
  });

}).call(this);
