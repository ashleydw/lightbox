module.exports = function (grunt) {
    "use strict";

    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

        coffee: {
            compile: {
                files: {
                    'dist/ekko-lightbox.js': 'ekko-lightbox.coffee'
                }
            }
        },
        recess: {
            options: {
                compile: true
            },
            css: {
                files: {
                    'dist/ekko-lightbox.css': 'ekko-lightbox.less'
                }
            },
            css_min: {
                options: {
                    compress: true
                },
                files: {
                    'dist/ekko-lightbox.min.css': 'ekko-lightbox.less'
                }
            }
        },
        uglify: {
            js: {
                files: {
                    'dist/ekko-lightbox.min.js': 'dist/ekko-lightbox.js'
                }
            }
        },
        watch: {
            coffee: {
                files: ['ekko-lightbox.coffee'],
                tasks: ['dist']
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-recess');

    grunt.registerTask('dist', ['coffee', 'uglify', 'recess']);
    grunt.registerTask('default', ['dist']);
};