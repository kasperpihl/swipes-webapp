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
        var analyticsKey;
        analyticsKey = 'UA-41592802-4';
        this.screens = [];
        this.customDimensions = {};
        this.user = Parse.User.current();
        if ((this.user != null) && this.user.id) {
          ga('create', analyticsKey, {
            'userId': this.user.id
          });
        } else {
          ga('create', analyticsKey, 'auto');
        }
        ga('send', 'pageview');
        return this.updateIdentity();
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
        var currentNumberOfTags, currentRecurringCount, currentTheme, currentUserLevel, gaSendIdentity, numberOfTags, numberUserLevel, recurringCount, recurringTasks, theme, userLevel;
        gaSendIdentity = {};
        userLevel = "None";
        if (this.user != null) {
          userLevel = "User";
          numberUserLevel = parseInt(this.user.get("userLevel"), 10);
          if (numberUserLevel > 1) {
            userLevel = "Plus";
          }
        }
        currentUserLevel = this.customDimensions['user_level'];
        if (currentUserLevel !== userLevel) {
          gaSendIdentity["dimension1"] = userLevel;
        }
        theme = "Light";
        currentTheme = this.customDimensions['active_theme'];
        if (currentTheme !== theme) {
          gaSendIdentity['dimension3'] = theme;
        }
        if (typeof swipy !== "undefined" && swipy !== null) {
          recurringTasks = swipy.todos.filter(function(m) {
            return m.get("repeatOption") !== "never";
          });
          recurringCount = recurringTasks.length;
          currentRecurringCount = this.customDimensions['recurring_tasks'];
          if (currentRecurringCount !== recurringCount) {
            gaSendIdentity['dimension4'] = recurringCount;
          }
          numberOfTags = swipy.tags.length;
          currentNumberOfTags = this.customDimensions['number_of_tags'];
          if (currentNumberOfTags !== numberOfTags) {
            gaSendIdentity['dimension5'] = numberOfTags;
          }
        }
        if (_.size(gaSendIdentity) > 0) {
          ga('set', gaSendIdentity);
          return this.sendEvent("Session", "Updated Identity");
        }
      };

      return AnalyticsController;

    })();
  });

}).call(this);
