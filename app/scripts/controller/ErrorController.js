(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    var TaskInputController;
    return TaskInputController = (function() {
      function TaskInputController() {
        Backbone.on("throw-error", this.throwError, this);
      }

      TaskInputController.prototype.throwError = function(err) {
        console.warn(err);
        return alert(err);
      };

      TaskInputController.prototype.destroy = function() {
        this.throwError = null;
        return Backbone.off("throw-error", this.throwError);
      };

      return TaskInputController;

    })();
  });

}).call(this);
