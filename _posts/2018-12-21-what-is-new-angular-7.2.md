---
layout: post
title: What's new in Angular 7.2?
author: cexbrayat
tags: ["Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4"]
description: "Angular 7.2 is out! Read about the new Bazel support and more!"
---

Angular&nbsp;7.2.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#TODO">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

Not a lot of new features in this release:
the Angular team is still mainly focused on the Ivy project,
rewriting the Angular compiler and runtime code to make it smaller, better, faster.


## ng new with Bazel support!

I was mentioning in [our article about Angular 7.1](/2018/11/22/what-is-new-angular-7.1) that the [Bazel](https://bazel.build/) support was making progress,
and this 7.2 release brings a cool new feature.
It's more a new CLI feature and maybe should be mentioned in [my blog post about "What's new in Angular CLI 7.2"](/2018/12/TODO/angular-cli-7.2), but the code of `@angular/bazel` lives in the Angular repo and not in the CLI repo.

This new feature is the possibility to generate a new project with Bazel build! 🚀

    npm i -g @angular/bazel
    ng new my-app --collection=@angular/bazel --defaults

And boom! You have a new project that uses Bazel.

You can then run the usual commands like `ng serve/build/test`,
and they will not use the default CLI builders, but the Bazel ones.

TODO doesn't work yet in beta.1

## Router

### New option for runGuardAndResolvers

This is not a left over copy/paste from the [7.1 article](/2018/11/22/what-is-new-angular-7.1):
there is another new option for `runGuardsAndResolvers` in 7.2!

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

### History state

TODO

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
