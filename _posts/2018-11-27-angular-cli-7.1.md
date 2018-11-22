---
layout: post
title: What's new in Angular CLI 7.1?
author: cexbrayat
tags: ["Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4", "Angular CLI"]
description: "Angular CLI 7.1 is out! Read about the new dependency and options!"
---

[Angular CLI 7.1.0](https://github.com/angular/angular-cli/releases/tag/v7.1.0) is out!

If you want to upgrade to 7.1.0 without pain (or to any other version, by the way), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (6.2.1 for example), and the target version (7.1.0 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/6.2.1...7.1.0](https://github.com/cexbrayat/angular-cli-diff/compare/6.2.1...7.1.0).
It can be a great help along the official `ng update @angular/core @angular/cli` command.
You have no excuse for staying behind anymore!

Let's see what we've got!

## Package manager auto detection

The CLI should now do a better job to detect the package manager you use (NPM or Yarn),
and use it for the various commands like `ng update` or `ng add`.

## tslib as a dependency

The CLI applications have a new required dependency: `tslib`.
This [Microsoft library](https://github.com/Microsoft/tslib) contains TypeScript helpers.
The CLI now uses one of them to avoid repeating code for every class regarding imports.
The use of these helpers is activated by an option `importHelpers` in the `tsconfig.json` file:

    "experimentalDecorators": true,
    "importHelpers": true,

By including these helpers, and avoiding to repeat the same code over and over,
the sizes of your bundles should be slightly reduced (don't expect miracles though).

## @angular/http removed

`@angular/http` has been deprecated for a long time in favor of `@angular/common/http`,
and it is now removed from the generated `package.json` file.

That's all for this very small release, I hope you enjoyed reading this blog post.
Stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
