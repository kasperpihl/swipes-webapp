(function() {
  var LoginView, login;

  LoginView = Parse.View.extend({
    el: "#login",
    events: {
      "submit form": "handleSubmitForm",
      "click #facebook-login": "facebookLogin"
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
              return location.pathname = "/";
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
            return location.pathname = "/";
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
          return location.href = "/";
        });
      } else {
        return location.href = "/";
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
        alert("Please fill in you e-mail address");
        return false;
      }
      if (!password) {
        alert("Please fill in you password");
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
      if (triedLoginWithCredentials == null) {
        triedLoginWithCredentials = false;
      }
      if (triedLoginWithCredentials) {
        if (error && error.code) {
          switch (error.code) {
            case 101:
              if (confirm("You're about to create a new user with the e-mail " + triedLoginWithCredentials.email + ". Do you want to continue?")) {
                this.removeBusyState();
                return this.doAction("register");
              } else {
                return;
              }
              break;
            default:
              return this.showError(error);
          }
        } else {
          this.removeBusyState();
          return alert("something went wrong. Please try again.");
        }
      }
      this.removeBusyState();
      if (error && error.code) {
        return this.showError(error);
      } else {
        return alert("something went wrong. Please try again.");
      }
    },
    showError: function(error) {
      switch (error.code) {
        case Parse.Error.USERNAME_TAKEN:
        case Parse.Error.EMAIL_NOT_FOUND:
          return alert("The password was wrong or the email/username was already taken");
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
