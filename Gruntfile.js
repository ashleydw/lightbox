module.exports = function (grunt) {
    "use strict";

    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        banner:
            '/*!\n' +
            ' * Lightbox for Bootstrap 3 by @ashleydw\n' +
            ' * https://github.com/ashleydw/lightbox\n' +
            ' *\n' +
            ' * License: https://github.com/ashleydw/lightbox/blob/master/LICENSE\n' +
            ' */',

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
        usebanner: {
            dist: {
                options: {
                    banner: '<%= banner %>'
                },
                files: {
                    src: ['dist/ekko-lightbox.min.js']
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

    grunt.loadNpmTasks('grunt-banner');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-recess');

    grunt.registerTask('dist', ['coffee', 'uglify', 'recess', 'usebanner']);
    grunt.registerTask('default', ['dist']);
};