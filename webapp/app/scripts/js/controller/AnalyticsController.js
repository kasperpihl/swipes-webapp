(function() {
  define(["underscore"], function(_) {
    var AnalyticsController, isInt;
    isInt = function(n) {
      return typeof n === 'number' && n % 1 === 0;
    };
    return AnalyticsController = (function() {
      function AnalyticsController() {
        this.init();
      }

      AnalyticsController.prototype.init = function() {
        return this.screens = [];
      };

      AnalyticsController.prototype.sendEvent = function(category, action, label, value) {
        return ga('send', 'event', category, action, label, value);
      };

      AnalyticsController.prototype.pushScreen = function(screenName) {
        ga('send', 'screenview', {
          'screenName': screenName
        });
        return this.screens.push(screenName);
      };

      AnalyticsController.prototype.popScreen = function() {
        var lastScreen;
        if (this.screens.length) {
          this.screens.pop();
          lastScreen = _.last(this.screens);
          if (lastScreen == null) {
            return;
          }
          return ga('send', 'screenview', {
            'screenName': lastScreen
          });
        }
      };

      AnalyticsController.prototype.updateIdentity = function() {
        var cdUserLevel, user;
        user = Parse.user.current();
        cdUserLevel = (function() {
          switch (parseInt(user.get("userLevel"), 10)) {
            case 1:
              return "Trial";
            case 2:
              return "Plus Monthly";
            case 3:
              return "Plus Yearly";
            default:
              return "Standard";
          }
        })();
        if (cdUserLevel !== this.customDimensions[0]) {
          this.setCustomDimension(0, cdUserLevel);
        }
        if (user.get("email") !== this.session.customerEmail) {
          this.session.setCustomerEmail(user.get("email"));
        }
        if ((user.id != null) !== this.session.customerId) {
          return this.session.setCustomerId(user.id);
        }
      };

      return AnalyticsController;

    })();
  });

}).call(this);
