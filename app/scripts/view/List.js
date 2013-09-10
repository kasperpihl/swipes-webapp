(function() {
  define(["view/Default"], function(DefaultView) {
    return DefaultView.extend({
      init: function() {},
      render: function() {
        this.renderList();
        return this;
      },
      renderList: function() {},
      afterRenderList: function(models) {},
      customCleanUp: function() {}
    });
  });

}).call(this);
