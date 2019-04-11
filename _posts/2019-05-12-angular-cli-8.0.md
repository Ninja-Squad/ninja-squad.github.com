---
layout: post
title: What's new in Angular CLI 8.0?
author: cexbrayat
tags: ["Angular 8", "Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4", "Angular CLI"]
description: "Angular CLI 8.0 is out! Read all about TODO!"
---

[Angular CLI 8.0.0](https://github.com/angular/angular-cli/releases/tag/v8.0.0) is out!✨

Of course this brings us the support of the brand new Angular 8.0 version,
but also a lot of new features.

If you want to upgrade to 8.0.0 without pain (or to any other version, by the way), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (7.2.1 for example), and the target version (8.0.0 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/7.2.1...8.0.0](https://github.com/cexbrayat/angular-cli-diff/compare/7.2.1...8.0.0).
It can be a great help along the official `ng update @angular/core @angular/cli` command.
You have no excuse for staying behind anymore!

Let's see what we've got in this release!

## Angular 8 and TypeScript 3.3 (TODO 3.4?) support

This was obviously expected: Angular 8.0 is now supported by the CLI.
Note that as Angular 8.0 now requires TypeScript 3.3 (TODO 3.4?),
you will need to also update your TypeScript version.
You can checkout out what TypeScript 3.3 brings [on the Microsoft blog](TODO link to 3.3 and maybe 3.4 if supported).

The CLI now also supports the new style of lazy-loading declarations using TypeScript `import`, introduced in Angular 8.0. It is even required if you want to use Ivy (see below).

So you can change your `loadChildren` declarations from:

    loadChildren: './admin/admin.module#AdminModule'

to:

    loadChildren: () => import('./races/races.module').then(m => m.RacesModule)

Note that this must be the exact syntax for now(TODO still the case in final release?),
and you must use an arrow function, and `m` as the variable name.
The `import` feature was introduced in [TypeScript 2.4](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-2-4.html).
If you want to use `import` in your CLI project,
you must enable it by using `"module": "exnext"`
in the root `tsconfig.json` file
and adding `"experimentalImportFactories": true"` to your
`angularCompilerOptions`.

## dart-sass replaces node-sass

The CLI now uses [dart-sass](https://github.com/sass/dart-sass) instead of [node-sass](https://github.com/sass/node-sass) to build your Sass files.
The Dart implementation of Sass is now the reference implementation
and has replaced the historic Ruby one.
It is also notoriously faster.

It should not have an impact on the generated files,
but there are [some differences between the implementations](https://github.com/sass/dart-sass#behavioral-differences-from-ruby-sass) and I heard that the compiler might be slightly stricter.

You can also install `fibers` if you want to speed things up
(`npm install --save-dev fibers`).
Vue CLI, which also recently migrated to dart-sass,
mentions that the compilation can be twice as fast with `fibers` installed.

Note that all of this was already possible previously, but it is now the default,
and is technically a breaking change.
You can still use `node-sass` if you wish, by installing it explicitely.

## Ivy support

You probably know that the main feature in Angular 8.0  is Ivy.
The CLI provides a switch to give it a try.
You can test it in a new project with:

    ng new project --enable-ivy

Or in a existing project by adding the following option in your `tsconfig.json` file:

    "angularCompilerOptions": {
      "enableIvy": true
    }

and in `angular.json`, add change your lazy routes declaration as explained above.
The CLI team also offers to add `"aot": true` in your default build configuration in `angular.json`,
because they think Ivy will achieve fast rebuilds, fast enough to use AoT in development with `ng serve`.

When using Ivy, you need to compile your third party Angular modules with `ngcc` (the Angular Compatibility Compiler).
This tool generates the code necessary to compile your application with Ivy enabled (by generating the `ngComponentDef` field, `ngModuleDef` field, etc. for each dependency you use).

But no need to worry about it, as the CLI now has a Webpack plugin that takes care of it for you! Your workflow will not change, even if behind the scenes the CLI does an extra-step for you when necessary.

If you give it a try, remember that the Ivy support is still quite new 😋.

## Web worker support

This version provides a new `generate` schematic
to add a Web Worker to one of your component.
This can be handy if you want to delegate a computational heavy task
to a dedicated thread in the browser
instead of blocking the main one.

Let's say that your `PictureComponent` (in `src/app/picture`)
needs to do some CPU intensive work, like applying filters to an image.

You can run:

    ng generate web-worker picture/picture

This will generate a new file called `picture.worker.ts` in `src/app/picture`,
containing the following boilerplate code:

    addEventListener('message', ({ data }) => {
      const response = `worker response to ${data}`;
      postMessage(response);
    });

That's where you would put your heavy code computation.

and adds this other boilerplate code to your `PictureComponent`:

    if (typeof Worker !== 'undefined') {
      // Create a new
      const worker = new Worker('./picture.worker', { type: 'module' });
      worker.onmessage = ({ data }) => {
        console.log('page got message: $\{data\}');
      };
      worker.postMessage('hello');
    } else {
      // Web Workers are not supported in this environment.
      // You should add a fallback so that your program still executes correctly.
    }

to get you started.

The sample posts a simple string,
but you can post an object or an array.
It will be serialized and then deserialized so the worker receives a copy.
TODO update snippet if https://github.com/angular/angular-cli/pull/14132 lands

The schematic will also configure your CLI project
if this is the first time you add a Web Worker.
It will exclude the `worker.ts` files from your main TypeScript configuration,
and add two new TypeScript configurations named `src/tsconfig.json` and `src/tsconfig.worker.json`. The former adds `webworker` to the `lib` section,
and the latter handles the `worker.ts` file.
The `angular.json` file is also modified to add:

    "webWorkerTsConfig": "src/tsconfig.worker.json"

Then, when you'll run `ng build`, the CLI will package the Web Worker in a dedicated bundle (using [googlechromelabs/worker-plugin](https://github.com/googlechromelabs/worker-plugin)).

Note that this is different from running Angular itself in a Web Worker
via `@angular/platform-webworker`, which is not yet supported in Angular CLI.

## Usage analytics data

The CLI can now collect usage analytics data.
If you opt-in, some stats are collected and sent to the CLI team,
to help them prioritize features and improvements.
You can't really miss this new feature,
as you'll be asked after installing the new CLI version globally 🧐.

You can opt-in globally (`ng analytics on`) and per project (`ng analytics project on`).
A few metrics are collected if you opted in globally: command used, flags used, OS, Node version, CPU count and speed, RAM size, command initialization and execution time, and errors with their crash data if any occurs. If you opted-in in the project, it will even collect for build commands the number and size of your bundles (initial, lazy and total), the assets, polyfills and CSS sizes, and the number of `ngOnInit` in your code.

If you use `ng update` to update you CLI project,
you will be asked about whether you want to collect and send analytics or not (or when you install the CLI globally).

    Would you like to share anonymous usage data with the Angular Team at Google under
    Google’s Privacy Policy at https://policies.google.com/privacy? For more details and
    how to change this setting, see http://angular.io/analytics.

You can manually trigger the prompt again with: `ng analytics prompt` or `ng analytics project prompt`. You can turn it off at any time with `ng analytics off` or for a project with `ng analytics project off`.

You can find more details [on the official documentation](https://github.com/angular/angular/blob/master/aio/content/marketing/analytics.md).

I think this will be really helpful for the CLI team,
as they'll have a real insight about what's going on in the real world
(build time, test time, build sizes, etc.).

It is also possible to gather these usage analytics in your own Google Analytics, to see how your teams are using the CLI.
This can be configured globally with `ng config --global cli.analyticsSharing.tracking UA-123456-12`. More information about that can be found [here](https://github.com/angular/angular/blob/master/aio/content/cli/usage-analytics-gathering.md).

## Project layout change

You'll notice that the [project layout changed quite a bit](https://github.com/cexbrayat/angular-cli-diff/compare/7.3.0...8.0.0):

- there is no more a dedicated project for e2e tests in the `angular.json` file
- the `tsconfig.*.json`, `karma.conf.js` files have migrated to the root of the workspace, and the relative paths they contained were updated to reflect that.

## SVG templates support

It is now possible to have a file with an `svg` extension as template (instead of only HTML previously).
This was the first PR from [@oocx](https://twitter.com/oocx) and he detailled the feature himself in an [article](https://medium.com/@oocx/using-svg-files-as-component-templates-with-angular-cli-ea58fe79b6c1) that you can check if you want to learn more.

## Codelyzer 5.0

The default TSLint configuration loads additional rules from the excellent [Codelyzer](https://github.com/mgechev/codelyzer),
which has recently been released in version 5.0.
As this new version of Codelyzer renames some of its rules,
the CLI offers a schematic to automatically update your TSLint configuration
when you upgrade using `ng update @angular/cli`.
Note that Codelyzer v5 also offers new rules and deprecated some,
take a look at the [changelog](https://github.com/mgechev/codelyzer/blob/master/CHANGELOG.md#500-2019-03-27) if you want to learn more.

The update schematic will also removes the es6 imports from your `polyfills.ts` file,
as they are now added automatically if needed by the CLI (see [our article about CLI 7.3](/2019/01/31/angular-cli-7.3/)).


## PNPM support

After NPM and Yarn, The CLI now supports another package manager: [PNPM](https://github.com/pnpm/pnpm).

## New Architect API

This is just a note about the internals of the CLI.
The Architect API, responsible for running pretty much everything under the hood,
has been completely overhauled.
Check out this [blog post](TODO) on the official Angular blog if you want to learn more about it.

As you can see, this 8.0 release was packed with new features!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
