---
layout: post
title: What's new in Angular CLI 6.0?
author: cexbrayat
tags: ["Angular 2", "Angular", "Angular 4", "Angular 5", "Angular 6", "Angular CLI"]
description: "Angular CLI 6.0 is out! Which new features are included? Webpack 4, dynamic lazy-loading, breaking changes and more!"
---

[Angular CLI 6.0.0](https://github.com/angular/angular-cli/releases/tag/v6.0.0) is out with some nice new features!

The version number can be a bit surprising as the last release was... 1.7!
But the Angular team decided to now release the CLI with the rest of the framework, hence the big jump.

If you want to upgrade to 6.0.0 without pain (or to any other version, by the way), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (1.2.1 for example), and the target version (6.0.0 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/1.2.1...6.0.0](https://github.com/cexbrayat/angular-cli-diff/compare/1.2.1...6.0.0). You have no excuse for staying behind anymore!

Let's see what new features we have!

## Breaking changes

The CLI 6.0 supports only Angular 5.x and 6.x, but not Angular 2.x et 4.x anymore.

The minimum NodeJS version has also changed to 8.9+ (and NPM to 5.5+).

Another thing that can impact you: the generated files don't have `.bundle` or `.chunk` in their names anymore
(`main.bundle.js` -> `main.js`, `admin.module.chunk.js` -> `admin.module.js`),
and `inline.bundle.js` has been renamed `runtime.js`.
If you have scripts relying on these names, don't forget to update them.

Now that the unpleasant stuff is out of the way, let's see what this new release brings.

## Webpack 4

You probably know that under the hood the CLI uses Webpack to do the heavy lifting.
Webpack has released the 4.0 version: you can read more about it on https://medium.com/webpack/webpack-4-released-today-6cdb994702d4.

TL;DR: Webpack 4 is faster, should be smarter for bundling common parts of the application,
a new option (`sideEffects`) will help to have a better tree-shaking, and adds WebAssembly support.

The Angular CLI team has done an awesome job and integrated Webpack 4 right away in the CLI,
and it brings some nice improvements on build times and bundle sizes.

// TODO build time and bundle size bench

## Dynamic lazy-loading

Angular provides a nice way to have lazy-loading in your application via the router.
This is usually enough, but sometimes you might find yourselves in a situation
where you would like to lazy-load a module programatically, on demand.

Something like:

    constructor(loader: SystemJsNgModuleLoader) {
      loader.load('app/admin/admin.module#AdminModule')
        .then(factory => ...);
    }

The problem was that the CLI was only able to bundle modules separately
if they are found in a `loadChildren` route configuration.
So you had to "trick" the CLI and Webapck to build a separate chunk.

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


Check out our [ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](http://ninja-squad.com/training/angular) if you want to learn more!
