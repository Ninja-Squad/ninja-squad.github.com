---
layout: post
title: What's new in Angular CLI 6.0?
author: cexbrayat
tags: ["Angular 2", "Angular", "Angular 4", "Angular 5", "Angular 6", "Angular CLI"]
description: "Angular CLI 6.0 is out! Which new features are included? Webpack 4, dynamic lazy-loading, breaking changes and more!"
---

[Angular CLI 6.0.0](https://github.com/angular/angular-cli/releases/tag/v6.0.0) is out with some nice new features!

The version number can be a bit surprising as the last release was... 1.7!
The Angular team decided to now release the CLI with the rest of the framework, hence the big jump.

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

The cool thing is that you can directly import from the library into your applications.
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
But I'll come back to these two last in a dedicated section.

// TODO add an extract of angular.json and explain it

## ng update

// TODO explain that ng update runs a schematic
// current examples: the CLI itself, Angular Element, RxJS

## Breaking changes

The CLI 6.0 supports only Angular 5.x and 6.x, but not Angular 2.x et 4.x anymore.

The minimum NodeJS version has also changed to 8.9+ (and NPM to 5.5+).

The configuration files and the project layout have changed quite a bit.
// TODO talk about migrating the angular-cli.json file and the rest with ng update
// and that it kinda works

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

Now that the unpleasant stuff is out of the way,
let's see what other stuff this new release brings.

## Webpack 4

You probably know that under the hood the CLI uses Webpack to do the heavy lifting.
Webpack has released the 4.0 version: you can read more about it on https://medium.com/webpack/webpack-4-released-today-6cdb994702d4.

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
A new option, called `lazyModules`, can be added to your `.angular-cli.json`,
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

Check out our [ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](http://ninja-squad.com/training/angular) if you want to learn more!
