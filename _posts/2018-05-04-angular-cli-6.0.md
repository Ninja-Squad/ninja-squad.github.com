---
layout: post
title: What's new in Angular CLI 6.0?
author: cexbrayat
tags: ["Angular 2", "Angular", "Angular 4", "Angular 5", "Angular 6", "Angular CLI"]
description: "Library support, new architecture, ng update, Webpack 4, dynamic lazy-loading, breaking changes and more!"
---

[Angular CLI 6.0.0](https://github.com/angular/angular-cli/releases/tag/v6.0.0) is out with some nice new features!

The version number can be a bit surprising as the last release was... 1.7!
The Angular team decided to now release the CLI with the rest of the framework, hence the big jump.
Check out our article about [Angular&nbsp;6.0](/2018/05/04/what-is-new-angular-6/) if you haven't!

But it is also a big major release because the internals have changed to offer us more possibilities!
Note that the update might not be straightforward, as a few things have changed.

If you want to upgrade to 6.0.0 without pain (or to any other version, by the way), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (1.2.1 for example), and the target version (6.0.0 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/1.2.1...6.0.0](https://github.com/cexbrayat/angular-cli-diff/compare/1.2.1...6.0.0). You have no excuse for staying behind anymore!

Let's see what new features we have!

## Support for libraries and multiple applications

This was a long time request from developers, and now we have it!
It's possible with this new version to have several applications in the same CLI project
(now called a `workspace`), and to create libraries (a shared set of components, directives, pipes and services)!

It will now be easier to share a few components across multiple applications for example.
A new schematic has been added to help you generate a library.

Just run `ng generate library`, and it will scaffold the necessary in the `projects` directory.
It relies upon [`ng-packagr`](https://github.com/dherges/ng-packagr),
which was the de facto tool to create Angular libraries,
because it handles all the details of packaging the library following the official
[Angular Packaging Format](https://docs.google.com/document/d/1CZC2rcpxffTDfRDs6p1cfbmKNLA6x5O-NtkJglDaBVs/edit).
Based on `ng-packagr`, the CLI can now build a library, and produces all the required files
(es5 bundle, esm2015 bundle, umd bundle, metadata file for AoT compilation, public API file...).
I'm not an expert on the topic,
but it looks like you just need to `npm publish` the result and you're good to go!

You can also have several applications in your project, with `ng generate application`.
Actually you already have two now by default: your main application and an application containing the `e2e` tests.

The cool thing is that you can directly import from the library into your applications
in the same CLI project, even without publishing the library on NPM.

For example, let's say you generated a `shared` library.
By default the CLI will produced a `shared` directory inside `projects`,
with a `ShareComponent` and a `SharedService`.
You'll have something like:

    cli-6
    - projects
    -- shared
    --- src
    ---- lib
    ----- share.module.ts
    ----- share.component.ts
    ----- share.service.ts
    - src
    -- app
    --- app.module.ts
    --- app.component.ts
    --- ...

If you want to use the `SharedService` inside your application,
for example in `app.component.ts`,
you simply have to import:

    import { Component } from '@angular/core';
    import { SharedService } from 'shared';

    @Component({
      selector: 'app-root',
      templateUrl: './app.component.html',
      styleUrls: ['./app.component.css']
    })
    export class AppComponent {
      title = 'app';

      constructor(sharedService: SharedService) {
        // note the import at the top!
      }
    }

And the CLI will handle it!

This opens great possibilities for large project,
and for developers to open source libraries of useful components and services!

A slightly annoying thing right now:
when you make a change to the library source,
you'll have to rebuild it manually if you want the rest of the project to see it,
because there is no watch mode for `ng build` in a library (yet).

## A new architecture

The CLI as you knew it has been broken down into several small pieces
to allow the multi-projects/libraries architecture.

Most of what used to live in the CLI now lives in various schematics.
In fact, pretty much everything is a schematic now,
and the CLI is just a "schematic runner".
The CLI role is now to execute commands,
and it does so with its new "Architect" package (`@angular-devkit/architect`).

The `run` command of `architect` accepts a target (which command to execute) and a project.
So, in theory, all commands should be like:

     ng run <project>:<target>[:configuration] [...options]

But a few commands are a special case and can be run directly, like `build`, `lint`, `test`, `xi18n`. `ng serve` and `ng e2e` needs the project to be specified, except if there is just one with this target in the workspace.

So running `ng build` is the same as running `ng run *:build`,
`ng lint my-app` is the same as running `ng run my-app:lint`,
`ng serve` is the same as running `ng run my-app:serve`,
you get it...

A few commands are not delegating to `@angular-devkit/architect` but to `@angular-devkit/schematics`.
These commands are `ng new my-app` (which is the same as `ng generate @schematics/angular:application my-app`), `ng update` and `ng add`.
But I'll come back to these two lasts in a dedicated section.

This new architecture comes at a price though:
a bunch of configuration files have changed.
Some code has been moved around,
a new dev dependency has been added (`@angular-devkit/build-angular`),
but most importantly, `.angular-cli.json` is now deprecated and replaced by `angular.json`.

This new configuration file looks like:

    {
      "version": 1,
      "newProjectRoot": "projects",
      "projects": {
        "ponyracer": {
          "root": "",
          "projectType": "application",
          "cli": {
            "packageManager": "yarn"
          },
          "architect": {
            "build": {
              "builder": "@angular-devkit/build-angular:browser",
              "options": {
                "outputPath": "dist",
                "index": "src/index.html",
                "main": "src/main.ts",
                // ...

It's far bigger than this sample of course,
but you can find what I was explaining about the new architecture.
The new applications or libraries will be generated in the `projects` directory,
My configuration is for one project, called `ponyracer` and it's  an application.
The CLI can be customized to use another package manager like Yarn.
And then you have a long section for `architect`, the command runner.
Each available command is a key, for which a builder is needed.
For example, `build` runs `@angular-devkit/build-angular:browser`,
with a bunch of options you can override if you want to.

Migrating to this new configuration is a bit cumbersome,
but not that hard.
You can do it by hand, using [`angular-cli-diff`](https://github.com/cexbrayat/angular-cli-diff/compare/1.7.0...6.0.0) to help you,
or you can try the brand new `ng update` feature of the CLI.

## ng update and ng add

The `ng update` command has been introduced in 1.7 but was a glorified `npm install`.
With this release, it starts to express its potential!

It's now a command that can install packages and run migration scripts automatically.
The command will look into the `package.json` file of the package you're specifying
for a key called `ng-update`.
If it finds one, it will try to run the migration scripts found.
You have to specify from which version you update (and to which one if you want to).

The CLI itself offers a migration script to go from 1.x to 6.0.
You can run the migration script alone with `ng update @angular/cli --migrate-only --from=1.7.4`,
and it ill automatically add the missing dependencies, move the code around to match the new layout,
and migrate the old configuration file to the new `angular.json` one.
It works well enough in that case, even if it was not perfect when we tried it.
So give it a try, but don't trust it blindly and check manually if everything looks good.

RxJS also offers scripts to update your app to RxJS v6,
with `ng update rxjs --migrate-only --from=5.5.9` for example.

Note that the same is possible with `ng add`:
when adding a package with `ng add`,
the CLI will look for the `ng-add` key in the `package.json` file
of the package you are installing and will run it.
For example, if you add Angular Element to your project with `ng add @angular/elements`,
a script will add the required polyfill to your application.
Another example is Angular Material: just run `ng add @angular/material`
and it will set up your application,
by adding the CSS imports, the default theme, the necessary module import, etc.
Material goes even further and provides a few schematics that you can use.
For example, if your run `ng generate @angular/material:material-nav --name=nav`,
it will generate a component `NavComponent` with the boilerplate necessary
in its template to display a navbar.

On the paper, it looks great and _kind of_ what Facebook does for React with the [codemod  project](https://github.com/reactjs/react-codemod).
In practice, it will greatly depend on whether the eco-system adopts it or not.
But this could be quite cool if the feature becomes reliable.
We can imagine migrating Angular or the CLI from one version to the next
by relying solely on the tooling and one command line!

## New schematics

Now that the CLI is broken down into several pieces,
we have one package/schematic per functionnality.
Let's have an overview on which packages are currently available:

- `@angular-devkit/build-angular`: this is the one to build an Angular application,
now a required dependency in your CLI projects.
- `@angular-devkit/build-ng-packagr`: this is the schematic for generating and building a library,
based on `ng-packagr`.
- `@angular/pwa`: the schematic to transform your app into a Progressive Web App. See our [blog post about it](/2017/12/12/angular-cli-1.6/) for more details about PWA and Service Workers support. Just run `ng add @angular/pwa` and you'll have transformed your application into a progressive one!
- `@angular-devkit/build-optimizer`: the plugin that makes crazy optimizations to your application,
to ship as few code as possible to your users.

## Breaking changes

The CLI 6.0 supports only Angular 5.x and 6.x of course (check out [our blog post about Angular&nbsp;6.0](/2018/05/04/what-is-new-angular-6/)), but not Angular 2.x et 4.x anymore.

The minimum NodeJS version has also changed to 8.9+ (and NPM to 5.5+).

The configuration files and the project layout have changed quite a bit,
as we pointed out above, so you'll have to move things around and migrate your configuration files
(with `ng update` and/or manually by checking [`angular-cli-diff`](https://github.com/cexbrayat/angular-cli-diff/compare/1.7.0...6.0.0))

Note that the environment concept has slightly changed
and is now called a `configuration`.
You can't run `ng build --env=prod` anymore as the option has been removed,
and building with `ng build --prod` is now the same as running `ng build --configuration=prod`.
A configuration can contain build options and file replacements.
A build option is typically `--aot` for example.
A file replacement is what is done natively with the `environment.ts` file,
which is replaced at build time by `environment.prod.ts` as it was previously.
The cool thing is that you can create several configurations
to avoid memorizing a long command.
For example, when you want to build the application in a specific locale,
you have to type something like: `ng build --aot --output-path=dist/fr --i18n-locale=fr --i18n-format=xlf --i18n-file=src/locale/messages.fr.xlf`
(which nobody can remember).
With this new configuration system, you can add your configuration to your `angular.json` file:

    "build": {
      "builder": "@angular-devkit/build-angular:browser",
      "configurations": {
        "fr": {
          "aot": true,
          "outputPath": "dist/fr",
          "i18nFile": "src/locale/messages.fr.xlf",
          "i18nFormat": "xlf",
          "i18nLocale": "fr"
        }

A configuration can also contain as many file replacements as you want.
For example the `production` configuration replaces `environment.ts` by `environment.prod.ts`.

    "configurations": {
      "production": {
        "fileReplacements": [
          {
            "replace": "src/environments/environment.ts",
            "with": "src/environments/environment.prod.ts"
          }
        ],

A configuration is specific to a command.
In my example above, I added the `fr` configuration to the build command,
allowing to run `ng build --configuration=fr`.
But you can reuse a configuration for another command by referencing it:

    "serve": {
      "builder": "@angular-devkit/build-angular:dev-server",
      "configurations": {
        "fr": {
          "browserTarget": "ponyracer:build:fr"
        }
      }

Another thing that can impact you:
the generated files don't have `.bundle` or `.chunk` in their names anymore.
`main.bundle.js` is now `main.js`,
but worst `admin.module.chunk.js` is now `admin-admin-module-ngfactory.js`,
reflecting that my `AdminModule` is in an `admin` directory in my project.
That's to allow people to have two modules with the same name in different locations,
at the price of a fucking long name for those who have just one...
And `inline.bundle.js` has been renamed `runtime.js`.
If you have scripts relying on these names, don't forget to update them.

Also, a few commands have lost or renamed some options and gain others...
Don't be surprised if your usual command does not work right away...
For example `--single-run` have been removed from `ng test`,
and you should now use `ng test --watch=false`.
The kind of stuff that will break a continuous integration (and the developer nerves)
when upgrading...

`ng get/set` has been removed and replaced with `ng config`,
for example you now have to use `ng config cli.packageManager yarn`.

And to finish, `ng eject` is currently not supported
(but will come back soon).

Now that the unpleasant stuff is out of the way,
let's see what other stuff this new release brings.

## Webpack 4

You probably know that under the hood the CLI uses Webpack to do the heavy lifting.
Webpack has released the 4.0 version: you can read more about it on [the offical blog](https://medium.com/webpack/webpack-4-released-today-6cdb994702d4).

TL;DR: Webpack 4 is faster, should be smarter for bundling common parts of the application,
has a new option (`sideEffects`) that will help to have a better tree-shaking, and adds WebAssembly support.

The Angular CLI team has done an awesome job and integrated Webpack 4 right away in the CLI,
and it brings some nice improvements on build times and bundle sizes.

## Dynamic lazy-loading

Angular provides a nice way to have lazy-loading in your application via the router.
This is usually enough, but sometimes you might find yourself in a situation
where you would like to lazy-load a module programmatically, on demand.

Something like:

    constructor(loader: SystemJsNgModuleLoader) {
      loader.load('app/admin/admin.module#AdminModule')
        .then(factory => ...);
    }

The problem was that the CLI was only able to bundle modules separately
if they are found in a `loadChildren` route configuration.
So you had to "trick" the CLI and Webpack to build a separate chunk.

With Angular CLI 6.0, that's no longer necessary.
A new option, called `lazyModules`, can be added to your `angular.json`,
to inform the CLI that you have other NgModules that need to be lazy-loaded,
and Webpack will build the necessary chunks:

    "lazyModules": [ "app/admin/admin.module" ]

## Better error stacks

This is not really a CLI feature as it is a rather old Zone.js feature,
but the `environment.ts` file has been enriched with an import you can uncomment:

    import 'zone.js/dist/zone-error';

It transforms the usual stack traces containing all the Zone.js frames
into a cleaner and less verbose one containing just the necessary frames.

This is only included in the development environment,
because it can have performance impact on your production code.

## Installation time

As the CLI is now split in several sub-packages,
the installation time should be greatly reduced.
So you should not have time to grab a coffee anymore
when running `npm install --global @angular/cli` ;).


To sum up, this release is a huge one for the CLI.
It does imply a bit of work from you to migrate,
but it's worth it for the modularity it brings.
You might want to let things dry a little though,
and wait for a few weeks to upgrade your main projects...

It took us quite some time to update our ebook and online training
with these novelties, but we are up-to-date!

Check out our [ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular) if you want to learn more!
