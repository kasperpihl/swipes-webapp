(function() {
  define(["underscore", "backbone", "view/scheduler/SettingsOverlay", "model/SettingsModel"], function(_, Backbone, SettingsOverlayView, SettingsModel) {
    var SettingsController;
    return SettingsController = (function() {
      function SettingsController(opts) {
        this.init();
      }

      SettingsController.prototype.init = function() {
        this.model = new SettingsModel();
        this.view = new SettingsOverlayView({
          model: this.model
        });
        $("body").append(this.view.render().el);
        Backbone.on("settings/view", this.showView, this);
        Backbone.on("show-settings", this.show, this);
        return Backbone.on("hide-settings", this.hide, this);
      };

      SettingsController.prototype.showView = function(view) {
        return console.log("Show settings view: " + view);
      };

      SettingsController.prototype.destroy = function() {
        this.view.remove();
        return Backbone.off(null, null, this);
      };

      return SettingsController;

    })();
  });

}).call(this);
