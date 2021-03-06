---
layout: post
title: What's new in Angular CLI 1.7?
author: cexbrayat
tags: ["Angular 2", "Angular", "Angular 4", "Angular 5", "Angular 6", "Angular CLI"]
description: "Angular CLI 1.7 is out! Which new features are included? App budgets, ng update, e2e test suites, Angular 6 support, TypeScript 2.5 and 2.6, Webpack 4, faster builds and more!"
---

[Angular CLI 1.7.0](https://github.com/angular/angular-cli/releases/tag/v1.7.0) is out with some nice new features!

If you want to upgrade to 1.7.0 without pain (or to any other version, by the way), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (1.2.1 for example), and the target version (1.7.0 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/1.2.1...1.7.0](https://github.com/cexbrayat/angular-cli-diff/compare/1.2.1...1.7.0). You have no excuse for staying behind anymore!

Let's see what new features we have!

## App budgets

One of the major new features is the ability to set budgets for your applications.
In `.angular-cli.json`, you can now add a new section looking like:

    "apps": [
      {
        "budgets": [
          { "type": "bundle", "name": "main", "baseline": "300kb", "warning": "30kb" },
          { "type": "bundle", "name": "races", "maximumWarning": "360kb" },
          { "type": "allScript", "baseline": "1.4mb", "maximumError": "100kb" },
          { "type": "initial", "baseline": "1.6mb", "error": "100kb" },
          { "type": "any", "maximumError": "500kb" }
         ],

As you can see, there are several types of budget:

- `bundle`, a specific bundle that you name;
- `allScript`, all your application scripts;
- `all`, all the application;
- `initial`, the initial size of the application;
- `anyScript`, any one of the script;
- `any`, any one of the files.

The sizes are compared to the `baseline` you specify.
If you don't specify a baseline, then the baseline used is `0`.

There are several types of error:

- `maximumWarning`: warns you if size > baseline + maximumWarning;
- `minimumWarning`: warns you if size < baseline - minimumWarning;
- `warning`: same as defining the same `maximumWarning` and `minimumWarning`;
- `maximumError`: errors if size > baseline + maximumError;
- `minimumError`: errors if size < baseline - minimumError;
- `error`: same as defining the same `maximumError` and `minimumError`.

This is a pretty cool feature, as it allows to keep the size in check without additional tooling
(like [bundlesize](https://github.com/siddharthkp/bundlesize))!
And these may be the only budgets your app won't go over ;)

## ng update

Good news, we have now a command to automatically update the Angular dependencies of our CLI applications.

If you use the new CLI 1.7, just run:

    ng update

And all your `@angular/*` dependencies will be updated to the latest stable!
This includes all the core packages in your dependencies and devDependencies,
but also the CLI itself, and other Angular packages like Material, or DevKit.
It does so recursively, so dependencies like `rxjs`,
`typescript` or `zone.js` are automatically updated too!

The command does not have a lot of options
(only a `dry-run` option and a `next` option to update not to the latest stable, but to the next version),
so it's currently an all or nothing process.

But it relies on a schematic ([introduced in CLI 1.4, see our blog post](/2017/09/14/angular-cli-1.4/)),
called `package-update`, that you can use directly.
In broad lines, a schematic is a package that contains tasks allowing developers
to create code (a full project, a component, a service...)
and/or to update code (like updating configuration or classes, adding a dependency, etc...).
All the "classic" tasks and blueprints of Angular CLI are in the `@schematics/angular` package,
but the CLI team is gradually rolling in a few new ones to add features,
like `@schematics/package-update`.

This new schematic offers 4 tasks:
- `@angular` to update the Angular packages
- `@angular/cli` to update the CLI
- `@angular-devkit` to update the DevKit
- `all` to update all at once

The `ng update` command calls the `all` task of the schematic,
but you can use the schematic directly if you need or want to.

I've never really explained how to do so, so let's take an example:
you only want to update the Angular packages but not the CLI version.

First, install the schematic:

    yarn add --dev @schematics/package-update

Add a `schematics` script in your `package.json`:

    "scripts": {
      "ng": "ng",
      "schematics": "schematics"
      // ...
    },

and run:

    yarn schematics @schematics/package-update:@angular

And you'll only have your Angular packages (and their own dependencies) updated.

You can also specify a version to the schematic:

    yarn schematics @schematics/package-update:@angular --version 5.2.3

## Configuration simplifications

I usually don't mention that a few files have changed in the project template,
but for once it comes with a few simplifications and new options,
so you should definitively take a careful look at all the changes,
especially in the:

- `test.ts` file (new `zone.js` import, simplified logic)
- `polyfills.ts` file (shows how to use some `zone.js` capabilities)
- `tslint.json` file (rules added and removed)
- `package.json` file (lots of dependency bumps)

You can easily see these changes with our `angular-cli-diff` repository,
for example between an old version and the last one: [angular-cli-diff/compare/1.2.1...1.7.0](https://github.com/cexbrayat/angular-cli-diff/compare/1.2.1...1.7.0)

## E2e test suites

The `e2e` task can now take a `--suite` option,
to run only part of your e2e tests.
You can define suites of tests in your `protractor.conf.js` configuration file:

    exports.config = {
      suites: {
        perf: 'e2e/perf/**/*.e2e-spec.ts',
        regression: [
          'e2e/regression/**/*.e2e-spec.ts',
          'e2e/bugs/**/*.e2e-spec.ts'
        ]
      },

And then run:

    yarn e2e --suite perf,regression

## Service worker safety

Service workers are a really nice feature of modern browsers,
and Angular offers a package to help you use them,
introduced in Angular&nbsp;5 (see [our blog post](/2017/11/02/what-is-new-angular-5/)).
Angular CLI also has a very good support for them,
as we explained in [our blog post](/2017/12/12/angular-cli-1.6/).

But they can also be tricky, as everything involving caching in our industry...
If you need to deactivate an already installed service worker,
`@angular/service-worker` will include a `safety-worker.js` script starting with Angular&nbsp;6,
and the CLI 1.7 adds support to automatically include it in the production bundle.
You must then serve the content of this script at the URL of the service worker you want to unregister.

## Angular&nbsp;6 support

As Angular&nbsp;6 stable is right around the corner (end of March if everything goes well),
the CLI is now compatible with it, meaning you can give a try to version 6 right now!

## Angular Compiler options

The Angular Compiler options are now supported!

That means if you try to use for example the `fullTemplateTypeCheck` option
introduced in Angular&nbsp;5.0 (see our [blog post](/2017/11/02/what-is-new-angular-5/)),
you can now just update the `tsconfig.json` file of your CLI project,
and when you will run `ng serve --aot` or `ng build --prod` the option will be picked up!

## TypeScript 2.5 and 2.6 support

As Angular&nbsp;5.1 supports TypeScript&nbsp;2.5
(see our [blog post](/2017/12/07/what-is-new-angular-5.1/))
and Angular&nbsp;5.2 now supports TypeScript&nbsp;2.6
(see our other [blog post](/2018/01/11/what-is-new-angular-5.2/)) ,
the CLI will no longer complain if you use these TS versions.

## Webpack 4 support

As you may know, the CLI uses Webpack under the hood.
Webpack is currently in version 3 but the version 4 [should not be far away](https://medium.com/webpack/webpack-4-beta-try-it-today-6b1d27d7d7e2),
bringing in some performance enhancements and some nice features
(like the side-effect feature which should reduce our bundle sizes, better defaults, WebAssembly support, etc...).

The CLI is getting ready to switch to Webpack 4,
and we should enjoy some of these nice features (reduce bundle sizes, faster builds) soon!

## Better, faster, higher

The tasks have been slightly improved with the introduction of caching,
so your build should be faster!

Check out our [ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular) if you want to learn more!
