---
layout: post
title: What's new in Angular 15.1?
author: cexbrayat
tags: ["Angular 15", "Angular"]
description: "Angular 15.1 is out!"
---

Angular&nbsp;15.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/15.1.0">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This is a minor release with some interesting features: let's dive in!

## TypeScript 4.9

TypeScript 4.9 is now supported by Angular.
This new version of TypeScript brings some new features,
as you can see in the [official blog post](https://devblogs.microsoft.com/typescript/announcing-typescript-4-9/), including the new `satisfies` operator.

## Templates

It is now possible to use self-closing tags on custom elements.
This is a small but nice improvement, as it allows to write:

    <my-component />

instead of:

    <my-component></my-component>

This is also applicable to `ng-content` and `ng-container` for example.

Fun fact: this might not seem like a big change,
but this is actually the first time that Angular allows
a syntax that is not HTML compliant in templates.
Until now, templates were always valid HTML (yes, even, the binding syntax `[src]`!).
But as Angular templates are never parsed by the browser,
the Angular team decided to allow this syntax,
and it will probably be extended in the future to other non-HTML compliant syntaxes
that can improve the developer experience.


## Router

The `CanLoad` guard is now officially deprecated and replaced by the recently introduced `CanMatch` guard. They both achieve the same goal (prevent loading the children of a route), but the `CanMatch` guard can also match another route when it rejects.
`CanLoad` was also only running once, whereas `CanMatch` runs on every navigation
as the `CanActivate` guard.

It is now possible to define the `onSameUrlNavigation` option for a specific navigation to specify what to do when the user navigates to the same URL as the current one,
with two possible values: `reload` and `ignore`.
This was previously only possible globally with the `RouterConfigOptions` of the router (or `withRouterConfig` if you're using the standalone router providers).

You can now do something like:

    this.router.navigateByUrl('/user', { onSameUrlNavigation: 'reload' })

The router also gained a new event `NavigationSkipped` that is emitted when a navigation is skipped because the user navigated to the same URL as the current one or if `UrlHandlingStrategy` ignored it.

A new `withHashLocation()` function has been added to the router to configure the router to use a hash location strategy. It was previously configured via DI `{ provide: LocationStrategy, useClass: HashLocationStrategy }`. You can now write:

    providers: [provideRouter(routes, withHashLocation())]

## Core

A new function `isStandalone()` was added to check if a component, directive or pipe is standalone or not.

    const isStandalone = isStandalone(UserComponent);

## Tests

The `TestBed` now has a new method `runInInjectionContext`
to easily run a function that uses `inject()`.
This was already possible via the verbose `TestBed.inject(EnvironmentInjector).runInContext()`.
This is especially useful when you want to test a functional guard or resolver for example,
and this is what the CLI now generates by default for the tests of these entities.


## Angular CLI

As usual, you can check out our dedicated article about the new CLI version:

👉 [Angular CLI v15.1](/2023/01/11/angular-cli-15.1)


## Summary

The roadmap includes work on the CLI to be able to generate standalone applications without modules.
It also mentions some efforts on the server-side rendering story,
which is not the strong suit of Angular (compared to other mainstream frameworks)
and the possibility to use Angular without zone.js.

That's all for this release, stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
