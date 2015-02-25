(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(function() {
    var SliderControl;
    return SliderControl = (function() {
      function SliderControl(el, opts, value) {
        this.el = el;
        if (value == null) {
          value = 0;
        }
        this.handleResize = __bind(this.handleResize, this);
        this.cacheElements();
        this.proxyCallbacks(opts);
        this.opts = $.extend(this.getDefaultOptions(), opts);
        if (opts.steps) {
          this.opts.stepCount = opts.steps;
          this.opts.liveSnap = this.getPxSteps();
        }
        this.init();
        $(window).on("resize.slidercontrol", this.handleResize);
        this.handleResize();
        this.setValue(value, value > 0, false);
      }

      SliderControl.prototype.cacheElements = function() {
        this.track = this.el.querySelector(".track");
        return this.handle = this.el.querySelector(".handle");
      };

      SliderControl.prototype.proxyCallbacks = function(opts) {
        if (opts != null ? opts.onDrag : void 0) {
          this.onDragCb = opts.onDrag;
          delete opts.onDrag;
        }
        if (opts != null ? opts.onDragEnd : void 0) {
          this.onDragEndCb = opts.onDragEnd;
          return delete opts.onDragEnd;
        }
      };

      SliderControl.prototype.handleResize = function() {
        var steps;
        this.draggable.vars.bounds = {
          minX: 0,
          maxX: this.getBounds().width + 1
        };
        if (this.opts.stepCount) {
          steps = this.getPxSteps();
          this.draggable.vars.liveSnap = steps;
        }
        return this.setValue(this.value);
      };

      SliderControl.prototype.getDefaultOptions = function() {
        return {
          type: "x",
          zIndexBoost: false,
          bounds: {
            minX: 0,
            maxX: this.getBounds().width + 1
          },
          onDrag: this.handleDrag,
          onDragScope: this,
          onDragEnd: this.handleDragEnd,
          onDragEndScope: this
        };
      };

      SliderControl.prototype.init = function() {
        return this.draggable = new Draggable(this.handle, this.opts);
      };

      SliderControl.prototype.getBounds = function() {
        return this.track.getBoundingClientRect();
      };

      SliderControl.prototype.getClosestValue = function(value) {
        var diffs, i, minDist, step, steps, val, _i, _len;
        steps = this.getValueSteps();
        diffs = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = steps.length; _i < _len; _i++) {
            step = steps[_i];
            _results.push(Math.abs(value - step));
          }
          return _results;
        })();
        minDist = Math.min.apply(Math, diffs);
        for (i = _i = 0, _len = diffs.length; _i < _len; i = ++_i) {
          val = diffs[i];
          if (val === minDist) {
            return steps[i];
          }
        }
      };

      SliderControl.prototype.getValueSteps = function() {
        var i, incrementBy;
        if (!this.valueSteps) {
          incrementBy = 1 / (this.opts.stepCount - 1);
          this.valueSteps = (function() {
            var _i, _ref, _results;
            _results = [];
            for (i = _i = 0, _ref = this.opts.stepCount; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
              _results.push(incrementBy * i);
            }
            return _results;
          }).call(this);
          return this.valueSteps;
        } else {
          return this.valueSteps;
        }
      };

      SliderControl.prototype.getPxSteps = function() {
        var step, _i, _len, _ref, _results;
        _ref = this.getValueSteps();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          step = _ref[_i];
          switch (step) {
            case 0:
              _results.push(step);
              break;
            case 1:
              _results.push(Math.round(this.getBounds().width));
              break;
            default:
              _results.push(Math.round(this.convertFloatToPx(step)));
          }
        }
        return _results;
      };

      SliderControl.prototype.getValueFromPxStep = function(px) {
        var i, matchingValue, val, _i, _len, _ref;
        _ref = this.opts.liveSnap;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          val = _ref[i];
          if (!(val === px)) {
            continue;
          }
          this.currentStep = i;
          matchingValue = this.getValueSteps()[i];
          return matchingValue;
        }
      };

      SliderControl.prototype.convertFloatToPx = function(float) {
        return this.track.clientWidth * float;
      };

      SliderControl.prototype.convertPxToFloat = function(px) {
        return px / this.track.clientWidth;
      };

      SliderControl.prototype.handleDrag = function() {
        this.value = this.getSlideValue();
        if (this.onDragCb) {
          return this.onDragCb.apply(this, arguments);
        }
      };

      SliderControl.prototype.handleDragEnd = function() {
        this.value = this.getSlideValue();
        if (this.onDragEndCb) {
          return this.onDragEndCb.apply(this, arguments);
        }
      };

      SliderControl.prototype.getSlideValue = function() {
        var val;
        if (this.opts.stepCount) {
          return this.getValueFromPxStep(this.draggable.x);
        } else {
          val = this.draggable.x / this.track.clientWidth;
          return Math.min(Math.max(val, 0), 1);
        }
      };

      SliderControl.prototype.setValue = function(value, updateDraggable, pxValue) {
        if (updateDraggable == null) {
          updateDraggable = true;
        }
        if (pxValue == null) {
          pxValue = false;
        }
        if (pxValue) {
          this.value = this.convertPxToFloat(value);
        } else {
          this.value = value;
          value = this.convertFloatToPx(value);
        }
        TweenLite.set(this.handle, {
          x: value
        });
        if (updateDraggable) {
          this.draggable.update();
        }
        return this.value;
      };

      SliderControl.prototype.disable = function() {
        $(window).off("resize.slidercontrol", this.handleResize);
        return this.draggable.disable();
      };

      SliderControl.prototype.enable = function() {
        this.draggable.enable();
        $(window).on("resize.slidercontrol", this.handleResize);
        return this.handleResize();
      };

      SliderControl.prototype.destroy = function() {
        return this.disable();
      };

      return SliderControl;

    })();
  });

}).call(this);
