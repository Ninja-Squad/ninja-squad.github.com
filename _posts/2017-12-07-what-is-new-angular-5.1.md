---
layout: post
title: What's new in Angular 5.1?
author: cexbrayat
tags: ["Angular 2", "Angular", "Angular 4"]
description: "Angular 4.4 is out! Which new features are included?"
---

Angular 5.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#510-2017-12-06">
    <img class="img-rounded img-responsive" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This is a fairly small release, with some bugfixes but not a lot of features.

Let's see what 5.1 has in stock for us!

## i18n

The `registerLocaleData` method now has an optional parameter to set the locale id.
This allows to use a custom locale id or locales that Angular does not support.
You can now do something like:

    registerLocaleData(localeFr, 'fr-ZZ');

and the french locale data will be available for the (fake) locale id `fr-ZZ`.

## Service worker

The `@angular/service-worker` package evolves a little,
with the possibility to register the `ServiceWorkerModule` without crashing the application
even if the Service Worker API is not supported by the browser.
The `register` method has now also a new option to enable the service worker or not.
Previously you would have registered your service worker like this:

    providers: [
      environment.production ? ServiceWorkerModule.register('/ngsw-worker.js') : [],
      // ...
    ]

which would have made the Service Worker services like `SwUpdate` only available to dependency injection in production.
That was forcing us to use a trick like `Optional` to not crash the application in development:

    constructor(@Optional() private swUpdate: SwUpdate) {
      // test if swUpdate is not null
    }

With 5.1, we can do better:

    providers: [
      ServiceWorkerModule.register('/ngsw-worker.js', { enabled: environment.production }),
      // ...
    ]

With this new `enabled` option, the services will always be available to dependency injection,
making the `Optional` trick no longer necessary.
The services like `SwUpdate` now also has an `isEnabled` field to know if they are enabled or not:

    constructor(private swUpdate: SwUpdate) {
      if (swUpdate.isEnabled) {
        // ...
      }
    }

## Compiler

It's worth noting that behind the scenes, some work has been done to enable AoT unit testing.
Currently units test are run using the JiT compiler.
But as you may know, the Angular team is working to make this JiT compiler obsolete.
It's been recommended for a long time to use the AoT mode in production,
and, starting with Angular&nbsp;5.0, it's no longer necessary to use JiT even in development
as AoT has become faster (even it's still slower than JiT right now).
The last place where JiT is required is for unit testing.
That should no longer be the case soon, as some key pieces are falling into place in the framework.

Another interesting point for the compiler: the error messages should now be clearer
(especially when you make a mistake in a decorator)!

Angular now also officially supports TypeScript 2.5.x.

That's all for this small release!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](http://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
