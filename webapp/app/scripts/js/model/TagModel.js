(function() {
  define(["js/model/BaseModel"], function(BaseModel) {
    return BaseModel.extend({
      className: "Tag",
      defaults: {
        title: "",
        deleted: false
      },
      set: function() {
        BaseModel.prototype.handleForSync.apply(this, arguments);
        return Parse.Object.prototype.set.apply(this, arguments);
      }
    });
  });

}).call(this);
