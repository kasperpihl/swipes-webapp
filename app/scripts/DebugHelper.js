(function() {
  define(function() {
    var DebugHelper;
    return DebugHelper = (function() {
      function DebugHelper() {
        this.setDummyTodos();
        this.forceCalendar();
      }

      DebugHelper.prototype.setDummyTodos = function() {
        return swipy.todos.reset(this.getDummyData());
      };

      DebugHelper.prototype.forceCalendar = function() {
        location.hash = "list/todo";
        return setTimeout(function() {
          var list, tasks;
          tasks = swipy.todos.getActive().slice(0, 2);
          list = swipy.viewController.currView;
          list.scheduleTasks(tasks);
          return setTimeout(function() {
            return Backbone.trigger("select-date");
          }, 1400);
        }, 800);
      };

      DebugHelper.prototype.getDummyData = function() {
        return [
          {
            title: "Follow up on Martin",
            order: 0,
            schedule: new Date("September 19, 2013 16:30:02"),
            completionDate: new Date("September 02, 2013 11:51:34"),
            repeatOption: "never",
            repeatDate: null,
            tags: ["work", "client"],
            notes: ""
          }, {
            title: "Make visual research",
            order: 1,
            schedule: new Date("October 13, 2013 11:13:00"),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            notes: ""
          }, {
            title: "Buy a new Helmet",
            order: 2,
            schedule: new Date("March 1, 2017 16:30:02"),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["Personal", "work", "Bike", "Outside"],
            notes: ""
          }, {
            title: "Renew Wired Magazine subscription",
            schedule: new Date("September 17, 2013 20:30:02"),
            completionDate: null,
            repeatOption: "never",
            tags: ["presentation", "work"],
            repeatDate: null,
            notes: ""
          }, {
            title: "Clean up the house",
            order: 0,
            schedule: new Date("September 16, 2013 22:30:02"),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["Errand", "City", "work"],
            notes: ""
          }, {
            title: "Buy a biiiiiiiike!!!",
            schedule: new Date("September 17, 2013 23:59:02"),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            notes: ""
          }, {
            title: "Check that insurance covers bike",
            schedule: new Date("September 17, 2013 23:59:02"),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["Ahrengotti Del Barista e Assasino", "work"],
            notes: ""
          }, {
            title: "Build webapp",
            schedule: new Date("September 17, 2013 23:59:02"),
            completionDate: new Date("July 15, 2013 11:51:34"),
            repeatOption: "never",
            repeatDate: null,
            tags: ["Ahrengotti Del Barista e Assasino", "work"],
            notes: ""
          }, {
            title: "Learn to make Tiramisú",
            schedule: new Date("September 17, 2013 23:59:02"),
            completionDate: new Date("September 18, 2013 09:51:34"),
            repeatOption: "never",
            repeatDate: null,
            tags: ["Food", "Die hipsters"],
            notes: ""
          }, {
            title: "Learn who Martin is",
            schedule: new Date("September 17, 2013 23:59:02"),
            completionDate: new Date("September 2, 2013 09:51:34"),
            repeatOption: "never",
            repeatDate: null,
            tags: ["Work"],
            notes: ""
          }, {
            title: "Dirt Jumps, Dirt Jumps, Dirt Jumps!",
            schedule: new Date("September 17, 2013 23:59:02"),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["Random tag 2", "work"],
            notes: ""
          }
        ];
      };

      return DebugHelper;

    })();
  });

}).call(this);
