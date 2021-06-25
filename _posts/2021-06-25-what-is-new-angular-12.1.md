---
layout: post
title: What's new in Angular 12.1?
author: cexbrayat
tags: ["Angular 12", "Angular"]
description: "Angular 12.1 is out!"
---

Angular&nbsp;12.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#1210-2021-06-24">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This new minor version contains a few interesting features.


## ng-submitted

Angular now adds a `ng-submitted` class to `form` elements that have been submitted.
The class is automatically added on submissions, and removed on resets.
Note that the inner elements of the form do not receive this class.

This can simplify error styling, as you can now rely on this class to easily show errors
when a field is in error, but is still pristine and untouched.
Or you can use [ngx-valdemort](https://github.com/Ninja-Squad/ngx-valdemort) of course 😉.

## Templates

We can now use shorthand property declarations in templates.

    <button (click)="setName({ name: name })">Set name</button>

can now become:

    <button (click)="setName({ name })">Set name</button>

The compiler is now also a bit smarter when you use components with `ViewEncapsulation.ShadowDom`.
It will throw an error if the selector is not a valid custom element name
(see [NG2009](https://angular.io/errors/NG2009)).

The language service also continues to improve,
and it should now be possible to rename pipes directly from the templates!

## Styles

Angular v12.1 includes a migration that replaces the deprecated shadow-piercing selector from `/deep/`
with the deprecated but recommended `::ng-deep` (as there is no better solution for now).
This is required as new versions of the CLI will not support `/deep/`.

## Faster tests

Angular has a long-standing issue that slows down tests by a _lot_.
There is a trick to workaround it, and I wrote about it a few months ago, see
[One trick for 3 times faster `ng test`](/2020/11/25/faster-ng-test/).

Our main project at the moment has 2661 tests.
Without this trick, they take around 6 minutes 🐢.
With this trick, they take 1 minute and 30 seconds 🚀.

If I talk about this, it's because Angular v12.1 introduces an opt-in test configuration,
that fixes the underlying issue (it properly destroys the created modules and providers).
The `TestBed.initTestEnvironment` and `TestBed.configureTestingModule` methods now take
 an optional parameter to opt-in into the new teardown behavior.
The first one allows to set this behavior at the application level.
You can use it in your `test.ts` file if you're using the CLI:

    getTestBed().initTestEnvironment(
      BrowserDynamicTestingModule,
      platformBrowserDynamicTesting(),
      { teardown: { destroyAfterEach: true } }
    );

The tests should now be roughly as fast as with my trick: 1 minute 35 seconds in my example.
Note that this could break your tests, if you relied on the broken previous behavior.

This new option will become the default in a future version.

## Http

The `delete` method of the `HttpClient` now accepts an optional `body`.
All HTTP methods now also accept an `URLSearchParams` body.

## Service workers

The push notifications have been improved,
and we can now define what happens when a notification is clicked and the application is not opened.

Previously the `notificationClick` handler in the service worker only broadcasted the event if the app was opened.
It is now possible to specify `onActionClick` on a notification:

    {
      "notification": {
        "title": "Hey there!",
        "data": {
          "onActionClick": {
            "default": { "operation": "openWindow", "url": "ninja-squad.com" }
          }
        }
      }
    }

A few options are supported:
- `openWindow`, to open a new tab at the specified URL
- `focusLastFocusedOrOpen`, to focus the last client opened or open a new one
- `navigateLastFocusedOrOpen`, to focus the last client and navigate to the URL, or open a new one


That's all for this release!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!