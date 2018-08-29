---
layout: post
title: What's new in Angular CLI 6.1?
author: cexbrayat
tags: ["Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4", "Angular CLI"]
description: "Angular CLI 6.1 is out! Read about the project refactoring, the new bundling features and more!!"
---

[Angular CLI 6.1.0](https://github.com/angular/angular-cli/releases/tag/v6.1.0) is out
(in fact we even have a [6.1.1](https://github.com/angular/angular-cli/releases/tag/v6.1.1) available)!

It is less feature rich than the previous releases:
most of the work in this release consists in refactorings and bug fixes.

If you want to upgrade to 6.1.1 without pain (or to any other version, by the way), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (6.0.0 for example), and the target version (6.1.1 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/6.0.0...6.1.1](https://github.com/cexbrayat/angular-cli-diff/compare/6.0.0...6.1.1). You have no excuse for staying behind anymore!


Let's see what we've got!

## Internal refactoring

Even if that's not super useful to you as a developer,
the `devkit` project (upon which the CLI relies a lot internally)
is now in the same repository than the `angular-cli` project.

It used to be slightly painful to open issues and contribute code,
because it was hard to figure out which repository the issue/code belonged to.

The [angular/devkit repository](https://github.com/angular/devkit) has been archived,
and imported back into the [angular/angular-cli repository](https://github.com/angular/angular-cli),
which is now the only source of truth.


## ES2015 modules everywhere

If you check [angular-cli-diff/compare/6.0.0...6.1.1](https://github.com/cexbrayat/angular-cli-diff/compare/6.0.0...6.1.1),
you'll see that one of the changes is that `"module": "es2015"` is now used in all `tsconfig.json` files.
It means that we now have the same behaviour when serving/building/testing the app.


## Vendor source map

A new option has been introduced called `vendorSourceMap` allowing to have source maps for vendor packages.
You can use it with:

    ng build --prod --source-map --vendor-source-map

This can be useful for debugging your production packages and see what is really included,
thanks to [source-map-explorer](https://www.npmjs.com/package/source-map-explorer).

For example, this is with `sourceMap` only:

<p style="text-align: center;">
  <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/2018-07-27/source-map.png" alt="Source maps" />
</p>

and the same source maps built with `vendorSourceMap`:

<p style="text-align: center;">
  <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/2018-07-27/vendor-source-map.png" alt="Vendor source maps" />
</p>


This is all for this small release,
except the support of TypeScript 2.8 and 2.9 and the support of Angular 6.1 of course.
You can check out what's new in Angular 6.1 in our [previous blog post](/2018/07/26/what-is-new-angular-6.1).

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
