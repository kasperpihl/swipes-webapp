module.exports = function(grunt) {
	// Configure grunt and tasks
	grunt.initConfig({
		compass: {
			dev: {
				options: {
					config: 'config.rb'
				}
			}
		},
		coffee: {
			compileWithMaps: {
				options: {
					sourceMap: true
				}
			},
			dynamic_mappings: {
				files: [
					{
						expand: true,
						cwd: 'scripts/coffee/',
						src: ['**/*.coffee'],
						dest: 'scripts',
						ext: '.js'
					}
				]
			}
		},

		// Set up rules for Grunt Watch
		watch: {
			livereload: {
				files: ['**/*.html', '**/*.php'],
				options: {
					livereload: true
				}
			},
			compass: {
				files: ['styles/sass/**/*.scss'],
				tasks: 'compass',
				options: {
					livereload: true,
				},
			},
			coffee: {
				files: ['scripts/coffee/**/*.coffee'],
				tasks: 'coffee',
				options: {
					livereload: true
				}
			}
		}
	});

	// Load tasks
	grunt.loadNpmTasks('grunt-contrib-compass');
	grunt.loadNpmTasks('grunt-contrib-coffee');
	grunt.loadNpmTasks('grunt-contrib-watch');
	
	// Execute tasks
	grunt.registerTask('default', ['compass', 'coffee']);
};