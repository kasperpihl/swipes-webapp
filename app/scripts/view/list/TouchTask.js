(function() {
  define(["view/list/BaseTask", "hammerjs"], function(BaseTaskView) {
    return BaseTaskView.extend({
      bindEvents: function() {
        this.$el.hammer().on("tap", ".todo-content", this.toggleSelected);
        this.$el.hammer().on("tap", ".priority", this.togglePriority);
        this.$el.hammer().on("doubletap", ".todo-content", this.edit);
        return this.$el.hammer().on("tap", ".action", this.handleAction);
      },
      afterRender: function() {
        var classNameMap, key, oldEl, val, _results;
        classNameMap = {
          "icon-schedule-act": "icon-clock-alt",
          "icon-todo-act": "icon-todo",
          "icon-checkmark-act": "icon-checkmark-alt"
        };
        _results = [];
        for (key in classNameMap) {
          val = classNameMap[key];
          oldEl = this.$el.find("." + key);
          if (oldEl.length) {
            _results.push(oldEl.removeClass(key).addClass(val));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    });
  });

}).call(this);
