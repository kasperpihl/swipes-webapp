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
        this.customDimensions = ["Standard"];
        this.screens = [];
        return this.createSession();
      };

      AnalyticsController.prototype.createSession = function() {
        this.session = LocalyticsSession(this.getKey());
        this.session.open();
        this.session.upload();
        return this.setUser(Parse.User.current());
      };

      AnalyticsController.prototype.getKey = function() {
        var liveKey, testKey;
        testKey = "f2f927e0eafc7d3c36835fe-c0a84d84-18d8-11e3-3b24-00a426b17dd8";
        liveKey = "0c159f237171213e5206f21-6bd270e2-076d-11e3-11ec-004a77f8b47f";
        return testKey;
      };

      AnalyticsController.prototype.hasDimension = function(dimension) {
        if (isInt(dimension) && (this.customDimensions.length < dimension && dimension >= 0)) {
          return true;
        } else {
          return false;
        }
      };

      AnalyticsController.prototype.customDimension = function(dimension) {
        if (this.hasDimension(dimension)) {
          return this.customDimensions[dimension];
        } else {
          return false;
        }
      };

      AnalyticsController.prototype.setCustomDimension = function(dimension, value) {
        if (this.hasDimension(dimension)) {
          return this.customDimensions[dimension] = value;
        }
      };

      AnalyticsController.prototype.tagEvent = function(ev, options) {
        return this.session.tagEvent(ev, options, this.customDimensions);
      };

      AnalyticsController.prototype.pushScreen = function(screenName) {
        this.session.tagScreen(screenName);
        return this.screens.push(screenName);
      };

      AnalyticsController.prototype.popScreen = function() {
        if (this.screens.length) {
          this.screens.pop();
          return this.session.tagScreen(_.last(this.screens));
        }
      };

      AnalyticsController.prototype.setUser = function(user) {
        var cdUserLevel;
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
