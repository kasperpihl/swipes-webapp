(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    var ErrorController;
    return ErrorController = (function() {
      function ErrorController() {
        Backbone.on("throw-error", this.throwError, this);
      }

      ErrorController.prototype.throwError = function() {
        console.warn(arguments);
        return alert(arguments[0]);
      };

      ErrorController.prototype.destroy = function() {
        this.throwError = null;
        return Backbone.off("throw-error", this.throwError);
      };

      return ErrorController;

    })();
  });

}).call(this);
