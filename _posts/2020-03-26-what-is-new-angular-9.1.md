---
layout: post
title: What's new in Angular 9.1?
author: cexbrayat
tags: ["Angular 9", "Angular"]
description: "Angular 9.1 is out!"
---

Angular&nbsp;9.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#910-2020-03-25">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This is a small release in terms of features but a big release in terms of bug fixes.
As more and more people are updating their applications to Ivy,
the Angular team fixed a few remaining issues for corner cases.
All in all, it looks like the upgrade has been fairly easy for most applications
(which I still find unbelievable when you know how different the compilers/runtimes are!).

The team has also been digging into the opened issues on Github:
it's no secret that issues accumulated over these past months/years
without much feedback from the Angular team, busy as they were working on Ivy.
A lot of issues have been closed because they were already fixed by Ivy,
and all should now be properly labeled,
to allow the team to plan what should be worked on.
This is exciting, and we should see long awaited requests answered in the next months.

Let's see what version 9.1 brings us.

## TypeScript 3.8

This release comes with the support of TypeScript 3.8.
You can check out which new features TS 3.8 offers on the [Microsoft blog](https://devblogs.microsoft.com/typescript/announcing-typescript-3-8/).

## Template compiler

The Ivy compiler introduced a new `strictTemplates` option in v9
(see our [Angular 9.0 blog post](https://blog.ninja-squad.com/2020/02/07/what-is-new-angular-9.0/) for more info).
This flag is a shortcut to enable a bunch of checks,
that can be individually enabled/disabled.
A new option called `strictLiteralTypes` has been introduced
if you want to relax the check on literal types in templates
(View Engine interpreted them as `any` whereas Ivy is stricter and infers their proper type by default).

## i18n

The locale data now contain the writing direction of the locale ('rtl' or 'ltr').
A utility function `getLocaleDirection` offered by the `@angular/common` package
can help you retrieve this information in your application.

## ngcc

The Angular compatibility compiler (the piece that compiles the dependencies of your application to make them compatible with Ivy) should now be a bit faster, a bit more reliable and a bit more accurate.
This is good news as we need to run this compiler on every CI build,
and, as you have probably witnessed, every time a dependency changes on your machine
(the CLI runs it for you).
It's especially painful for those using Yarn,
as Yarn blows away the whole `node_modules` directory every time a dependency changes,
forcing `ngcc` to re-compile _every_ dependency again.
So every gain of speed on this compiler is welcome until we can get rid of it,
once all the dependencies are directly released in an Ivy compatible format.
But that's going to take a while.

## zone.js

Even if this is not really about Angular,
zone.js was recently released in version 0.10.3
and it comes with a few new features.

### Passive events

[Passive events](https://developers.google.com/web/updates/2016/06/passive-event-listeners)
can be very handy if you want to do something on an event
that happens very often, like `scroll` or `mousemove`,
but don't want to slow down the scrolling of your application:
it's here to tell the browser that it can proceed with scrolling
without waiting for the listener function to return.

Angular doesn't have a syntax to easily declare a passive event in an application,
but zone.js now offers a global variable to configure it.
For example, if your declare `(window as any)['__zone_symbol__PASSIVE_EVENTS'] = ['scroll'];`
then all the `scroll` event listeners you'll declare in your application
will be passive.

### Better Jest support

Until now, zone.js automatically added support for Jasmine and Mocha
when importing `zone-testing` (the CLI imports it in the `test.ts` file of your project).
It now also offers built-in support for [Jest](https://jestjs.io/),
a popular testing framework.

This support already existed via the community library
[`jest-preset-angular`](https://github.com/thymikee/jest-preset-angular),
which is still needed, but the library now avoids to mingle with Zone.js itself
and only focuses on the Jest part.

### MessagePort

Zone.js can now handle the
[Channel Message API](https://developer.mozilla.org/en-US/docs/Web/API/Channel_Messaging_API).
If you listen to messages in your Angular application,
the callback can now automatically run in the zone.
You can see how to disable it,
like every zone module,
in this [document](https://github.com/angular/angular/blob/master/packages/zone.js/MODULE.md).

### tickOptions

The `tick()` function that we use in asynchronous tests
can now receive an extra parameter `tickOptions`.
`tickOptions` has for the moment only one property: `processNewMacroTasksSynchronously`.
It has been introduced for a very specific use-case
with [nested timeouts](https://github.com/angular/angular/issues/33799).
By default, this property is `true` and reflects the current behavior,
where all timeouts, even the nested ones not yet installed,
are resolved when calling `tick`.
You can now give the extra option to `tick` to force it to resolve
only the currently installed timeouts.

You can also check out
[our blog post about the CLI v9.1](/2020/03/26/angular-cli-9.1/)
to see what's new there.

I'm not sure I can publicly talk about it yet,
so all I will say is that long-awaited work should start soon,
and hopefully land in the upcoming v10!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
