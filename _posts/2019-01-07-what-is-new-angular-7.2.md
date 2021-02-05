---
layout: post
title: What's new in Angular 7.2?
author: cexbrayat
tags: ["Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4"]
description: "Angular 7.2 is out! Read about the new Bazel support, TS 3.2 and more!"
---

Angular&nbsp;7.2.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#720-2019-01-07">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

Not a lot of new features in this release:
the Angular team is still mainly focused on the Ivy project,
rewriting the Angular compiler and runtime code to make it smaller, better, faster.

## TypeScript 3.2 support

One of the new features is the support of TypeScript 3.2,
which is the latest release!
You can check out what was introduced in [TypeScript 3.2](https://blogs.msdn.microsoft.com/typescript/2018/11/29/announcing-typescript-3-2/)
on the Microsoft blog.

## ng new with Bazel support!

I was mentioning in [our article about Angular 7.1](/2018/11/22/what-is-new-angular-7.1/) that the [Bazel](https://bazel.build/) support was making progress,
and this 7.2 release brings a cool new feature.
It's more a new CLI feature and maybe should be mentioned in my upcoming blog post about "What's new in Angular CLI 7.2", but the code of `@angular/bazel` lives in the Angular repo and not in the CLI repo.

This new feature is the possibility to generate a new project with Bazel build! 🚀

    npm i -g @angular/bazel
    ng new my-app --collection=@angular/bazel --defaults

And boom! You have a new project that uses Bazel.

You can then run the usual commands like `ng serve/build/test`,
and they will not use the default CLI builders, but the Bazel ones.
Note however that all the usual flags and options of the CLI are not supported yet.

This is still very experimental and early stage,
so you will probably encounter various issues if you give it a try.

## Router

### History state

The router gains a new feature allowing to pass dynamic data to the component you want to navigate to,
without adding them into the URL.
This could be done by using a shared service,
but it can be cumbersome to have to create a service to just pass a few data.

The router now uses the full capacity of the [Browser History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API),
and allows to pass a `state` property to `NavigationExtras`,
the options that you can pass to some router methods, like `navigateByUrl`.

    this.router.navigateByUrl('/user', { state: { orderId: 1234 } });

or in a link, thanks to a new `state` input:

    <a [routerLink]="/user" [state]="{ orderId: 1234 }">Go to user's detail</a>

The state will be persisted to the browser's `History.state` property.
Later, the value can be read from the router by using `getCurrentNavigation`:

    const navigation = this.router.getCurrentNavigation();
    this.orderId = navigation.extras.state ? navigation.extras.state.orderId : 0;

### New options for runGuardAndResolvers

This is not a left over copy/paste from the [7.1 article](/2018/11/22/what-is-new-angular-7.1/):
there are other new options for `runGuardsAndResolvers` in 7.2!

`runGuardsAndResolvers` is one of the configuration options for a route,
allowing to define when the guards and the resolvers will be run for this route.
By default, they run only when the path or matrix parameters change (value `paramsChange`).
You can override this behavior by using another value for this option like `paramsOrQueryParamsChange`,
to also trigger the guards and resolvers if a query parameter changes,
or `always` to trigger them if anything changes.
Angular 7.1 introduced a new possible value: `pathParamsChange`.
Using this value, the guards and resolvers will run if a path parameter changes,
but not if a query or matrix parameter changes.
Angular 7.2 introduces *another* option: `pathParamsOrQueryParamsChange`.
using this value, the guards and resolvers will run if a path parameter or a query parameter changes,
but not if a matrix parameter changes.

I think a configuration object with boolean switches for `path`, `query` or `matrix` parameters
would make things clearer at that point 😅.

But *another* new possibility in 7.2 is to define your own predicate function
to indicate to `runGuardsAndResolvers` if it should run the guards and resolvers.
The function should look like `(from: ActivatedRouteSnapshot, to: ActivatedRouteSnapshot) => boolean`,
for example:

    runGuardsAndResolvers: (from: ActivatedRouteSnapshot, to: ActivatedRouteSnapshot)
      => to.paramMap.get('query') !== from.paramMap.get('query')

In that case, the guards and resolvers will only run if the `query` param changed.

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
