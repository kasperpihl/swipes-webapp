(function() {
  define(["underscore", "../bower_components/greensock-js/src/uncompressed/TweenLite"], function(_, TweenLite) {
    var ClockWork;
    return ClockWork = (function() {
      function ClockWork() {
        this.timesUpdated = 0;
        this.timer = this.getTimer();
      }

      ClockWork.prototype.getTimer = function() {
        if (this.timer && this.timer.progress < 1) {
          return this.timer;
        } else {
          return TweenLite.delayedCall(this.getSecondsRemainingThisMin(), this.tick, null, this);
        }
      };

      ClockWork.prototype.tick = function() {
        this.timesUpdated++;
        return console.log("Update!");
      };

      ClockWork.prototype.getSecondsRemainingThisMin = function() {
        return 60 - new Date().getSeconds();
      };

      ClockWork.prototype.destroy = function() {
        return TweenLite.killDelayedCallsTo(this.tick);
      };

      return ClockWork;

    })();
  });

}).call(this);
