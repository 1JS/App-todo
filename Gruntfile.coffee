"use strict"
LIVERELOAD_PORT = 35728
lrSnippet = require("connect-livereload")(port: LIVERELOAD_PORT)

# var conf = require('./conf.'+process.env.NODE_ENV);
mountFolder = (connect, dir) ->
    connect.static require("path").resolve(dir)

proxySnippet = require('grunt-connect-proxy/lib/utils').proxyRequest

# # Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*}*.js'
# use this if you want to recursively match all subfolders:
# 'test/spec/**/*.js'
module.exports = (grunt) ->
    require("load-grunt-tasks") grunt
    require("time-grunt") grunt
    
    # configurable paths
    yeomanConfig =
        app: "client"
        dist: "dist"

    try
        yeomanConfig.app = require("./bower.json").appPath or yeomanConfig.app
    grunt.initConfig
        yeoman: yeomanConfig
        watch:
            coffee:
                files: ["<%= yeoman.app %>/scripts/**/*.coffee"]
                tasks: ["coffee:dist"]

            compass:
                files: ["<%= yeoman.app %>/styles/**/*.{scss,sass}"]
                tasks: ["compass:server"]

            livereload:
                options:
                    livereload: LIVERELOAD_PORT

                files: ["<%= yeoman.app %>/index.html", "<%= yeoman.app %>/views/**/*.html", "<%= yeoman.app %>/styles/**/*.scss", ".tmp/styles/**/*.css", "{.tmp,<%= yeoman.app %>}/scripts/**/*.js", "<%= yeoman.app %>/images/**/*.{png,jpg,jpeg,gif,webp,svg}"]

        connect:
            options:
                port: 9000
                
                # Change this to '0.0.0.0' to access the server from outside.
                hostname: "localhost"

            proxies: [
                context: ["/api", "/todo"]
                host: "localhost"
                https: false
                changeOrigin: false
                xforward: false
                port: 3333
            ]

            livereload:
                options:
                    middleware: (connect) ->
                        [proxySnippet, lrSnippet, mountFolder(connect, ".tmp"), mountFolder(connect, yeomanConfig.app)]

            test:
                options:
                    middleware: (connect) ->
                        [mountFolder(connect, ".tmp"), mountFolder(connect, "test")]

            dist:
                options:
                    middleware: (connect) ->
                        [mountFolder(connect, yeomanConfig.dist)]

        open:
            server:
                url: "http://localhost:<%= connect.options.port %>"

        clean:
            dist:
                files: [
                    dot: true
                    src: [".tmp", "<%= yeoman.dist %>/*", "!<%= yeoman.dist %>/.git*"]
                ]

            server: ".tmp"

        jshint:
            options:
                jshintrc: ".jshintrc"

            all: ["Gruntfile.js", "<%= yeoman.app %>/scripts/**/*.js"]

        compass:
            options:
                sassDir: "<%= yeoman.app %>/styles"
                cssDir: ".tmp/styles"
                generatedImagesDir: ".tmp/styles/ui/images/"
                imagesDir: "<%= yeoman.app %>/styles/ui/images/"
                javascriptsDir: "<%= yeoman.app %>/scripts"
                fontsDir: "<%= yeoman.app %>/fonts"
                importPath: "<%= yeoman.app %>/bower_components"
                httpImagesPath: "styles/ui/images/"
                httpGeneratedImagesPath: "styles/ui/images/"
                httpFontsPath: "fonts"
                relativeAssets: true

            dist: {}
            server:
                options:
                    debugInfo: true

        
        # if you want to use the compass config.rb file for configuration:
        # compass: {
        #   dist: {
        #     options: {
        #       config: 'config.rb'
        #     }
        #   }
        # },
        coffee:
            options:
                sourceMap: true
                
                # join: true,
                sourceRoot: ""

            dist:
                files: [
                    expand: true
                    cwd: "<%= yeoman.app %>/scripts"
                    src: "**/*.coffee"
                    dest: ".tmp/scripts"
                    ext: ".js"
                ]

        # rev:
        #     dist:
        #         files:
        #             src: ["<%= yeoman.dist %>/scripts/**/*.js", "<%= yeoman.dist %>/styles/**/*.css", "<%= yeoman.dist %>/images/**/*.{png,jpg,jpeg,gif,webp,svg}", "<%= yeoman.dist %>/styles/fonts/*"]

        useminPrepare:
            html: "<%= yeoman.app %>/index.html"
            options:
                dest: "<%= yeoman.dist %>"
                flow:
                    steps:
                        js: ["concat"]
                        css: ["concat"]

        
        # 'css': ['concat']
        usemin:
            html: ["<%= yeoman.dist %>/**/*.html", "!<%= yeoman.dist %>/bower_components/**"]
            css: ["<%= yeoman.dist %>/styles/**/*.css"]
            options:
                dirs: ["<%= yeoman.dist %>"]

        # imagemin:
        #     dist:
        #         files: [
        #             expand: true
        #             cwd: "<%= yeoman.app %>/images"
        #             src: "**/*.{png,jpg,jpeg}"
        #             dest: "<%= yeoman.dist %>/images"
        #         ]

        htmlmin:
            dist:
                options: {}
                
                #removeCommentsFromCDATA: true,
                #                    // https://github.com/yeoman/grunt-usemin/issues/44
                #                    //collapseWhitespace: true,
                #                    collapseBooleanAttributes: true,
                #                    removeAttributeQuotes: true,
                #                    removeRedundantAttributes: true,
                #                    useShortDoctype: true,
                #                    removeEmptyAttributes: true,
                #                    removeOptionalTags: true
                files: [
                    expand: true
                    cwd: "<%= yeoman.app %>"
                    src: ["*.html", "views/*.html"]
                    dest: "<%= yeoman.dist %>"
                ]

        
        # Put files not handled in other tasks here
        copy:
            dist:
                files: [
                    expand: true
                    dot: true
                    cwd: "<%= yeoman.app %>"
                    dest: "<%= yeoman.dist %>"
                    src: [
                        "favicon.ico"
                        # bower components that has image, font dependencies
                        "bower_components/font-awesome/css/*"
                        "bower_components/font-awesome/fonts/*"
                        
                        "fonts/**/*"
                        "images/**/*"
                        "views/**/*"
                    ]
                ,
                    expand: true
                    cwd: ".tmp"
                    dest: "<%= yeoman.dist %>"
                    src: ["styles/**", "assets/**"]
                ,
                    expand: true
                    cwd: ".tmp/images"
                    dest: "<%= yeoman.dist %>/images"
                    src: ["generated/*"]
                ]

            styles:
                expand: true
                cwd: "<%= yeoman.app %>/styles"
                dest: ".tmp/styles/"
                src: "**/*.css"

        concurrent:
            server: ["coffee:dist", "compass:server", "copy:styles"]
            color: ["coffee:dist", "compass:dist", "copy:styles"]
            dist: ["coffee", "compass:dist", "copy:styles", "htmlmin"]

        concat:
            dist:
                src: ["<%= yeoman.dist %>/bower_components/angular/angular.min.js"]
                dest: "<%= yeoman.dist %>/scripts/vendor.js"

        uglify:
            dist:
                files:
                    "<%= yeoman.dist %>/scripts/app.js": [".tmp/**/*.js"]

    
    # '<%= yeoman.dist %>/scripts/vendor.js': [
    #   '<%= yeoman.dist %>/bower_components/angular/angular.min.js'
    # ]
    grunt.registerTask "server", (target) ->
        return grunt.task.run(["build", "open", "connect:dist:keepalive"])  if target is "dist"
        return grunt.task.run ["clean:server", "concurrent:color", "connect:livereload", "open", "watch"] if target is "color"
        grunt.task.run ["clean:server", "concurrent:server", 'configureProxies', "connect:livereload", "open", "watch"]

    grunt.registerTask "build", ["clean:dist", "useminPrepare", "concurrent:dist", "copy:dist", "concat", "uglify", "usemin"]
    grunt.registerTask "default", ["jshint", "build"]