(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.View.extend({
      events: {
        "click li": "toggleFilter"
      },
      initialize: function() {
        this.listenTo(swipy.tags, "add remove reset", this.render, this);
        return this.render();
      },
      toggleFilter: function(e) {
        var el, tag;
        tag = e.currentTarget.innerText;
        el = $(e.currentTarget).toggleClass("selected");
        if (el.hasClass("selected")) {
          return Backbone.trigger("apply-filter", "tag", tag);
        } else {
          return Backbone.trigger("remove-filter", "tag", tag);
        }
      },
      render: function() {
        var list, tag, _i, _len, _ref;
        list = this.$el.find(".rounded-tags");
        list.empty();
        _ref = swipy.tags.models;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          tag = _ref[_i];
          this.renderTag(tag, list);
        }
        this.renderTagInput(list);
        return this.el;
      },
      renderTag: function(tag, list) {
        return list.append("<li>" + (tag.get('title')) + "</li>");
      },
      renderTagInput: function(list) {
        return list.append("				<li class='tag-input'>					<form class='add-tag'>						<input type='text' placeholder='Add new tag'>					</form>				</li>");
      },
      remove: function() {
        this.stopListening();
        this.undelegateEvents();
        return this.$el.remove();
      }
    });
  });

}).call(this);
