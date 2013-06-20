(function() {
  define(function() {
    var PageController;
    return PageController = (function() {
      function PageController(opts) {
        this.setOpts(opts);
        this.init();
      }

      PageController.prototype.setOpts = function(opts) {
        var defaultOptions;
        defaultOptions = {
          $wrap: $('.pt-perspective'),
          $pages: $('.pt-page'),
          isAnimating: false,
          endOldPage: false,
          endNewPage: false,
          animEndEventNames: {
            'WebkitAnimation': 'webkitAnimationEnd',
            'OAnimation': 'oAnimationEnd',
            'msAnimation': 'MSAnimationEnd',
            'animation': 'animationend'
          }
        };
        defaultOptions.numPages = defaultOptions.$pages.length;
        defaultOptions.animEndEventName = defaultOptions.animEndEventNames[Modernizr.prefixed('animation')];
        return this.options = $.extend(defaultOptions, opts);
      };

      PageController.prototype.init = function() {
        var _this = this;
        this.options.$pages.each(function() {
          return $(this).data('originalClassList', $(this).attr('class'));
        });
        this.options.$pages.eq(0).addClass('pt-page-current');
        return $(document).on('navigate/page', function(e, slug) {
          return _this.goto(slug);
        });
      };

      PageController.prototype.goto = function(slug) {
        var newPage, oldPage;
        if (this.options.isAnimating) {
          return false;
        }
        this.options.isAnimating = true;
        oldPage = this.options.$pages.filter('.pt-page-current');
        newPage = this.options.$pages.filter(function() {
          return $(this).data('slug') === slug;
        });
        return this.transitionPages(oldPage, newPage);
      };

      PageController.prototype.transitionPages = function(oldPage, newPage) {
        var transitionIn, transitionOut,
          _this = this;
        log("out: '" + (oldPage.data('slug')) + "' /// in: '" + (newPage.data('slug')) + "'");
        if (this.options.currView != null) {
          this.options.currView.cleanUp();
        }
        newPage.addClass('pt-page-current');
        transitionOut = this.getTransitionsForPage(oldPage.data('slug')).out;
        transitionIn = this.getTransitionsForPage(newPage.data('slug'))["in"];
        oldPage.addClass(transitionOut).one(this.options.animEndEventName, function() {
          _this.options.endOldPage = true;
          if (_this.options.endNewPage) {
            return _this.onEndAnimation(oldPage, newPage);
          }
        });
        return newPage.addClass(transitionIn).one(this.options.animEndEventName, function() {
          _this.options.endNewPage = true;
          if (_this.options.endOldPage) {
            return _this.onEndAnimation(oldPage, newPage);
          }
        });
      };

      PageController.prototype.onEndAnimation = function(oldPage, newPage) {
        this.options.endOldPage = false;
        this.options.endNewPage = false;
        this.resetPage(oldPage, newPage);
        this.options.isAnimating = false;
        return this.loadPageScripts(newPage.data('slug'), newPage);
      };

      PageController.prototype.resetPage = function(oldPage, newPage) {
        oldPage.attr('class', oldPage.data('originalClassList'));
        return newPage.attr('class', newPage.data('originalClassList') + ' pt-page-current');
      };

      PageController.prototype.getTransitionsForPage = function(slug) {
        var transitions;
        transitions = {
          "in": '',
          out: ''
        };
        switch (slug) {
          case 'todo':
            transitions["in"] = "pt-page-flipInLeft";
            transitions.out = "pt-page-moveToLeft";
            break;
          case 'schedule':
            transitions["in"] = "pt-page-moveFromRight";
            transitions.out = "pt-page-rotateRightSideFirst";
            break;
          default:
            transitions["in"] = "pt-page-moveFromRightFade";
            transitions.out = "pt-page-moveToLeftFade";
        }
        return transitions;
      };

      PageController.prototype.loadPageScripts = function(slug, pageEl) {
        var _this = this;
        return require(["view/" + slug], function(View) {
          return _this.options.currView = new View({
            el: pageEl
          });
        });
      };

      return PageController;

    })();
  });

}).call(this);
