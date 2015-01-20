require.config({
    paths: {
        jquery: '../bower_components/jquery/jquery',
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
        'greensock-js': '../bower_components/greensock-js/src/minified/TweenMax.min',
        gsap: '../bower_components/greensock-js/src/uncompressed/TweenLite',
        timelinelite: '../bower_components/greensock-js/src/uncompressed/TimelineLite',
        'gsap-scroll': '../bower_components/greensock-js/src/uncompressed/plugins/ScrollToPlugin',
        'gsap-text': '../bower_components/greensock-js/src/uncompressed/plugins/TextPlugin',
        'gsap-easing': '../bower_components/greensock-js/src/uncompressed/easing/EasePack',
        'gsap-css': '../bower_components/greensock-js/src/uncompressed/plugins/CSSPlugin',
        'gsap-throwprops': '../bower_components/greensock-js/src/uncompressed/plugins/ThrowPropsPlugin',
        'gsap-draggable': '../bower_components/greensock-js/src/uncompressed/utils/Draggable',
        text: '../bower_components/requirejs-text/text',
        momentjs: '../bower_components/momentjs/moment',
        'requirejs-text': '../bower_components/requirejs-text/text',
        'slider-control': 'plugins/slider-control/app/scripts/SliderControl',
        clndr: '../bower_components/clndr/src/clndr',
        hammerjs: '../bower_components/hammerjs/dist/jquery.hammer',
        'parse': '../bower_components/parse/parse'
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
        }
    }
});

require(["jquery", "app", "DebugHelper", "plugins/log", "parse"], function ($, App, DebugHelper) {
    'use strict';

    Parse.initialize( "0qD3LLZIOwLOPRwbwLia9GJXTEUnEsSlBCufqDvr", "TcteeVBhtJEERxRtaavJtFznsXrh84WvOlE6hMag" )

    window.$ = window.jQuery = $;
    window.swipy = new App();
    window.debugHelper = new DebugHelper();
});

