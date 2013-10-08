(function() {
  define(["underscore", "backbone", "view/Overlay", "text!templates/settings-overlay.html"], function(_, Backbone, Overlay, SettingsOverlayTmpl) {
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
        if (Backbone.history.fragment === "settings") {
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
        if (this.subview != null) {
          return this.subview.remove().then(function() {
            return _this.$el.removeClass("has-active-subview");
          });
        } else {
          this.$el.removeClass("has-active-subview");
          dfd = new $.Deferred();
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
