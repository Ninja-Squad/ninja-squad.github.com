---
layout: post
title: What's new in Angular 10.0?
author: cexbrayat
tags: ["Angular 10", "Angular"]
description: "Angular 10.0 is out!"
---

Angular&nbsp;10.0.0 is here!
10 major versions is quite a milestone
(well, it's 8 in fact, as there are no Angular version 1 and 3, but you get the point)

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#1000-2020-06-24">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

Despite being a nice round number, this is a small release in terms of features.
But I'm super happy to see that the team has been digging into the open issues on Github:
it's no secret that issues accumulated over these past months/years
without much feedback from the Angular team, busy as they were working on Ivy.
We should see some improvements on this front!

Let's see what version 10.0 brings us.

## TypeScript 3.9

This release comes with the support of TypeScript 3.9,
and requires us to update our applications to use this version (TS 3.8 is no longer supported).
You can check out which new features TS 3.9 offers on the [Microsoft blog](https://devblogs.microsoft.com/typescript/announcing-typescript-3-9/).

## IE9, IE10, and IE mobile are no longer supported

As these old browsers now have a very small fraction of the market,
they are no longer officially supported by the Angular framework.

## Deprecations and breaking changes

The [Bazel builder](/2019/05/14/build-your-angular-application-with-bazel)
is now deprecated.
It never reached a stable state as it was still in the "Angular Labs",
and has not been actively used or maintained.
It does not mean that there will not be a solution for using Bazel with Angular applications,
but instead of wrapping Bazel in the CLI,
it will probably come in another form.

`WrappedValue` has been deprecated.
It was used to wrap a value, to force a change detection even if the value did not change.
The `async` pipe used to use it internally, and no longer does.
You probably never needed it, so that should not really impact you.

A fix in `forms` has also introduced a breaking change:
`valueChanges` used to fire twice on a `number` input.
this was to handle a special case with IE9.
As IE9 is no longer supported, this is no longer the case.
Again, that should not impact you, unless you were relying on this behavior.

## Service worker

The service worker package offers registration strategies since Angular 8.0.
You can check out [the article we wrote at that time](/2019/05/29/what-is-new-angular-8.0).
It now adds the possibility to set a timeout for the `registerWhenStable` strategy,
with `registerWhenStable:TIMEOUT`.
If the application does not stabilize after the timeout, the ServiceWorker registers anyway.
It can be handy if your application has an recurrent asynchronous task,
as it will never stabilize.
If you do not specify a timeout, the ServiceWorker will now register after 30 seconds by default.

It is now also possible to specify caching options with `cacheQueryOptions` for asset or data requests.

## Router

The signature of `CanLoad` changed, and it now matches the signature of `CanActivate`.
The guard can now also return an `UrlTree`. `CanActivate` had this option since Angular 7.1 (see our explanation in [this blog post](/2018/11/22/what-is-new-angular-7.1), and `CanLoad` can now do the same.

You can also check out
[our blog post about the CLI v10](/2020/06/25/angular-cli-10/)
to see what's new there.

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
