(function() {
  define(["underscore", "backbone", "gsap"], function(_, Backbone) {
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
          return TweenLite.to({
            a: 0
          }, this.getSecondsRemainingThisMin(), {
            a: 1,
            onComplete: this.tick,
            onCompleteScope: this,
            ease: Linear.easeNone
          });
        }
      };

      ClockWork.prototype.tick = function() {
        this.timesUpdated++;
        this.timer = this.getTimer();
        return Backbone.trigger("clockwork/update", this);
      };

      ClockWork.prototype.getSecondsRemainingThisMin = function() {
        var result;
        result = 60 - new Date().getSeconds();
        if (result === 0) {
          return 59;
        } else {
          return result;
        }
      };

      ClockWork.prototype.timeToNextTick = function() {
        return this.timer.duration() - this.timer.time();
      };

      ClockWork.prototype.destroy = function() {
        return this.timer.kill();
      };

      return ClockWork;

    })();
  });

}).call(this);
