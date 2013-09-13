(function() {
  describe("Basics", function() {
    return it("App should be up and running", function() {
      return expect(window.app).to.exist;
    });
  });

  describe("To Do list items", function() {
    return describe("Selection", function() {
      return it("should do something", function() {
        return console.log("Doing something...");
      });
    });
  });

}).call(this);
