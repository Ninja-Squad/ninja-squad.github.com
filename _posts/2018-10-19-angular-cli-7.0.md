---
layout: post
title: What's new in Angular CLI 7.0?
author: cexbrayat
tags: ["Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4", "Angular CLI"]
description: "Angular CLI 7.0 is out! Read about the interactive prompts, the new flags and more!"
---

[Angular CLI 7.0.0](https://github.com/angular/angular-cli/releases/tag/v7.0.0) is out
(in fact we even have a [7.0.1](https://github.com/angular/angular-cli/releases/tag/v7.0.1) available)!

If you want to upgrade to 7.0.1 without pain (or to any other version, by the way), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (6.2.1 for example), and the target version (7.0.1 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/6.2.1...7.0.1](https://github.com/cexbrayat/angular-cli-diff/compare/6.2.1...7.0.1).
It can be a great help along the official `ng update @angular/core @angular/cli` command.
You have no excuse for staying behind anymore!

Let's see what we've got!

## Interactive prompts

One of the major additions to this version:
the CLI now offers interactive prompts on several commands
to let the developer choose some options or names.

For example, if you run `ng new` with CLI 7.0,
then it asks you:

    ? What name would you like to use for the project?
    ? Would you like to add Angular routing? y/N
    ? Which stylesheet format would you like to use? (Use arrow keys)
    ❯ CSS
      SCSS   [ http://sass-lang.com   ]
      SASS   [ http://sass-lang.com   ]
      LESS   [ http://lesscss.org     ]
      Stylus [ http://stylus-lang.com ]

You can enter the name of the project,
choose to add or not the routing support
(with No as a default value if you just press Enter),
and pick which CSS pre-processor you want,
allowing to choose between CSS, SCSS, SASS, LESS and Stylus
by using the arrow keys.

Note that all these options were already available,
but you had to know the correct flags to add.
For example `ng new ponyracer --routing --style=scss`.

If you don't specify one of the options,
a prompt will appear.
You can of course deactivate this interactive mode,
by using `ng new ponyracer --no-interactive` (no prompt at all),
or `ng new ponyracer --defaults`
(uses the default option of the prompt if it exists).

All the `ng generate` commands (`component`, `service`, `pipe`, etc.)
will also ask for the name of the entity to generate
if not provided.

You can add these prompts to your own schematics too.
See how easy it is to add,
[for example in `ng new`](https://github.com/angular/angular-cli/commit/ee7603f597dda3e9d856b7eb238731a35bf0fa35).

## Fun with flags!

A lot of flags have been added to various commands!

### ng serve

A `--verbose` flag is now available for `ng serve` and `ng build`,
displaying how much time each task took,
how much each asset weighs, etc.

### ng build

`ng build` now has a `--profile` flag.

It outputs two files:

- `chrome-profiler-events.json`
- `speed-measure-plugin.json`

The first one is a Chrome profile file,
that you can load via the `Performances` tab in your Chrome Dev Tools.
The second one is the result of the [Speed Measure Webpack plugin](https://github.com/stephencookdev/speed-measure-webpack-plugin)
and contains information about how much time each plugin took.

This is not really intended for us,
but to help the CLI team improving some projects with long build times.
If you are in this case,
you can now offer proper information to the team about your build,
and they might be able to speed things up in future releases.

The CLI README now also has [a dedicated section to CPU profiling](https://github.com/angular/angular-cli/blob/master/packages/angular/cli/README.md#cpu-profiling) of your build.

### ng generate

`ng generate component` now accepts `--viewEncapsulation=ShadowDom`
to reflect the new view encapsulation option added in
[Angular 6.1](/2018/07/26/what-is-new-angular-6.1/).

### ng new

We already talked about `--no-interactive` and `--defaults`,
but `ng new` also earned a flag called `--no-create-application`.
If you use it, the CLI will create a workspace
with the NPM, TypeScript, TSLint and Angular CLI configurations,
but with no application (so no `src` and `e2e` directories).

Along the same lines, a new flag called `--minimal`
will generate a workspace with a project,
but with the bare minimum: no unit tests or e2e tests,
no TSLint either, and it uses inline styles and templates in components.
This can be useful if you just want to setup
a repository for a quick proof of concept.

### ng test

The `--reporters` flag for the test command is back,
after disappearing for a few versions.
It allows to directly specify which reporters you want Karma to use,
so it can be useful on a CI for example.

### ng xi18n

You can now turn off the progress of the build when
extracting the `i18n` messages with: `ng xi18n --no-progress`.

## TypeScript 3.1 support

As Angular 7.0 now requires TypeScript 3.1
([check out our article about Angular 7](/2018/10/18/what-is-new-angular-7/)),
the CLI officially supports it too.
This also includes a few optimizations in `build-optimizer`
specific to Angular 7.0/TS 3.1.

## Terser instead of UglifyJS

As uglify-es is [no longer maintained](https://github.com/mishoo/UglifyJS2/issues/3156#issuecomment-392943058) and uglify-js does not support ES6+,
the CLI team has moved to [Terser](https://github.com/fabiosantoscode/terser)
for the minification phase of the build.
Terser is a fork of uglify-es that retains API and CLI compatibility with uglify-es and uglify-js@3.
It shouldn't really change the results,
but it fixes a few long standing issues with UglifyJS,
like production builds that weren't working in old Firefox ESR versions.

## Configuration

In `angular.json`, you can now ignore certain files in your assets,
with the brand new `ignore` option:

    "assets": [
      {
        "glob": "**/*",
        "input": "src/assets/",
        "ignore": ["**/*.svg"],
        "output": "/assets/"
      },
    ],

On the polyfill side,
the `reflect-metadata` polyfill (`core-js/es7/reflect`) is now only included in JiT mode,
as it is not needed in AoT (production) mode.
If you run `ng update` to update to 7.0,
it should be automatically removed and
your bundle will be a few kB lighter!

Talking about bundle sizes,
a new application now has some "budgets" set by default:

    budgets: [{
      type: 'initial',
      maximumWarning: '2mb',
      maximumError: '5mb',
    }],

When you build your application,
you'll see a warning if the bundle is over 2MB,
and an error if it is over 5MB.
You can customize these limits of course
(see [our article about the CLI 1.7](/2018/02/19/angular-cli-1.7/),
the version that introduced budgets).

## Performances

The CLI team released a new package (still experimental),
called `benchmark`.
The goal is to help benchmarking a NodeJS process,
by measuring the time, CPU usage, memory usage, etc.
So it's not specific to the CLI itself.
You can check out the [README](https://github.com/angular/angular-cli/blob/master/packages/angular_devkit/benchmark/README.md) to learn more.
The CLI team probably intends to track the performances of the various tools
they are currently releasing,
but maybe you can use it on your projects too.

## .npmrc per project

You can now define one `.npmrc` file per project in your workspace,
making it easier to deploy artefacts to your Nexus or Artifactory repository.

## Breaking change

This is a small one, but worth noting:
the CLI no longer inlines the assets less than 10kb in the CSS.
If you had a small image, it used to be inlined directly
in the generated CSS.

## Eject is not coming back

As you may know, the CLI used to have an `eject` command,
making it possible to customize the Webpack config directly
(at the price of losing the CLI support).
It was temporarily removed in CLI 6.0 due to the internal refactoring,
but it will not come back. It will be removed completely in 8.0.
The team thinks that the new configuration format provides enough
flexibility to modify the configuration of your workspace without ejecting.
They also mention [ngx-build-plus](https://github.com/manfredsteyer/ngx-build-plus)
if you want even more customization without ejecting.

That's all for this release, I hope you enjoyed reading this blog post.
Stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
