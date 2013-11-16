(function() {
  var LoginView, SwipesLogin;

  LoginView = Parse.View.extend({
    el: "#login",
    events: {
      "click #button-login": "login",
      "click #button-register": "register",
      "click .facebook-login": "facebookLogin"
    },
    initialize: function() {
      this.busy = false;
      return _.bindAll(this, "handleFacebookLoginSuccess");
    },
    login: function() {
      return this.doAction("login");
    },
    register: function() {
      return this.doAction("register");
    },
    facebookLogin: function() {
      return this.doAction("facebookLogin");
    },
    doAction: function(action) {
      var email, password;
      if (this.busy) {
        return console.warn("Can't do " + action + " right now — I'm busy ...");
      }
      this.busy = true;
      switch (action) {
        case "login":
          email = this.$el.find("#email-login").val();
          password = this.$el.find("#password-login").val();
          if (!this.validateFields(email, password)) {
            return;
          }
          return Parse.User.logIn(email, password, {
            error: this.handleError,
            success: function() {
              return location.href = "/";
            }
          });
        case "register":
          email = this.$el.find("#email-register").val();
          password = this.$el.find("#password-register").val();
          if (!this.validateFields(email, password)) {
            return;
          }
          return this.createUser(email, password).signUp(null, {
            error: this.handleError,
            success: function() {
              return location.href = "/";
            }
          });
        case "facebookLogin":
          return Parse.FacebookUtils.logIn(null, {
            success: this.handleFacebookLoginSuccess,
            error: this.handleError
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
      user = new Parse.user();
      user.set("username", email);
      user.set("password", password);
      user.set("email", email);
      return user;
    },
    validateFields: function(email, password) {
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
    validateEmail: function() {
      var regex;
      regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
      return regex.test(email);
    },
    handleError: function(user, error) {
      this.busy = false;
      if (error && error.code) {
        switch (error.code) {
          case 202:
            return alert("The email is already in use, please login instead");
          case 101:
            return alert("Wrong email or password");
          default:
            return alert("something went wrong. Please try again.");
        }
      }
    }
  });

  SwipesLogin = (function() {
    function SwipesLogin() {
      console.log("Login thingy ready...");
      this.view = new LoginView();
    }

    return SwipesLogin;

  })();

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

}).call(this);
