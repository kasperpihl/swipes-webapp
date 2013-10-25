(function() {
  define(["underscore", "backbone", "view/settings/SettingsOverlay", "model/SettingsModel"], function(_, Backbone, SettingsOverlayView, SettingsModel) {
    var SettingsController;
    return SettingsController = (function() {
      function SettingsController(opts) {
        this.init();
      }

      SettingsController.prototype.init = function() {
        this.model = new SettingsModel();
        Backbone.on("show-settings", this.show, this);
        Backbone.on("hide-settings", this.hide, this);
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

      SettingsController.prototype.show = function() {
        if (this.view == null) {
          this.view = new SettingsOverlayView({
            model: this.model
          });
          $("body").append(this.view.render().el);
        }
        return this.view.show();
      };

      SettingsController.prototype.hide = function() {
        var _ref;
        return (_ref = this.view) != null ? _ref.hide() : void 0;
      };

      SettingsController.prototype.destroy = function() {
        var _ref;
        if ((_ref = this.view) != null) {
          _ref.remove();
        }
        return Backbone.off(null, null, this);
      };

      return SettingsController;

    })();
  });

}).call(this);
