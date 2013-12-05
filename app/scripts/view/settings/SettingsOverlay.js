(function() {
  define(["underscore", "backbone", "view/Overlay", "text!templates/settings-overlay.html", "view/settings/BaseSubview", "view/settings/Faq", "view/settings/Policy", "view/settings/Snoozes", "view/settings/Subscription", "view/settings/Support"], function(_, Backbone, Overlay, SettingsOverlayTmpl) {
    return Overlay.extend({
      className: 'overlay settings',
      initialize: function() {
        this.setTemplate();
        this.bindEvents();
        this.showClassName = "settings-open";
        return this.hideClassName = "hide-settings";
      },
      bindEvents: function() {
        _.bindAll(this, "handleResize");
        $(window).on("resize", this.handleResize);
        return Backbone.on("settings/view", this.showSubview, this);
      },
      setTemplate: function() {
        return this.template = _.template(SettingsOverlayTmpl);
      },
      render: function() {
        var html;
        html = this.template({});
        this.$el.html(html);
        return this;
      },
      afterShow: function() {
        return this.handleResize();
      },
      show: function() {
        if (Parse.history.fragment === "settings") {
          this.killSubView();
        }
        return Overlay.prototype.show.apply(this, arguments);
      },
      showSubview: function(subView) {
        var _this = this;
        return this.killSubView().then(function() {
          var viewName;
          viewName = subView[0].toUpperCase() + subView.slice(1);
          return require(["view/settings/" + viewName], function(View) {
            _this.subview = new View();
            _this.$el.find(".overlay-content").append(_this.subview.el);
            return _this.$el.addClass("has-active-subview");
          });
        });
      },
      killSubView: function() {
        var dfd,
          _this = this;
        dfd = new $.Deferred();
        if (this.subview != null) {
          this.subview.remove().then(function() {
            _this.$el.removeClass("has-active-subview");
            _this.subview = null;
            return dfd.resolve();
          });
          return dfd.promise();
        } else {
          this.$el.removeClass("has-active-subview");
          dfd.resolve();
          return dfd.promise();
        }
      },
      handleResize: function() {
        var content, offset;
        if (!this.shown) {
          return;
        }
        content = this.$el.find(".grid");
        offset = (window.innerHeight / 2) - (content.height() / 2);
        return content.css("margin-top", offset);
      }
    });
  });

}).call(this);
