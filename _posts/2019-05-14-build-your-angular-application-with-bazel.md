---
layout: post
title: Build your Angular application with Bazel
author: cexbrayat
tags: ["Angular", "Angular 8", "Bazel"]
description: "Angular 8 adds a better support for Bazel in the CLI. Let's learn how to use it!"
---

> **Disclaimer**
> This approach has later been deprecated in Angular v10.

One of the new features of Angular 8 is the possibility
to (more easily) build your CLI application with Bazel.

[Bazel](https://bazel.build/) is a build tool developed
and massively used by Google,
as it can build pretty much any language.
The Angular framework itself is built with Bazel.

<p style="text-align: center;">
  <img class="rounded img-fluid" style="max-width: 60%" src="/assets/images/2019-05-14/bazel.svg" alt="Bazel" />
</p>

The key advantages of Bazel are:

- the possibility of building your backends and frontends with the same tool
- the incremental build and tests
- the possibility to have remote builds (and cache) on a build farm

The second point is the most useful for most developers.
Bazel allows you to declare tasks with clear inputs and outputs.
Then when you run a command, Bazel builds a task graph,
and only runs the necessary ones,
depending on which inputs and outputs changed since the last run
(very similar to what [Gradle](https://gradle.org/) does in the Java world).
This can bring impressive gains on rebuild times.

This [talk by Alex Eagle at ng-conf 2019](https://www.youtube.com/watch?v=J1lnp-nU4wM)
can be interesting to learn more about what Bazel can do.

Be warned though: the first build will be painfully slow,
as Bazel is aiming for exactly reproducible builds.
For example, if you launch your tests on Firefox,
it will download a complete version of Firefox,
to make sure all developers are running the tests in the exact same browser!
So if you want to launch the tests on a big project (like the Angular framework),
you can go grab a coffee.
But after this first build,
a change in the codebase will only trigger the smallest rebuild possible.
It's especially useful if your application is made of several modules and libraries.

You can check out
[this slide deck from the Google team](https://docs.google.com/presentation/d/1OwktccLvV3VvWn3i7H2SuZkBeAQ8z-E5RdJODVLf8SA)
if you want to dive deeper into Bazel.
You'll learn how it works under the hood
and how to do crazy stuff like querying the build graph,
profiling your build, etc.

You have two options to give a try to Bazel with the CLI:
in a new project or in an existing project.

## Starting a new project with Bazel

The Angular team wrote a collection of schematics that you can install globally:

    npm i -g @angular/bazel

and then you can use this schematic with Angular CLI
to generate a new application already configured for Bazel:

    ng new bazel-project --defaults --collection=@angular/bazel

The generated application is very similar to a "classic" Angular CLI project,
with a few different files:

- the `angular.json` file references builders from `@angular/bazel` to build, serve and test the application. Note that the classic `angular.json` file is backed up as `angular.json.bak`.
- a script called `protractor.on-prepare.js` is added to configure Protractor in the e2e project.
- a file called `initialize_testbed.ts` configures the unit tests (equivalent to the classic `test.ts` file).
- the `tsconfig.json` file is slightly tweaked, and the original is backed up in `tsconfig.json.bak`.
- a file called `angular-metadata.tsconfig.json` is added for the Angular compiler.
- a file named `rxjs_shims.js`.
- two files named `main.dev.ts` and `main.prod.ts`.

You won't see any Bazel files added, and that might seems strange,
but the CLI actually keeps them in memory.
If at any time you want to go back,
simply restore the `.bak` files and delete the new ones.

It also adds a bunch of dependencies to your application:
- `@angular/bazel`, the Bazel builders for Angular CLI
- `@bazel/bazel`, well, that's Bazel
- `@bazel/ibazel`, the Bazel watcher
- `@bazel/karma`, the rules for testing with Karma and Bazel
- `@bazel/typescript`, the rules for building with TypeScript and Bazel

Once the application is generated, you can use the usual commands:
`ng serve`, `ng test` and `ng build` but now they use Bazel!
Note that all commands run with AoT compilation,
whereas in the "classic" CLI
you have to turn it on explicitely.


## Adding Bazel to an existing project

The Angular team created a schematic to ease the migration to Bazel if you want to test it:

    ng add @angular/bazel

This backs up the existing configuration files and adds the files and dependencies
mentioned in the previous section.
Note that this is just a basic setup, and it's very likely your project won't build,
because the schematic does not analyze your dependencies and assets.
So you are going to need a few hours/days to properly configure it.
Let's see how.


## Customizing the Bazel build

If you created your project from scratch or used `ng add`,
you end up in the same situation: with a basic Bazel configuration.
As soon as you are going to add another dependency,
or if you already have some in your project,
you'll need to customize the build,
because Bazel needs to be *very* explicit on what depends on what.

But as mentioned, the Bazel files are nowhere in sight!
We need to make them appear in our project.
For that, use the option `leaveBazelFilesOnDisk`, like:

    ng build --leaveBazelFilesOnDisk

This will trigger a build and make the Bazel files
(`WORKSPACE`, `BUILD.bazel`, `.bazelrc` and `.bazelignore`) appear.
Now we can customize the build.


## Adding a new dependency

If you look into `BUILD.bazel`,
you'll see the definition of `ng_module`:

    ng_module(
        name = "src",
        srcs = glob(
            include = ["**/*.ts"],
            exclude = [
                "**/*.spec.ts",
                "main.ts",
                "test.ts",
                "initialize_testbed.ts",
            ],
        ),
        assets = glob([
          "**/*.css",
          "**/*.html",
        ]) + ([":styles"] if len(glob(["**/*.scss"])) else []),
        deps = [
            "@npm//@angular/core",
            "@npm//@angular/platform-browser",
            "@npm//@angular/router",
            "@npm//@types",
            "@npm//rxjs",
        ],
    )

This is the declaration of an NgModule that includes all TS files except the test related ones,
with assets including all CSS and HTML files (and SCSS files if there are some).
The interesting part is the `deps` attribute.
It lists every dependency,
which can be NPM modules like here,
or another `ng_module` of your app for example.
This `ng_module` will only rebuild if:
- one of the `srcs` or `assets` files changes
- one of the dependencies changes

The most common task is to add a dependency to your project.
For example, if you build a component that uses the forms support from Angular,
then you need to list that dependency:

    deps = [
        "@npm//@angular/core",
        "@npm//@angular/platform-browser",
        "@npm//@angular/router",
        "@npm//@angular/forms",
        "@npm//@types",
        "@npm//rxjs",
    ],

If you want to add an external Angular module,
like [ng-bootstrap](https://github.com/ng-bootstrap/ng-bootstrap/),
you must also add it to the `deps` attribute:

    deps = [
        "@npm//@angular/core",
        "@npm//@angular/platform-browser",
        "@npm//@angular/router",
        "@npm//@angular/forms",
        "@npm//@types",
        "@npm//rxjs",
        "@npm//@ng-bootstrap/ng-bootstrap",
    ],

and include it into the `angular-metadata.tsconfig.json`,
as the Angular compiler needs to build the external components:

    "include": [
      "node_modules/@angular/**/*",
      "node_modules/@ng-bootstrap/ng-bootstrap/*"
    ],

It gets more complicated and cumbersome if you want to add a third-party library
that doesn't have the good taste to be packaged as Bazel would want to.
For example, if you want to use [Moment.js](https://momentjs.com/),
you'll need to add it to the dependencies as expected:

    deps = [
        "@npm//@angular/core",
        "@npm//@angular/platform-browser",
        "@npm//@angular/router",
        "@npm//@angular/forms",
        "@npm//@types",
        "@npm//rxjs",
        "@npm//moment",
    ],

But after a `ng serve`, you'll notice that `moment.js` is reported missing in the browser.
In fact, you'll need to manually configure [require.js](https://requirejs.org/) to load it!
I warned you, we are far from the usual magic of the CLI
that takes care of everything for us.

Add a `require.config.js` file into your project, with the following content:

    require.config({
      paths: {
        'moment': 'npm/node_modules/moment/min/moment.min'
      }
    });

and then add this file and `moment.min.js` in the `ts_devserver` rule:

    ts_devserver(
        name = "devserver",
        port = 4200,
        entry_module = "project/src/main.dev",
        serving_path = "/bundle.min.js",
        scripts = [
            "@npm//node_modules/tslib:tslib.js",
            ":rxjs_umd_modules",
        ],
        static_files = [
            "@npm//node_modules/zone.js:dist/zone.min.js",
        ],
        data = [
            "favicon.ico",
            "@npm//node_modules/moment:min/moment.min.js",
        ],
        index_html = "index.html",
        deps = [
          ":require.config.js",
          ":src",
        ],
    )

And now you have a working `ng serve` again.


## Advanced customization

As you can see, it can take quite a bit of work to customize your project.
Fortunately, you can get inspiration from a very good example project created by the Angular team:
[angular-bazel-example](https://github.com/angular/angular-bazel-example).
It provides explanations and sources for the most common features.
But some of them, like lazy loading, are quite painful to set up.

Bazel will reveal its full potential on big projects,
where you have multiple modules and libraries depending on each others.
In that case, the rebuild times will be greatly improved,
as Bazel will analyze the graph and only rebuild what's necessary.
But it's also in that case that the setup is going to take a lot of time.

It will probably be easier to setup in the future though,
as the Angular team is still working on this.
Bazel should reach 1.0 around September
and we can hope for more auto-configuration
(for setting up lazy-loading for example).
Keep in mind that the Bazel build support is still considered an experiment,
and has the "Labs" label.
You can check out more resources on [bazel.angular.io](https://bazel.angular.io).
At the time of writing, Bazel is impressive but still for the thrill seekers!

If you want to learn more about Angular, check out our ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular))!
