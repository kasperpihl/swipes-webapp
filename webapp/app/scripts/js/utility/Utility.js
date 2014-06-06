(function() {
  define(function() {
    var Utility;
    return Utility = (function() {
      function Utility() {}

      Utility.prototype.generateId = function(length) {
        var i, possible, text, _i;
        text = "";
        possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        for (i = _i = 0; 0 <= length ? _i <= length : _i >= length; i = 0 <= length ? ++_i : --_i) {
          text += possible.charAt(Math.floor(Math.random() * possible.length));
        }
        return text;
      };

      return Utility;

    })();
  });

}).call(this);
