(function() {
  define(['controller/ViewController', 'router/MainRouter', 'collection/ToDoCollection', 'view/nav/ListNavigation'], function(ViewController, MainRouter, ToDoCollection, ListNavigation) {
    var Swipes;
    return Swipes = (function() {
      function Swipes() {
        this.todos = new ToDoCollection();
        this.viewController = new ViewController();
        this.nav = new ListNavigation();
        this.router = new MainRouter();
        Backbone.history.start({
          pushState: false
        });
        $(".add-new input").focus();
        this.todos.fetch();
      }

      return Swipes;

    })();
  });

}).call(this);
