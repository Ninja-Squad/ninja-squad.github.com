---
layout: post
title: What's new in Angular CLI 8.2?
author: cexbrayat
tags: ["Angular 8", "Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4", "Angular CLI"]
description: "Angular CLI 8.2 is out! Read all about the component style budgets, deferred scripts and build time improvements!"
---

[Angular CLI 8.2.0](https://github.com/angular/angular-cli/releases/tag/v8.2.0) is out!✨

Of course this brings us the support of the brand new [Angular 8.2 version](/2019/08/01/what-is-new-angular-8.2/),
but also a lot of new features.

If you want to upgrade to 8.2.0 without pain (or to any other version, by the way), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (7.2.1 for example), and the target version (8.2.0 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/7.2.1...8.2.0](https://github.com/cexbrayat/angular-cli-diff/compare/7.2.1...8.2.0).
It can be a great help along the official `ng update @angular/core @angular/cli` command.
You have no excuse for staying behind anymore!

Let's see what we've got in this release,
and start with new options for several commands.

## Component style budget

Angular CLI supports budgets,
a feature to check that your generated bundles are not over a certain size,
since version 1.7 (check out [our explanation here](/2018/02/19/angular-cli-1.7/)).

A new budget, `anyComponentStyle`, has been added in version 8.2,
allowing to check your component CSS sizes.
This is a very nice feature because I've audited quite a few projects
where there was no problem in the JS bundles,
but where bad practices with CSS imports resulted in bloated CSS files.
As component CSS are self-contained,
it's quite easy to make a mistake and import the whole Material
or Bootstrap CSS into each component...

You can add this check to your existing budgets by adding
the following configuration into `angular.json`:

    "budgets": [
      {
        "type": "anyComponentStyle",
        "maximumWarning": "6kb",
        "maximumError": "10kb"
      }

You can of course adjust the thresholds,
but this is the default configuration if you generate a new project.
Or you can wait for the v9 release,
and the automatic migration will add this configuration for you.

## TypeScript configuration changes and build times

If you generate a new application with Ivy enabled,
you'll notice that the `tsconfig.app.json` file has slightly changed.
We went from a configuration that was including every TS file,
and excluding the specs:


    "files": [
      "src/main.ts",
      "src/polyfills.ts"
    ],
    "include": [
      "src/**/*.ts"
    ],
    "exclude": [
      "src/test.ts",
      "src/**/*.spec.ts"
    ]

to this configuration, which only lists the entry point:

    "files": [
      "src/main.ts",
      "src/polyfills.ts"
    ],
    "include": [
      "src/**/*.d.ts"
    ]

You may wonder why this is interesting 😀.
Well, with the former configuration and under certain conditions,
the TypeScript compiler would sometimes pick up redundant files
and cause slower builds!
The new configuration might speed up the build/rebuild times for large projects!

So why is it not enabled for every project,
but only in Ivy ones then?
Because View Engine projects allow to lazy load modules with the "magic syntax"

    loadChildren: './admin/admin.module#AdminModule'

that TS does not understand,
whereas Ivy projects must use the new lazy-loading syntax

    loadChildren: () => import('./admin/admin.module').then(m => m.AdminModule)

that TS understands.
The compiler will pick up changes in the files of the lazy-loaded module as well
in an Ivy project or a View Engine (VE) project using the new syntax,
but would not be able to catch them in a VE project using the old syntax.
You can thus give it try on your project,
if you migrated to the new lazy-loading syntax introduced in 8.0.

Note that with this configuration,
the compiler now warns you if a file is not used in the build.
I spotted a few files that were not used anymore in some of our projects
thanks to that new configuration 😅.

Speaking of build time improvements,
the CLI is keeping up with the latest Webpack releases,
and [Webpack `4.38.0`](https://github.com/webpack/webpack/releases/tag/v4.38.0)
has some really good improvements for rebuild times involving lazy-loaded chunks.
If you have a large application with many lazy-loaded modules,
you should definitely give a try to CLI 8.2.

## index HTML file input/output

The `angular.json` config lets us configure where the `index.html` file is in our application.
But before 8.2, the same name was used for the output file,
which was not super flexible if you wanted to output a file not named `index.html` or in a different path.
This is now possible by using:

    index: { input: 'src/index.html', output: 'main.html' }

## deferred scripts

The scripts generated by your application are now added to `index.html` with the `defer` attribute.
This is not the case in the "modern" build,
which uses `script type="module"`
that are already deferred by default.

As you can see, this 8.2 release has some interesting new features!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
