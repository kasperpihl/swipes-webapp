(function() {
  var LoginView, login;

  LoginView = Parse.View.extend({
    el: "#login",
    events: {
      "submit form": "handleSubmitForm",
      "click #facebook-login": "facebookLogin",
      "click .reset-password": "resetPassword"
    },
    facebookLogin: function(e) {
      return this.doAction("facebookLogin");
    },
    setBusyState: function() {
      $("body").addClass("busy");
      return this.$el.find("input[type=submit]").val("please wait ...");
    },
    removeBusyState: function() {
      $("body").removeClass("busy");
      return this.$el.find("input[type=submit]").val("Continue");
    },
    handleSubmitForm: function(e) {
      e.preventDefault();
      return this.doAction("login");
    },
    doAction: function(action) {
      var email, password,
        _this = this;
      if ($("body").hasClass("busy")) {
        return console.warn("Can't do " + action + " right now — I'm busy ...");
      }
      this.setBusyState();
      switch (action) {
        case "login":
          email = this.$el.find("#email").val();
          password = this.$el.find("#password").val();
          if (!this.validateFields(email, password)) {
            return this.removeBusyState();
          }
          return Parse.User.logIn(email, password, {
            success: function() {
              return _this.handleUserLoginSuccess();
            },
            error: function(user, error) {
              return _this.handleError(user, error, {
                email: email,
                password: password
              });
            }
          });
        case "register":
          console.log("Registering a new user");
          email = this.$el.find("#email").val();
          password = this.$el.find("#password").val();
          if (!this.validateFields(email, password)) {
            return this.removeBusyState();
          }
          return this.createUser(email, password).signUp().done(function() {
            return _this.handleUserLoginSuccess();
          }).fail(function(user, error) {
            return _this.handleError(user, error);
          });
        case "facebookLogin":
          return Parse.FacebookUtils.logIn(null, {
            success: this.handleFacebookLoginSuccess,
            error: function(user, error) {
              return _this.handleError(user, error);
            }
          });
      }
    },
    handleFacebookLoginSuccess: function(user) {
      var signup;
      if (user.isNew) {
        this.wasSignup = true;
      }
      if (!user.existed) {
        signup = true;
      }
      if (!user.get("email")) {
        return FB.api("/me", function(response) {
          if (response.gender) {
            user.set("gender", response.gender);
          }
          if (response.email) {
            user.set("email", response.email);
            user.set("username", response.email);
            user.save();
          }
          return this.handleUserLoginSuccess();
        });
      } else {
        return this.handleUserLoginSuccess();
      }
    },
    handleAnalyticsForLogin: function() {
      /*user = Parse.User.current()
      		if @wasSignup
      			swipy.analytics.tagEvent("Signed Up")
      		else
      			swipy.analytics.tagEvent("Logged In")
      */

    },
    handleUserLoginSuccess: function() {
      var level, user;
      this.handleAnalyticsForLogin();
      user = Parse.User.current();
      level = user.get("userLevel");
      if (level && parseInt(level) >= 1) {
        return location.pathname = "/";
      } else {
        this.removeBusyState();
        return $("body").addClass("swipes-plus-required").one("click", ".plus-required .cancel", function() {
          return $("body").removeClass("swipes-plus-required");
        });
      }
    },
    resetPassword: function() {
      var email;
      email = prompt("Which email did you register with?");
      if (email) {
        return Parse.User.requestPasswordReset(email, {
          success: function() {
            return alert("An email was sent to '" + email + "' with instructions on resetting your password");
          },
          error: function(error) {
            return alert("Error: " + error.message);
          }
        });
      }
    },
    createUser: function(email, password) {
      var user;
      user = new Parse.User();
      user.set("username", email);
      user.set("password", password);
      user.set("email", email);
      return user;
    },
    validateFields: function(email, password) {
      if (!email) {
        alert("Please fill in your e-mail address");
        return false;
      }
      if (!password) {
        alert("Please fill in your password");
        return false;
      }
      if (email.length === 0 || password.length === 0) {
        alert("Please fill out both fields");
        return false;
      }
      if (!this.validateEmail(email)) {
        alert("Please use a real email address");
        return false;
      }
      return true;
    },
    validateEmail: function(email) {
      var regex;
      regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
      return regex.test(email);
    },
    handleError: function(user, error, triedLoginWithCredentials) {
      var checkEmailOpts,
        _this = this;
      if (triedLoginWithCredentials == null) {
        triedLoginWithCredentials = false;
      }
      if (triedLoginWithCredentials) {
        checkEmailOpts = {
          success: function(result, error) {
            if (!result) {
              if (confirm("You're about to create a new user with the e-mail " + triedLoginWithCredentials.email + ". Do you want to continue?")) {
                _this.removeBusyState();
                return _this.doAction("register");
              } else {
                return _this.removeBusyState();
              }
            } else {
              _this.removeBusyState();
              return alert("Wrong password.");
            }
          },
          error: function() {
            alert("Something went wrong. Please try again.");
            return _this.removeBusyState();
          }
        };
        return Parse.Cloud.run("checkEmail", {
          email: triedLoginWithCredentials.email
        }, checkEmailOpts);
      } else if (error && error.code) {
        return this.showError(error);
      } else {
        return alert("something went wrong. Please try again.");
      }
    },
    showError: function(error) {
      switch (error.code) {
        case Parse.Error.USERNAME_TAKEN:
        case Parse.Error.EMAIL_NOT_FOUND:
          return alert("The password was wrong");
        case Parse.Error.INVALID_EMAIL_ADDRESS:
          return alert("The provided email is invalid. Please check it, and try again");
        case Parse.Error.TIMEOUT:
          return alert("The connection timed out. Please try again.");
        case Parse.Error.USERNAME_TAKEN:
          return alert("The email/username was already taken");
        case 202:
          return alert("The email is already in use, please login instead");
        case 101:
          return alert("Wrong email or password");
        default:
          return alert("something went wrong. Please try again.");
      }
    }
  });

  Parse.initialize("0qD3LLZIOwLOPRwbwLia9GJXTEUnEsSlBCufqDvr", "TcteeVBhtJEERxRtaavJtFznsXrh84WvOlE6hMag");

  window.fbAsyncInit = function() {
    return Parse.FacebookUtils.init({
      appId: '312199845588337',
      channelUrl: 'http://test.swipesapp.com/channel.html',
      status: false,
      cookie: true,
      xfbml: true
    });
  };

  (function() {
    var facebookJS, firstScriptElement;
    if (document.getElementById('facebook-jssdk')) {
      return;
    }
    firstScriptElement = document.getElementsByTagName('script')[0];
    facebookJS = document.createElement('script');
    facebookJS.id = 'facebook-jssdk';
    facebookJS.src = '//connect.facebook.net/en_US/all.js';
    return firstScriptElement.parentNode.insertBefore(facebookJS, firstScriptElement);
  })();

  login = new LoginView();

}).call(this);
