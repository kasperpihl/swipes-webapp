var jam = {
    "packages": [
        {
            "name": "backbone",
            "location": "vendor/backbone",
            "main": "backbone.js"
        },
        {
            "name": "backbone-localStorage",
            "location": "vendor/backbone-localStorage",
            "main": "main.js"
        },
        {
            "name": "chai",
            "location": "vendor/chai",
            "main": "./index"
        },
        {
            "name": "coffee-script",
            "location": "vendor/coffee-script",
            "main": "./extras/coffee-script.js"
        },
        {
            "name": "cs",
            "location": "vendor/cs",
            "main": "cs.js"
        },
        {
            "name": "hammer",
            "location": "vendor/hammer",
            "main": "hammer.js"
        },
        {
            "name": "jquery",
            "location": "vendor/jquery",
            "main": "dist/jquery.js"
        },
        {
            "name": "mocha",
            "location": "vendor/mocha",
            "main": "./index"
        },
        {
            "name": "underscore",
            "location": "vendor/underscore",
            "main": "underscore.js"
        }
    ],
    "version": "0.2.17",
    "shim": {
        "backbone": {
            "deps": [
                "underscore",
                "jquery"
            ],
            "exports": "Backbone"
        },
        "underscore": {
            "exports": "_"
        }
    }
};

if (typeof require !== "undefined" && require.config) {
    require.config({
    "packages": [
        {
            "name": "backbone",
            "location": "vendor/backbone",
            "main": "backbone.js"
        },
        {
            "name": "backbone-localStorage",
            "location": "vendor/backbone-localStorage",
            "main": "main.js"
        },
        {
            "name": "chai",
            "location": "vendor/chai",
            "main": "./index"
        },
        {
            "name": "coffee-script",
            "location": "vendor/coffee-script",
            "main": "./extras/coffee-script.js"
        },
        {
            "name": "cs",
            "location": "vendor/cs",
            "main": "cs.js"
        },
        {
            "name": "hammer",
            "location": "vendor/hammer",
            "main": "hammer.js"
        },
        {
            "name": "jquery",
            "location": "vendor/jquery",
            "main": "dist/jquery.js"
        },
        {
            "name": "mocha",
            "location": "vendor/mocha",
            "main": "./index"
        },
        {
            "name": "underscore",
            "location": "vendor/underscore",
            "main": "underscore.js"
        }
    ],
    "shim": {
        "backbone": {
            "deps": [
                "underscore",
                "jquery"
            ],
            "exports": "Backbone"
        },
        "underscore": {
            "exports": "_"
        }
    }
});
}
else {
    var require = {
    "packages": [
        {
            "name": "backbone",
            "location": "vendor/backbone",
            "main": "backbone.js"
        },
        {
            "name": "backbone-localStorage",
            "location": "vendor/backbone-localStorage",
            "main": "main.js"
        },
        {
            "name": "chai",
            "location": "vendor/chai",
            "main": "./index"
        },
        {
            "name": "coffee-script",
            "location": "vendor/coffee-script",
            "main": "./extras/coffee-script.js"
        },
        {
            "name": "cs",
            "location": "vendor/cs",
            "main": "cs.js"
        },
        {
            "name": "hammer",
            "location": "vendor/hammer",
            "main": "hammer.js"
        },
        {
            "name": "jquery",
            "location": "vendor/jquery",
            "main": "dist/jquery.js"
        },
        {
            "name": "mocha",
            "location": "vendor/mocha",
            "main": "./index"
        },
        {
            "name": "underscore",
            "location": "vendor/underscore",
            "main": "underscore.js"
        }
    ],
    "shim": {
        "backbone": {
            "deps": [
                "underscore",
                "jquery"
            ],
            "exports": "Backbone"
        },
        "underscore": {
            "exports": "_"
        }
    }
};
}

if (typeof exports !== "undefined" && typeof module !== "undefined") {
    module.exports = jam;
}