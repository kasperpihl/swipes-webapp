(function() {
  define(["underscore", "view/TaskInput"], function(_, TaskInputView) {
    var TaskInputController;
    return TaskInputController = (function() {
      function TaskInputController() {
        this.view = new TaskInputView();
        Backbone.on("create-task", this.createTask, this);
      }

      TaskInputController.prototype.parseTags = function(str) {
        var result, tag;
        result = str.match(/#(.[^,]+)/g);
        result = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = result.length; _i < _len; _i++) {
            tag = result[_i];
            _results.push(tag.replace("#", ""));
          }
          return _results;
        })();
        return result;
      };

      TaskInputController.prototype.parseTitle = function(str) {
        var result, _ref;
        result = (_ref = str.match(/.[^#]+/)) != null ? _ref[0] : void 0;
        if (result) {
          result = $.trim(result);
        }
        return result;
      };

      TaskInputController.prototype.createTask = function(str) {
        var order, tags, title;
        if (swipy.todos == null) {
          return;
        }
        tags = this.parseTags(str);
        title = this.parseTitle(str);
        order = 1;
        return swipy.todos.add({
          title: title,
          tags: tags,
          order: order
        });
      };

      return TaskInputController;

    })();
  });

}).call(this);
