---
layout: post
title: What's new in Angular 11.1?
author: cexbrayat
tags: ["Angular 11", "Angular"]
description: "Angular 11.1 is out!"
---

Angular&nbsp;11.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#TODO">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This is a relatively small release.
A ton of work has been done by the team on the Language Service (that powers the autocomplete/intellisense of our IDEs), and on the "linker", a new piece that'll allow to ship partially compiled libraries to NPM
in the long term (and get rid of `ngcc`).
This deserves a dedicated blog post, which will come soon!

## TypeScript 4.1

TypeScript v4.1 has been released, and Angular now officially supports it.
You can read the [announcement post](https://devblogs.microsoft.com/typescript/announcing-typescript-4-1/)
on the Microsoft blog to learn more about the new TS features
(template literal types allow to do some frightening but beautiful things!).

## Core

The `QueryList` type, that we use as the type of a field decorated
with `@ViewChildren` or `@ContentChildren`, has a new `get` method.
Until now, you had to use the index to access an element.
You can now use `elements.get(1)` (same as `element[1]`).

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
If you give no value to this input, the `routerLink` is resolved relatively to the root (as it is by default).
It has been introduced to fix an issue with router outlets and router links,
so you'll probably only need it in very specific cases.

## I18n

`localize` now supports the ARB
([Application Resource Bundle](https://github.com/google/app-resource-bundle)) translation file format.
It was already supporting XMB, XLIFF, and JSON.

ARB is based on JSON, and is a popular format in some ecosystems
(I believe [Flutter](https://flutter.dev/) projects use this format).


All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!