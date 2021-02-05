---
layout: post
title: What's new in Angular CLI 7.2?
author: cexbrayat
tags: ["Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4", "Angular CLI"]
description: "Angular CLI 7.2 is out! Read all about the new flags and options available!"
---

[Angular CLI 7.2.0](https://github.com/angular/angular-cli/releases/tag/v7.2.0) is out!

If you want to upgrade to 7.2.0 without pain (or to any other version, by the way), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (6.2.1 for example), and the target version (7.2.0 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/6.2.1...7.2.0](https://github.com/cexbrayat/angular-cli-diff/compare/6.2.1...7.2.0).
It can be a great help along the official `ng update @angular/core @angular/cli` command.
You have no excuse for staying behind anymore!

Let's see what we've got!

## TypeScript 3.2 support

As Angular 7.2 now supports TypeScript 3.2
([check out our article about Angular 7.2](/2019/01/07/what-is-new-angular-7.2/)),
the CLI officially supports it too.

## New flag and flag values for ng build

### new resourcesOutputPath option

It is now possible to specify where resources will be placed, relative to `outputPath`.
In short you can ouput your CSS in `other` instead of the root of the output folder with:

    ng build --resources-output-path=other

### sourceMap fine-grained values

The `sourceMap` flag of `ng build` used to take a boolean value:
`true` to generate the source maps for styles and scripts,
`false` to ignore them.

It can now take a more fine-grained value, as you can now give an object to configure if you want
only the `scripts` source maps, the `styles` source maps, the `vendor` source maps, or the `hidden` source maps,
a new feature to generate this special kind of source maps that some error reporting tools like Sentry use.

    "sourceMap": {
      "scripts": true,
      "styles": true,
      "hidden": true,
      "vendor": true
    }

The `vendor` option replaces the now deprecated `vendorSourceMap` flag.

### optimization fine-grained values

Similarly, the `optimization` flag used to take a boolean value:
`true` to activate scripts and styles optimization,
`false` to ignore them (leading to faster builds).

Now you can activate one or the other, as `optimization` can now take an object to configure it:

    "optimization": {
      "scripts": true,
      "styles": true
    }

### Build Event Log

A new flag called `buildEventLog` has been added to `ng build`.
This flag needs a filename as a parameter and will generate the specified file,
with a timeline of the build events.
Currently, running `ng build --build-event-log log.txt` generates:

    {"id":{"started":{}},"started":{"command":"build","start_time_millis":1544793799294}}
    {"id":{"finished":{}},"finished":{"finish_time_millis":1544793807037,"exit_code":{"code":0}}}

As you can see, it only logs a `started` and `finished` events for now.
This is heavily inspired by the [Build Event Protocol](https://docs.bazel.build/versions/master/build-event-protocol.html),
and we will probably get a more detailed report in the future (this is probably introduced with the future Bazel build in mind).

## New flag for ng update

A new `verbose` flag is available for this command to detail what exactly is going on and help debug potential issues.

## Flag deprecations

The CLI added the possibility to deprecate a flag in a schematic (with the `x-deprecated` field in a schema).

The team took the occasion to deprecate a few flags from the CLI itself:

- `evalSourceMap` in `ng build/serve` as it could be used to improve build performances, but isn't needed anymore.
- `vendorSourceMap` in `ng build/serve`, as it has been replaced, see above.
- `skipAppShell` in `ng build/serve` for a Web application as it had no effect.
- `styleext` in `ng generate`, and should now be `style`. It is used to specify the extension of the style file of a new component (for example, `ng generate component user --style scss`).
- `spec` in `ng generate`, and should now be `skipTests`. It is used to not generate tests (for example, `ng generate component user --skip-tests`).

## Flag override warning

Note that you will now have a warning when you specify a flag several times in the same command.
It used to pick the last one silently,
and now it will still do the same and also warn you that there is something weird going on:

    > ng build --aot --aot=false
    Option aot was already specified with value true. The new value false will override it.

But it doesn't warn you if you use: `ng build --prod --aot=false`.

That's all for this small release, I hope you enjoyed reading this blog post.
Stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
