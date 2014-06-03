require.config({
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
        'backbone.localStorage': '../bower_components/backbone.localStorage/backbone.localStorage',
        'greensock-js': '../scripts/plugins/greensock-js/src/minified/TweenMax.min',
        gsap: '../scripts/plugins/greensock-js/src/uncompressed/TweenLite',
        timelinelite: '../scripts/plugins/greensock-js/src/uncompressed/TimelineLite',
        'gsap-scroll': '../scripts/plugins/greensock-js/src/uncompressed/plugins/ScrollToPlugin',
        'gsap-text': '../scripts/plugins/greensock-js/src/uncompressed/plugins/TextPlugin',
        'gsap-easing': '../scripts/plugins/greensock-js/src/uncompressed/easing/EasePack',
        'gsap-css': '../scripts/plugins/greensock-js/src/uncompressed/plugins/CSSPlugin',
        'gsap-throwprops': '../scripts/plugins/greensock-js/src/uncompressed/plugins/ThrowPropsPlugin',
        'gsap-draggable': '../scripts/plugins/greensock-js/src/uncompressed/utils/Draggable',
        text: '../bower_components/requirejs-text/text',
        momentjs: '../bower_components/momentjs/moment',
        'requirejs-text': '../bower_components/requirejs-text/text',
        'slider-control': 'plugins/slider-control/app/scripts/SliderControl',
        clndr: '../bower_components/clndr/src/clndr',
        'parse-js-sdk': '../scripts/plugins/parse-js-sdk/lib/parse',
        'localytics-sdk': '../scripts/plugins/localytics',
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
        underscore: {
            exports: '_'
        },
        gsap: {
            deps: [
                'gsap-easing',
                'gsap-css'
            ],
            exports: 'TweenLite'
        },
        timelinelite: {
            exports: 'TimelineLite'
        },
        'gsap-draggable': {
            deps: [
                'gsap',
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

require(["jquery"], function($) {
    window.$ = window.jQuery = $;

    require(["parse-js-sdk"], function() {
        // First check that the user is actually logged in
        var appId = liveEnvironment ? "nf9lMphPOh3jZivxqQaMAg6YLtzlfvRjExUEKST3" : "0qD3LLZIOwLOPRwbwLia9GJXTEUnEsSlBCufqDvr";
        var jsId = liveEnvironment ? "SEwaoJk0yUzW2DG8GgYwuqbeuBeGg51D1mTUlByg" : "TcteeVBhtJEERxRtaavJtFznsXrh84WvOlE6hMag";
        
        Parse.initialize(appId, jsId);

        if (Parse.User.current()) {
            require(["app", "DebugHelper", "plugins/log"], function (App, DebugHelper) {
                'use strict';

                window.swipy = new App();
                window.debugHelper = new DebugHelper();
            });
        } else {
            location.pathname = "/login/"
        }
    });
});

