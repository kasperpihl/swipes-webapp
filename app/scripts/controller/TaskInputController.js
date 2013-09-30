(function() {
  define(["underscore", "view/TaskInput"], function(_, TaskInputView) {
    var TaskInputController;
    return TaskInputController = (function() {
      function TaskInputController() {
        this.view = new TaskInputView();
        Backbone.on("create-task", this.createTask, this);
      }

      TaskInputController.prototype.parseTags = function(str) {
        return ["one", "two", "three"];
      };

      TaskInputController.prototype.parseTitle = function(str) {
        return "Looool";
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
