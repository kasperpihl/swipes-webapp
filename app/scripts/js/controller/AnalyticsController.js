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
        this.loadedIntercom = false;
        this.user = Parse.User.current();
        if ((this.user != null) && this.user.id) {
          ga('create', analyticsKey, {
            'userId': this.user.id
          });
        } else {
          ga('create', analyticsKey, 'auto');
        }
        ga('send', 'pageview');
        this.startIntercom();
        return this.updateIdentity();
      };

      AnalyticsController.prototype.startIntercom = function() {
        var email, userId;
        if (this.user == null) {
          return;
        }
        userId = this.user.id;
        if (this.validateEmail(this.user.get("username"))) {
          email = this.user.get("username");
        } else if (this.validateEmail(this.user.get("email"))) {
          email = this.user.get("email");
        }
        window.Intercom('boot', {
          app_id: 'yobuz4ff',
          email: email,
          user_id: userId,
          created_at: parseInt(this.user.createdAt.getTime() / 1000, 10)
        });
        return this.loadedIntercom = true;
      };

      AnalyticsController.prototype.validateEmail = function(email) {
        var regex;
        regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return regex.test(email);
      };

      AnalyticsController.prototype.sendEvent = function(category, action, label, value) {
        return ga('send', 'event', category, action, label, value);
      };

      AnalyticsController.prototype.sendEventToIntercom = function(eventName, metadata) {
        return Intercom('trackEvent', eventName, metadata);
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
        var currentNumberOfTags, currentRecurringCount, currentTheme, currentUserLevel, gaSendIdentity, intercomIdentity, numberOfTags, numberUserLevel, recurringCount, recurringTasks, theme, userLevel;
        gaSendIdentity = {};
        intercomIdentity = {};
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
          intercomIdentity["user_level"] = userLevel;
        }
        theme = "Light";
        currentTheme = this.customDimensions['active_theme'];
        if (currentTheme !== theme) {
          gaSendIdentity['dimension3'] = theme;
          intercomIdentity['active_theme'] = theme;
        }
        if (typeof swipy !== "undefined" && swipy !== null) {
          recurringTasks = swipy.todos.filter(function(m) {
            return m.get("repeatOption") !== "never";
          });
          recurringCount = recurringTasks.length;
          currentRecurringCount = this.customDimensions['recurring_tasks'];
          if (currentRecurringCount !== recurringCount) {
            gaSendIdentity['dimension4'] = recurringCount;
            intercomIdentity["recurring_tasks"] = recurringCount;
          }
          numberOfTags = swipy.tags.length;
          currentNumberOfTags = this.customDimensions['number_of_tags'];
          if (currentNumberOfTags !== numberOfTags) {
            gaSendIdentity['dimension5'] = numberOfTags;
            intercomIdentity["number_of_tags"] = numberOfTags;
          }
        }
        if (_.size(gaSendIdentity) > 0) {
          ga('set', gaSendIdentity);
          this.sendEvent("Session", "Updated Identity");
        }
        if (_.size(intercomIdentity) > 0) {
          return Intercom("update", intercomIdentity);
        }
      };

      return AnalyticsController;

    })();
  });

}).call(this);
