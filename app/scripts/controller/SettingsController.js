(function() {
  define(["underscore", "backbone", "view/settings/SettingsOverlay", "model/SettingsModel"], function(_, Backbone, SettingsOverlayView, SettingsModel) {
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
        Backbone.on("show-settings", this.view.show, this.view);
        Backbone.on("hide-settings", this.view.hide, this.view);
        return _.bindAll(this, "get", "set", "unset");
      };

      SettingsController.prototype.get = function() {
        var _ref;
        return (_ref = this.model).get.apply(_ref, arguments);
      };

      SettingsController.prototype.set = function() {
        var _ref;
        return (_ref = this.model).set.apply(_ref, arguments);
      };

      SettingsController.prototype.unset = function() {
        var _ref;
        return (_ref = this.model).unset.apply(_ref, arguments);
      };

      SettingsController.prototype.destroy = function() {
        this.view.remove();
        return Backbone.off(null, null, this);
      };

      return SettingsController;

    })();
  });

}).call(this);
