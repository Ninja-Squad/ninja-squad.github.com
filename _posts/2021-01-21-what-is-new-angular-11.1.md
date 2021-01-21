---
layout: post
title: What's new in Angular 11.1?
author: cexbrayat
tags: ["Angular 11", "Angular"]
description: "Angular 11.1 is out!"
---

Angular&nbsp;11.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#1110-2021-01-20">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This is a relatively small release,
but with a few interesting features.
Let's dive in!

## TypeScript 4.1

TypeScript v4.1 has been released, and Angular now officially supports it.
You can read the [announcement post](https://devblogs.microsoft.com/typescript/announcing-typescript-4-1/)
on the Microsoft blog to learn more about the new TS features
(template literal types allow to do some frightening but beautiful things!).

## Angular Language Service

A ton of work has been done on the Language Service
(that powers the autocomplete/intellisense of our IDEs).
The team rewrote it from scratch to support Ivy,
and added some really nice features at the same time!

If you want to learn more about the Language Service,
and about the new features of this version,
check out [the blog post we wrote about it](/2021/01/19/angular-language-service/).

## Angular Linker

Another big part of the team work has been focused on the "linker",
a new piece that'll allow to ship partially compiled libraries to NPM
in the long term (and get rid of `ngcc`).
This is the first release with a preview of this new distribution format,
but this is not yet ready for prime time.
This deserves a dedicated blog post, which will come soon!

## Core

The `QueryList` type, that we use as the type of a field decorated
with `@ViewChildren` or `@ContentChildren`, has a new `get` method.
You can now use `elements.get(1)` instead of `elements.toArray()[1]` (which was duplicating the whole array).

As you may know, Angular has built-in support for [HammerJS](https://hammerjs.github.io/),
as long as you import `HammerModule` in your application.
HammerJS is a fairly popular library for handling touch gestures in an application.
Angular configures a lot of events out of the box
like `pan`, `pinch`, `press`, `rotate`, `swipe`, `tap`, etc.
This release adds the support of `doubletap` as well.

On the performance side, `NgZone` added a new option `shouldCoalesceRunChangeDetection`.
If you have a for loop that runs `ngZone.run`,
this option will run only one change detection for the loop instead of several ones.
It's quite specific, but may boost your application if you have such cases.

## Router

Did you know that a `canActivate` guard has no effect on a route with a `redirectTo`? No? Me neither 😛!

We now have an explicit error if we write a route configuration with both of them:

    Invalid configuration of route 'users': redirectTo and canActivate cannot be used together. Redirects happen before activation so canActivate will never be executed.

A schematic will automatically remove the useless `canActivate` guards in your route configurations when you update to v11.1.

Overall, the router received some love in this release with a bunch of fixes.
For example, you may have seen this very annoying log (that made no sense) when you run `ng test`:

    WARN: 'Navigation triggered outside Angular zone, did you forget to call 'ngZone.run()'?'

It has been fixed and the useless log is now gone!

The router also has a tiny new feature: `routerLink` now has a `relativeTo` input.
This allows to use `<a routerLink="something" [relativeTo]="route.parent">` like we do in the `router.navigate()` method.
If you give no value to this input, the `routerLink` is resolved relatively to the current route (as it is by default).
It has been introduced to fix an issue with router outlets and router links,
so you'll probably only need it in very specific cases.

## I18n

`localize` now supports the ARB
([Application Resource Bundle](https://github.com/google/app-resource-bundle)) translation file format.
It was already supporting XMB, XLIFF, and JSON.

ARB is based on JSON, and is a popular format in some ecosystems
(I believe [Flutter](https://flutter.dev/) projects use this format).

Check [our article about CLI v11.1](/2021-01-20/angular-cli-11.1/) to see an example,
and the differences between JSON and ARB.

## Docs

I mentioned in [our Angular 11.0 article](/2020/11/11/what-is-new-angular-11.0/)
that the most frequent Angular error now have codes.
And some of them now have dedicated documentation pages, with videos!

- [NG0100: "ExpressionChangedAfterItHasBeenCheckedError" (change detection error)](https://angular.io/errors/NG0100)
- [NG0200: "Circular dependency" (dependency injection error)](https://angular.io/errors/NG0200)
- [NG0201: "No provider for X" (dependency injection error)](https://angular.io/errors/NG0201)
- [NG0300: "Multiple components match node with tagname X" (template error)](https://angular.io/errors/NG0300)
- [NG0301: "Export of name X not found" (template error)](https://angular.io/errors/NG0301)

THe compiler now also has a few dedicated error code:

- [NG1001: "Decorator argument is not an object literal"](https://angular.io/errors/NG1001)
- [NG2003: "No suitable injection token for parameter"](https://angular.io/errors/NG2003)
- [NG8001: "Unknown HTML element or component"](https://angular.io/errors/NG8001)
- [NG8002: "Unknown attribute or input"](https://angular.io/errors/NG8002)


All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!