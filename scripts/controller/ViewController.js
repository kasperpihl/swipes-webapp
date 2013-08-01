(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(function() {
    var ViewController;
    return ViewController = (function() {
      function ViewController(opts) {
        this.updateNavigation = __bind(this.updateNavigation, this);
        this.setOpts(opts);
        this.init();
        this.navLinks = $('nav a');
      }

      ViewController.prototype.setOpts = function(opts) {
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

      ViewController.prototype.init = function() {
        var _this = this;
        this.options.$pages.each(function() {
          return $(this).data('originalClassList', $(this).attr('class'));
        });
        this.options.$pages.eq(0).addClass('pt-page-current');
        return $(document).on('navigate/page', function(e, slug) {
          return _this.goto(slug);
        });
      };

      ViewController.prototype.goto = function(slug) {
        var newPage, oldPage;
        if (this.options.isAnimating) {
          return false;
        }
        this.options.isAnimating = true;
        oldPage = this.options.$pages.filter('.pt-page-current');
        newPage = this.options.$pages.filter(function() {
          return $(this).attr('id') === slug;
        });
        this.transitionPages(oldPage, newPage);
        return this.updateNavigation(slug);
      };

      ViewController.prototype.updateNavigation = function(slug) {
        return this.navLinks.each(function() {
          var isCurrLink, link;
          link = $(this);
          isCurrLink = link.attr('href').slice(2) === slug ? true : false;
          return link.toggleClass('active', isCurrLink);
        });
      };

      ViewController.prototype.transitionPages = function(oldPage, newPage) {
        var transitionIn, transitionOut,
          _this = this;
        console.log("out: '" + (oldPage.attr('id')) + "' /// in: '" + (newPage.attr('id')) + "'");
        if (this.options.currView != null) {
          this.options.currView.cleanUp();
        }
        newPage.addClass('pt-page-current');
        transitionOut = this.getTransitionsForPage(oldPage.attr('id')).out;
        transitionIn = this.getTransitionsForPage(newPage.attr('id'))["in"];
        oldPage.addClass(transitionOut).one(this.options.animEndEventName, function() {
          _this.options.endOldPage = true;
          if (_this.options.endNewPage) {
            return _this.onEndAnimation(oldPage, newPage);
          }
        });
        newPage.addClass(transitionIn).one(this.options.animEndEventName, function() {
          _this.options.endNewPage = true;
          if (_this.options.endOldPage) {
            return _this.onEndAnimation(oldPage, newPage);
          }
        });
        return this.loadPageScripts(newPage.attr('id'), newPage);
      };

      ViewController.prototype.onEndAnimation = function(oldPage, newPage) {
        this.options.endOldPage = false;
        this.options.endNewPage = false;
        this.resetPage(oldPage, newPage);
        return this.options.isAnimating = false;
      };

      ViewController.prototype.resetPage = function(oldPage, newPage) {
        oldPage.attr('class', oldPage.data('originalClassList'));
        return newPage.attr('class', newPage.data('originalClassList') + ' pt-page-current');
      };

      ViewController.prototype.getTransitionsForPage = function(slug) {
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

      ViewController.prototype.loadPageScripts = function(slug, pageEl) {
        var _this = this;
        return require(["view/" + slug], function(View) {
          return _this.options.currView = new View({
            el: pageEl
          });
        });
      };

      return ViewController;

    })();
  });

}).call(this);
