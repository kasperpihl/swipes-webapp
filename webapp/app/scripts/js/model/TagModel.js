(function() {
  define(["js/model/BaseModel"], function(BaseModel) {
    return BaseModel.extend({
      className: "Tag",
      idAttribute: "objectId",
      defaults: {
        title: "",
        deleted: false
      },
      set: function() {
        BaseModel.prototype.handleForSync.apply(this, arguments);
        return Backbone.Model.prototype.set.apply(this, arguments);
      }
    });
  });

}).call(this);
