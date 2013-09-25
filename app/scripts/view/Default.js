(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.View.extend({
      initialize: function() {
        this.timers = [];
        this.init();
        return this.render();
      },
      init: function() {},
      render: function() {
        return this.el;
      },
      customCleanUp: function() {},
      remove: function() {
        var timer, _i, _len, _ref, _results;
        this.customCleanUp();
        this.undelegateEvents();
        _ref = this.timers;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          timer = _ref[_i];
          _results.push(clearTimeout(timer));
        }
        return _results;
      }
    });
  });

}).call(this);
