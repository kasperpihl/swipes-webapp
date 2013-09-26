(function() {
  var __slice = [].slice;

  define(["underscore", "backbone", "text!templates/edit-task.html"], function(_, Backbone, TaskTmpl) {
    return Backbone.View.extend({
      events: {
        "click .add-new-tag": "toggleTagPool",
        "click .tag-pool li:not(.tag-input)": "addTag",
        "submit .add-tag": "createTag"
      },
      initialize: function() {
        this.toggled = false;
        this.model.on("change:tags", this.render, this);
        return this.render();
      },
      toggleTagPool: function() {
        if (this.toggled) {
          return this.hideTagPool();
        } else {
          return this.showTagPool();
        }
      },
      showTagPool: function() {
        this.toggleButton(false);
        this.$el.find(".tag-pool").addClass("show");
        this.$el.find("form.add-tag input").focus();
        return this.toggled = true;
      },
      hideTagPool: function() {
        this.toggleButton(true);
        this.$el.find(".tag-pool").removeClass("show");
        this.$el.find("form.add-tag input").blur();
        return this.toggled = false;
      },
      toggleButton: function(flag) {
        var icon;
        icon = this.$el.find(".add-new-tag span");
        icon.removeClass("icon-plus icon-minus");
        return icon.addClass(flag === true ? "icon-plus" : "icon-minus");
      },
      addTag: function(e) {
        return this.addTagToModel(e.currentTarget.innerText);
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
        var tags;
        if (addToCollection == null) {
          addToCollection = true;
        }
        tags = this.model.get("tags") || [];
        if (_.contains(tags, tagName)) {
          return alert("You've already added that tag");
        }
        tags.push(tagName);
        this.model.unset("tags", {
          silent: true
        });
        if (addToCollection) {
          if (!_.contains(swipy.tags.pluck("title"), tagName)) {
            swipy.tags.add({
              title: tagName
            });
          }
        }
        return this.model.set("tags", tags);
      },
      render: function() {
        this.renderTags();
        this.renderTagPool();
        if (this.toggled) {
          this.$el.find("form.add-tag input").focus();
        }
        return this.el;
      },
      renderTags: function() {
        var icon, list, poolToggler, tagname, _i, _len, _ref;
        list = this.$el.find(" > .rounded-tags");
        list.empty();
        if (this.model.has("tags")) {
          _ref = this.model.get("tags");
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            tagname = _ref[_i];
            this.renderTag(tagname, list, true);
          }
        }
        icon = "<span class='" + (this.toggled ? "icon-minus" : "icon-plus") + "'></span>";
        poolToggler = "				<li class='add-new-tag'>					<a href='JavaScript:void(0);' title='Add a new tag'>" + icon + "</a>				</li>			";
        return list.append(poolToggler);
      },
      renderTagPool: function() {
        var allTags, list, tagInput, tagname, unusedTags, _i, _len;
        list = this.$el.find(".tag-pool .rounded-tags");
        list.empty();
        if (this.model.has("tags")) {
          allTags = swipy.tags.pluck("title");
          unusedTags = _.without.apply(_, [allTags].concat(__slice.call(this.model.get("tags"))));
          for (_i = 0, _len = unusedTags.length; _i < _len; _i++) {
            tagname = unusedTags[_i];
            this.renderTag(tagname, list);
          }
        }
        tagInput = "				<li class='tag-input'>					<form class='add-tag'>						<input type='text' placeholder='Add new tag'>					</form>				</li>			";
        return list.append(tagInput);
      },
      renderTag: function(tagName, parent, removable) {
        var removeBtn, tag;
        if (removable == null) {
          removable = false;
        }
        tag = document.createElement("li");
        tag.innerText = tagName;
        parent.append(tag);
        if (removable) {
          removeBtn = "					<a class='remove' href='JavaScript:void(0);' title='Remove'>						<span class='icon-cross'></span>					</a>				";
          return $(tag).prepend(removeBtn);
        }
      },
      cleanUp: function() {
        this.model.off();
        return this.undelegateEvents();
      }
    });
  });

}).call(this);
