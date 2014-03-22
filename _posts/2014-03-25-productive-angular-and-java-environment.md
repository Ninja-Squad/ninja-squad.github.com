---
layout: post
title: Setting up a productive AngularJS & Java environment
author: jbnizet
tags: [angularjs, grunt]
---

Deploying a Java server application is never as fast as we would like it to be. And being forced to deploy
and redeploy again to test changes in a HTML template, a JavaScript file or a CSS file is definitely
something to avoid.

When building an AngularJS application, a big part of the development time is spent editing those static files, and it's thus really important to take time setting up a productive development environment.

## JavaScript

In the good old days, when JavaScript was mainly used to hide a `div` here and there, we used to have JS code directly
inside our pages, or, for the perfectionists, in a single large file. But these days are long gone, and it's time to adopt good practices that Java has promoted from the beginning, when NodeJS hipsters were working hard trying to display falling snowflakes in their Web 1.0 pages: one JS component per file.

AngularJS makes the first part easy: identifying the components. If everything in Java is inside a class, that's not the case in JavaScript. But AngularJS defines well-identified components: controllers, services, directives, filters.

Now, of course, you really don't want your application to download 200 small JS files before showing a functional page. That's where JavaScript build tools like [Grunt](http://gruntjs.com/) or [Gulp](http://gulpjs.com/) become necessary. 

## CSS

In the same vein, using third-party CSS frameworks like Bootstrap is becoming more and more the norm. You should be able to produce a single minified CSS file from several pieces, and/or to use a better language than CSS (like [Less](http://lesscss.org/)) to write CSS. Here again, build tools like Grunt or Gulp really help.

## Grunt

<div style="float:right; margin:20px;"><img src="/assets/images/2014-03-25/grunt-logo.svg" width="150px;"/></div>

Here's thus how we use those tools in our AngularJS-based projects:

We use [grunt-contrib-uglify](https://github.com/gruntjs/grunt-contrib-uglify) to produce a single, minified JS file from all our AngularJS files: `app-only.min.js`.

We then use [grunt-contrib-concat](https://github.com/gruntjs/grunt-contrib-concat) to concatenate the already minified JS libraries and our own minified JS, and thus produce a single, minified JS file: `app.min.js`.

![From many JS source files to a single minified one](/assets/images/2014-03-25/grunt-contrib-uglify.png)

    uglify: {
        'p2': {
            files: {
                'build/grunt/tmp/js/app-only.min.js': [
                    'src/main/webapp/js/app.js',
                    'src/main/webapp/js/services/*.js',
                    'src/main/webapp/js/filters/*.js',
                    'src/main/webapp/js/directives/*.js',
                    'src/main/webapp/js/controllers/*.js'
                ]
            }
        }
    },

    concat: {
        'app': {
            src: [
                'src/main/webapp/bower_components/angular/angular.min.js',
                'src/main/webapp/bower_components/angular-ui-router/release/angular-ui-router.min.js',
                'src/main/webapp/bower_components/angular-cookies/angular-cookies.min.js',
                'src/main/webapp/bower_components/angular-animate/angular-animate.min.js',
                'src/main/webapp/bower_components/angular-ui-bootstrap-bower/ui-bootstrap-tpls.min.js',
                'build/grunt/tmp/js/app-only.min.js'
            ],
            dest: 'build/grunt/dist/js/app-' + timestamp + '.min.js'
        }
    },

We use [grunt-contrib-less](https://github.com/gruntjs/grunt-contrib-less) to produce a single, minified CSS file from the boostrap less files and our own less files: `app.min.css`. Note that we use a timestamp to generate a unique file name. This allows us to make the browser cache those large CSS and JS files for years, while still being to be able to deploy a new version of the app. Since the new version uses different file names, the browser will download the new files immediately and won't use a stale, cached version.

![From many Less source files to a single minified CSS file](/assets/images/2014-03-25/grunt-contrib-less.png)

    less: {
        app: {
            src: 'src/main/webapp/less/app/app.less',
            dest: 'build/grunt/dist/css/app-' + timestamp + '.css'
        }
    },

Our main HTML file is named `index-dev.html`. It references every non-minified JS file and our `app.less` file (which imports all the other ones) directly. This is really useful: you make a change to any of those JS or less files, refresh the page, and you have the changes. And if you want to debug, you have access to the source code, unmodified.

We use [grunt-contrib-copy](https://github.com/gruntjs/grunt-contrib-copy) to produce 2 (or more) copies of this page:

- `index.html`: this one is the one that is used in production. It only references the `app-1385397227574.min.js` file and the `app-1385397227574.min.css` files.
- `index-e2e.html`: this one is the same as index.html, but references two additional JS files used to mock the REST backend, using `angular-mocks.js`. This allows creating end-to-end tests (yes, we know, the name is inappropriate) without depending on an actual backend. We also do more coarse-grained, end-to-end tests against the real backend.

Now how do we replace these JS and CSS references inside those HTML pages? Using the [grunt-htmlrefs](https://github.com/tactivos/grunt-htmlrefs) plugin.

![From a single html file to multiple versions of this file](/assets/images/2014-03-25/grunt-htmlrefs.png)

    copy: {
        index: {
            src: ['src/main/webapp/index-dev.html'],
            dest: 'build/grunt/tmp/index.html'
        },
        'index-e2e': {
            src: ['src/main/webapp/index-dev.html'],
            dest: 'build/grunt/tmp/e2e/index-e2e.html'
        }
    },

    htmlrefs: {
        index: {
            src: 'build/grunt/tmp/index.html',
            dest: 'build/grunt/dist/index.html',
            options: {
                timestamp: timestamp
            }
        },
        'index-e2e': {
            src: 'build/grunt/tmp/e2e/index-e2e.html',
            dest: 'build/grunt/dist/index-e2e.html',
            options: {
                timestamp: timestamp,
                includes: {
                    'e2efiles': 'src/main/webapp/js/e2e/e2e-files.inc'
                }
            }
        }
    },

All this process runs in a second and is thus almost transparent.

## Avoiding deployments

But how to avoid deploying the webapp every time we make a change? The trick is to avoid the deployment completely. We use a proxy server ([connect](http://www.senchalabs.org/connect/), using [grunt-contrib-connect](https://github.com/gruntjs/grunt-contrib-connect) and [grunt-connect-proxy](https://github.com/drewzboto/grunt-connect-proxy)), but it could be anything else) to serve the static files directly from the files inside the project, and delegate to the actual Java server for REST service requests.

![Serve files with a proxy to avoid deployments](/assets/images/2014-03-25/connect-proxy.png)

    connect: {
        server: {
            options: {
                port: 9001,
                keepalive: true,
                middleware: function (connect, options) {
                    return [
                        // serve static files from sources
                        connect.static('src/main/webapp'), 
                        // then from grunt-built files
                        connect.static('build/grunt/dist'), 
                        // then from rest services in tomcat
                        proxySnippet, 
                        // then rewrite the URL and serve index-dev.html
                        // from sources again. This allows refreshing the
                        // page even with html5-mode URLs
                        function(req, res, next) { 
                            req.url = '/index-dev.html';
                            next();
                        },
                        connect.static('src/main/webapp')
                    ];
                }
            },
            proxies: [
                {
                    context: '/api',
                    host: 'localhost',
                    port: 8080,
                    https: false,
                    changeOrigin: false
                }
            ]
        }
    },