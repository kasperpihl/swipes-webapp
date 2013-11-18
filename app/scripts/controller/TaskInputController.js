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
        result = str.match(/#(.[^,#]+)/g);
        if (result) {
          result = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = result.length; _i < _len; _i++) {
              tag = result[_i];
              _results.push($.trim(tag.replace("#", "")));
            }
            return _results;
          })();
          return result;
        } else {
          return [];
        }
      };

      TaskInputController.prototype.parseTitle = function(str) {
        var result, _ref;
        if (str[0] === "#") {
          return "";
        }
        result = (_ref = str.match(/[^#]+/)) != null ? _ref[0] : void 0;
        if (result) {
          result = $.trim(result);
        }
        return result;
      };

      TaskInputController.prototype.createTask = function(str) {
        var animateIn, msg, order, tags, title;
        if (swipy.todos == null) {
          return;
        }
        tags = this.parseTags(str);
        title = this.parseTitle(str);
        order = 0;
        animateIn = true;
        if (!title) {
          msg = "You cannot create a todo by simply adding a tag. We need a title too. Titles should come before tags when you write out your task.";
          Backbone.trigger("throw-error", msg);
          return;
        }
        swipy.todos.bumpOrder();
        return swipy.todos.create({
          title: title,
          tags: tags,
          order: order,
          animateIn: animateIn
        });
      };

      TaskInputController.prototype.destroy = function() {
        return Backbone.off(null, null, this);
      };

      return TaskInputController;

    })();
  });

}).call(this);
