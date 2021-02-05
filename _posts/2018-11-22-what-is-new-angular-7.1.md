---
layout: post
title: What's new in Angular 7.1?
author: cexbrayat
tags: ["Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4"]
description: "Angular 7.1 is out! Read about the new router and forms options, Bazel support and more!"
---

Angular&nbsp;7.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#710-2018-11-21">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

Not a lot of new features in this release:
the Angular team is still mainly focused on the Ivy project,
rewriting the Angular compiler and runtime code to make it smaller, better, faster.


## Beginning of Bazel support

A new `@angular/bazel` package appeared in the Angular repository,
containing the stepping stones for building our Angular applications with [Bazel](https://bazel.build/).
It also contains a schematics collection (with a target currently called `bazel-workspace`) to generate the necessary files in an Angular CLI application.

    npm i -g @angular/bazel
    ng generate @angular/bazel:bazel-workspace my-app // adds the Bazel build files to a CLI project

I guess that in a near future, we should be able to directly generate a CLI app with Bazel build
(something like `ng new my-app --collection=@angular/bazel`).

The `bazel-workspace` target already allows to build, serve, test and launch the e2e tests with Protractor. This is still quite experimental.

Note that Bazel is now [published on NPM](https://www.npmjs.com/package/@bazel/bazel) directly,
removing the need to install it manually.

## Router

### CanActivate guard can return a UrlTree

The signature of `CanActivate` changed and it now can return `Observable<boolean|UrlTree>|Promise<boolean|UrlTree>|boolean|UrlTree` instead of `Observable<boolean>|Promise<boolean>|boolean`.
It means that whereas previously you would have returned a boolean (or something that yields a boolean later), you can now return the URL where you want to redirect your user.

So you can write:

    canActivate(next: ActivatedRouteSnapshot, state: RouterStateSnapshot): boolean | UrlTree {
      return this.userService.isLoggedIn() || this.router.parseUrl('/login');
    }

instead of:

    canActivate(next: ActivatedRouteSnapshot, state: RouterStateSnapshot): boolean {
      const loggedIn = this.userService.isLoggedIn();
      if (!loggedIn) {
        this.router.navigateByUrl('/');
      }
      return loggedIn;
    }


The difference is also that now the router will behave correctly if several guards trigger different redirects (it was not the case before, and that could lead to non deterministic behavior in redirections).
Note that you can also use `router.createUrlTree()` to build a `UrlTree` with parameters.

### New option for runGuardAndResolvers

`runGuardsAndResolvers` is one of the configuration options for a route,
allowing to define when the guards and the resolvers will be run for this route.
By default, they run only when the path or matrix parameters change (value `paramsChange`).
You can override this behavior by using another value for this option like `paramsOrQueryParamsChange`,
to also trigger the guards and resolvers if a query parameter changes,
or `always` to trigger them if anything changes.

Angular 7.1 introduces a new possible value: `pathParamsChange`.
Using this value, the guards and resolvers will run if a path parameter changes,
but not if a query or matrix parameter changes.

## Forms

### updateOn in FormBuilder

The `updateOn` option is available since [Angular 5](/2017/11/02/what-is-new-angular-5/),
but it was only usable if you used the constructor of `FormGroup` directly:

    this.userForm = new FormGroup({
      username: '',
      password: ''
    }, {
      validators: Validators.required,
      updateOn: 'blur'
    });

It is now possible to use it via the `group` helper method of the `FormBuilder`.
Note that this updated `group` method can now take an `AbstractControlOptions` as the second parameter,
allowing to have a more coherent API, and use exactly the same syntax as in `FormGroup`:

    this.userForm = fb.group({
      username: '',
      password: ''
    }, {
      validators: Validators.required,
      updateOn: 'blur'
    });

The old form of options is now deprecated
(it was using `validator` and `asyncValidator` instead of `validators` and `asyncValidators`).

## Service Worker

It's now possible to be notified when a user clicks on a push notification,
via the `notificationClicks` observable on the service `SwPush`.

## Ivy update

The Ivy rewrite is still in progress,
but I noted that I missed a nice addition:
there will be public discovery utils that can be used to debug your application in the browser.
Several functions will be available in the browser console:
`getComponent(target)`, `getDirectives(target)`, `getHostComponent(target)`,
`getInjector(target)`, `getRootComponents(target)`, and `getPlayers(target)`.

In Chrome for example, you can inspect an element and that will store the current element in a variable called `$0`. Then in the browser console, you can do `ng.getComponent($0)` and it will return the component associated to the element!
You can check out [Jason Aden talk at AngularConnect](https://www.youtube.com/watch?v=MMPl9wHzmS4) for more info on the topic.

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
