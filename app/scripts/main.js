require.config({
    baseUrl: "scripts",
    paths: {
        jquery: '../bower_components/jquery/dist/jquery',
        bootstrapAffix: '../bower_components/sass-bootstrap/js/affix',
        bootstrapAlert: '../bower_components/sass-bootstrap/js/alert',
        bootstrapButton: '../bower_components/sass-bootstrap/js/button',
        bootstrapCarousel: '../bower_components/sass-bootstrap/js/carousel',
        bootstrapCollapse: '../bower_components/sass-bootstrap/js/collapse',
        bootstrapPopover: '../bower_components/sass-bootstrap/js/popover',
        bootstrapScrollspy: '../bower_components/sass-bootstrap/js/scrollspy',
        bootstrapTab: '../bower_components/sass-bootstrap/js/tab',
        bootstrapTooltip: '../bower_components/sass-bootstrap/js/tooltip',
        bootstrapTransition: '../bower_components/sass-bootstrap/js/transition',
        backbone: '../bower_components/backbone/backbone',
        requirejs: '../bower_components/requirejs/require',
        'sass-bootstrap': '../bower_components/sass-bootstrap/dist/js/bootstrap',
        underscore: '../bower_components/underscore/underscore',
        localStorage: '../bower_components/Backbone.localStorage/backbone.localStorage',
        collectionSubset: 'plugins/backbone.collectionsubset',
        'TweenLite': 'plugins/greensock-js/src/minified/TweenLite.min',
        gsap: 'plugins/greensock-js/src/uncompressed/TweenMax',
        timelinelite: 'plugins/greensock-js/src/uncompressed/TimelineLite',

        'gsap-scroll': 'plugins/greensock-js/src/uncompressed/plugins/ScrollToPlugin',
        'gsap-text': 'plugins/greensock-js/src/uncompressed/plugins/TextPlugin',
        'gsap-easing': 'plugins/greensock-js/src/uncompressed/easing/EasePack',
        'gsap-css': 'plugins/greensock-js/src/uncompressed/plugins/CSSPlugin',
        'gsap-throwprops': 'plugins/greensock-js/src/uncompressed/plugins/ThrowPropsPlugin',
        'gsap-draggable': 'plugins/greensock-js/src/uncompressed/utils/Draggable',
        text: '../bower_components/requirejs-text/text',
        momentjs: '../bower_components/momentjs/moment',
        'requirejs-text': '../bower_components/requirejs-text/text',
        'slider-control': 'plugins/slider-control/app/scripts/SliderControl',
        clndr: '../bower_components/clndr/src/clndr',
        'parse': '../bower_components/parse/parse',
        hammerjs: '../bower_components/hammerjs/hammer',
        'jquery-hammerjs': '../bower_components/jquery-hammerjs/jquery.hammer',
        mousetrap: '../bower_components/mousetrap/mousetrap',
        mousetrapGlobal: '../bower_components/mousetrap/plugins/global-bind/mousetrap-global-bind'
    },
    shim: {
        bootstrapAffix: {
            deps: [
                'jquery'
            ]
        },
        bootstrapAlert: {
            deps: [
                'jquery'
            ]
        },
        bootstrapButton: {
            deps: [
                'jquery'
            ]
        },
        bootstrapCarousel: {
            deps: [
                'jquery'
            ]
        },
        bootstrapCollapse: {
            deps: [
                'jquery'
            ]
        },
        bootstrapPopover: {
            deps: [
                'jquery'
            ]
        },
        bootstrapScrollspy: {
            deps: [
                'jquery'
            ]
        },
        bootstrapTab: {
            deps: [
                'jquery'
            ]
        },
        bootstrapTooltip: {
            deps: [
                'jquery'
            ]
        },
        bootstrapTransition: {
            deps: [
                'jquery'
            ]
        },
        backbone: {
            deps: [
                'jquery',
                'underscore'
            ],
            exports: 'Backbone'
        },
        localStorage:{
            deps:[
                'backbone'
            ],
            exports: 'localStorage'
        },
        collectionSubset:{
            deps:[
                'backbone'
            ],
            exports: 'collectionSubset'
        },
        underscore: {
            exports: '_'
        },
        gsap: {
            deps: [
                'gsap-easing',
                'gsap-css'
            ],
            exports: 'TweenMax'
        },
        timelinelite: {
            deps: [
                'gsap'
            ],
            exports: 'TimelineLite'
        },
        'gsap-draggable': {
            deps: [
                'gsap-throwprops'
            ],
            exports: 'Draggable'
        },
        clndr: {
            deps: [
                'momentjs'
            ]
        },
        'jquery-hammerjs': {
            deps: [
                'hammerjs'
            ]
        },
        mousetrapGlobal: {
            deps: ['mousetrap']
        }
    }
});
var QueryString = function () {
  // This function is anonymous, is executed immediately and
  // the return value is assigned to QueryString!
  var query_string = {};
  var query = window.location.search.substring(1);
  var vars = query.split("&");
  for (var i=0;i<vars.length;i++) {
    var pair = vars[i].split("=");
        // If first entry with this name
    if (typeof query_string[pair[0]] === "undefined") {
      query_string[pair[0]] = pair[1];
        // If second entry with this name
    } else if (typeof query_string[pair[0]] === "string") {
      var arr = [ query_string[pair[0]], pair[1] ];
      query_string[pair[0]] = arr;
        // If third or later entry with this name
    } else {
      query_string[pair[0]].push(pair[1]);
    }
  }
    return query_string;
} ();
if (typeof String.prototype.startsWith != 'function') {
  // see below for better implementation!
  String.prototype.startsWith = function (str){
    return this.indexOf(str) === 0;
  };
}
require(["jquery", "underscore", "backbone"], function($) {
    var appCache = window.applicationCache;
    if(appCache){
        window.applicationCache.addEventListener('updateready', function(e) {
            if (window.applicationCache.status == window.applicationCache.UPDATEREADY) {
                // Browser downloaded a new app cache.
                if (confirm('A new version of this site is available. Load it?')) {
                    appCache.swapCache();
                    window.location.reload();
                }
            } else {
                // Manifest didn't changed. Nothing new to server.
            }
        }, false);
    }

    /*require(["bootstrapTooltip"],function(){
        $('[data-toggle="tooltip"]').tooltip({delay:{show:1000,hide:0}});
    })*/

    $.ajax({
      url: 'http://localhost:5000/v1/users.logged',
      type: 'GET',
      dataType: 'json',
      contentType: "application/json; charset=utf-8",
      crossDomain : true,
      xhrFields: {
        withCredentials: true
      },
      success: function () {
        queryString = QueryString;
        require(["js/app", "js/DebugHelper", "plugins/log"], function (App, DebugHelper) {
            'use strict';

            window.swipy = new App();
            window.swipy.handleQueryString(queryString);
            window.swipy.manualInit();
            window.debugHelper = new DebugHelper();
            swipy.start();
        });
      },
      error: function (error) {
        location.href = location.origin + "/newlogin/"
      }
    });

    // if (localStorage.getItem("logged")) {
    //   // First check that the user is actually logged in
    //   queryString = QueryString;
    //   require(["js/app", "js/DebugHelper", "plugins/log"], function (App, DebugHelper) {
    //       'use strict';
    //
    //       window.swipy = new App();
    //       window.swipy.handleQueryString(queryString);
    //       window.swipy.manualInit();
    //       window.debugHelper = new DebugHelper();
    //       swipy.start();
    //   });
    // } else {
    //   path = location.origin + "/newlogin/"
    //
    //   location.href = path;
    // }
    // require(["parse"], function() {
    //     // First check that the user is actually logged in
    //     queryString = QueryString;
    //     var appId = "nf9lMphPOh3jZivxqQaMAg6YLtzlfvRjExUEKST3";
    //     var jsId = "SEwaoJk0yUzW2DG8GgYwuqbeuBeGg51D1mTUlByg";
    //
    //     Parse.initialize(appId, jsId);
    //     if (localStorage.getItem("slack-token")) {
    //         require(["js/app", "js/DebugHelper", "plugins/log"], function (App, DebugHelper) {
    //             'use strict';
    //
    //             window.swipy = new App();
    //             window.swipy.handleQueryString(queryString);
    //             window.swipy.manualInit();
    //             window.debugHelper = new DebugHelper();
    //             swipy.start();
    //         });
    //     } else {
    //
    //         path = location.origin + "/loginslack/"
    //         if(queryString && queryString.href){
    //             path += "?href="+queryString.href;
    //         }
    //         if(location.hash){
    //             path += "#" + location.hash.substring(1);
    //         }
    //
    //
    //
    //         location.href = path;
    //     }
    // });
});
