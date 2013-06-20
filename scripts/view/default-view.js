(function() {
  define(['backbone'], function(Backbone) {
    return Backbone.View.extend({
      events: {
        'tap .page-link': 'gotoPage',
        'click .page-link': 'gotoPage'
      },
      initialize: function() {
        _.bindAll(this);
        this.timers = [];
        this.init();
        return this.render();
      },
      init: function() {},
      gotoPage: function(e) {
        var link;
        link = $(e.currentTarget).attr('data-href');
        return window.location.hash = link;
      },
      render: function() {
        return this.el;
      },
      customCleanUp: function() {},
      cleanUp: function() {
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
