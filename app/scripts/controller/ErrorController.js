(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    var TaskInputController;
    return TaskInputController = (function() {
      function TaskInputController() {
        Backbone.on("throw-error", this.throwError, this);
      }

      TaskInputController.prototype.throwError = function() {
        console.warn(arguments);
        return alert(arguments[0]);
      };

      TaskInputController.prototype.destroy = function() {
        this.throwError = null;
        return Backbone.off("throw-error", this.throwError);
      };

      return TaskInputController;

    })();
  });

}).call(this);
