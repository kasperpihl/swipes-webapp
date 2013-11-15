(function() {
  var SwipesLogin;

  SwipesLogin = (function() {
    function SwipesLogin() {
      console.log("Login thingy ready...");
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
