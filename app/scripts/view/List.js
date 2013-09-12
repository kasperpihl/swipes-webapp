(function() {
  define(["view/Default"], function(DefaultView) {
    return DefaultView.extend({
      events: Modernizr.touch ? "tap" : "click ",
      init: function() {},
      render: function() {
        this.renderList();
        return this;
      },
      getDummyData: function() {
        return [
          {
            schedule: ""
          }
        ];
      },
      renderList: function() {},
      afterRenderList: function(models) {},
      customCleanUp: function() {}
    });
  });

}).call(this);
