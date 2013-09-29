(function() {
  define(["underscore"], function(_) {
    var DateConverter;
    return DateConverter = (function() {
      function DateConverter() {
        console.log("Date Converter created");
      }

      DateConverter.prototype.getDateFromScheduleOption = function(option) {
        return new Date();
      };

      return DateConverter;

    })();
  });

}).call(this);
