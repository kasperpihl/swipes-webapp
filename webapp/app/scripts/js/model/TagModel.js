(function() {
  define(["js/model/BaseModel"], function(BaseModel) {
    return BaseModel.extend({
      className: "Tag",
      idAttribute: "objectId",
      attrWhitelist: ["title"],
      defaults: {
        title: "",
        deleted: false
      },
      set: function() {
        BaseModel.prototype.handleForSync.apply(this, arguments);
        return Backbone.Model.prototype.set.apply(this, arguments);
      },
      deleteTag: function() {
        return this.set("deleted", true, {
          sync: true
        });
      },
      updateFromServerObj: function(obj) {
        BaseModel.prototype.updateFromServerObj.apply(this, arguments);
        if (obj.title != null) {
          return this.set("title", obj.title);
        }
      }
    });
  });

}).call(this);
