(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.View.extend({
      events: {
        "click li": "toggleFilter",
        "click .remove": "removeTag",
        "submit form": "createTag"
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
      createTag: function(e) {
        var tagName;
        e.preventDefault();
        tagName = this.$el.find("form.add-tag input").val();
        if (tagName === "") {
          return;
        }
        return this.addTagToModel(tagName);
      },
      addTagToModel: function(tagName, addToCollection) {
        if (addToCollection == null) {
          addToCollection = true;
        }
        if (_.contains(swipy.tags.pluck("title"), tagName)) {
          return alert("That tag already exists");
        } else {
          return swipy.tags.add({
            title: tagName
          });
        }
      },
      removeTag: function(e) {
        var tag, tagName;
        e.stopPropagation();
        tagName = $.trim(e.currentTarget.parentNode.innerText);
        tag = swipy.tags.findWhere({
          title: tagName
        });
        if (tag && confirm("Are you sure you want to permenently delete this tag?")) {
          return tag.destroy({
            success: function(model, response) {
              return swipy.todos.remove(model);
            },
            error: function(model, response) {
              alert("Something went wrong trying to delete the tag '" + (model.get('title')) + "' please try again.");
              return console.warn("Error deleting tag — Response: ", response);
            }
          });
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
        return list.append("				<li>					<a class='remove' href='JavaScript:void(0);' title='Remove'>						<span class='icon-cross'></span>					</a>					" + (tag.get('title')) + "				</li>");
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
