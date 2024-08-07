---
layout: post
title: What's new in Angular 18.2?
author: cexbrayat
tags: ["Angular 18", "Angular"]
description: "Angular 18.2 is out!"
---

Angular&nbsp;18.2.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/18.2.0">
    <img class="rounded img-fluid" style="max-width: 60%" src="/assets/images/angular_gradient.png" alt="Angular logo" />
  </a>
</p>

This is a minor release with some nice features: let's dive in!

## Automatic flush in fakeAsync

In Angular v18.2 (and zone.js v14.11+), the `flush()` function is now automatically called at the end of a `fakeAsync()` test.

Before this version, you had to call `flush()` yourself at the end of your test to flush all pending asynchronous tasks or `discardPeriodicTasks()` for periodic tasks. If you didn't do it, you would get the error `1 periodic timer(s) still in the queue`.

The way to fix it was to call `flush()` or `discardPeriodicTasks()` at the end of your test:

```ts
it('should do something', fakeAsync(() => {
  // ...
  flush();
}));
```

This is no longer necessary, as Angular will do it for you.

```ts
it('should do something', fakeAsync(() => {
  // ...
  // no flush() or discardPeriodicTasks() required!
}));
```

This can be manually disabled by setting the `flush` option of `fakeAsync` to `false`:

```ts
it('should do something', fakeAsync(() => {
  // ...
  flush();
}, { flush: false }));
```

## whenStable helper

A new helper method has been added to `ApplicationRef` to wait for the application to become stable. `whenStable` is really similar to the existing `isStable` method, but it returns a promise that resolves when the application is stable instead of an observable.


## defaultQueryParamsHandling in router

It is now possible to specify the default query params handling strategy for all routes in the `provideRouter()` configuration.

```ts
provideRouter(routes, withRouterConfig({ defaultQueryParamsHandling: 'merge' }));
```

By default, Angular uses the `replace` strategy, but you can also use `preserve` or `merge`.
Previously, you could only specify this strategy on a per-navigation basis (via `RouterLink` or `router.navigate` options).

## Migrations

An optional migration has been added to migrate dependency injection done via the constructor to the `inject` function.

```bash
ng g @angular/core:inject
```

This will update your code from:

```ts
export class UserComponent {
  constructor(private userService: UserService) {}
}
```

to:

```ts
export class UserComponent {
  private userService = inject(UserService);
}
```

Note that you might have some compilation errors after this migration,
most notably if you were using `new UserComponent(userService)` in your tests.
There are a few options for this migration, and one can mitigate this issue:

- `path`, the directory to run the migration. By default: `.`;
- `migrateAbstractClasses`, whether to migrate the abstract classes or not (which may break your code and necessitate to manually fixing it). By default: `false`;
- `backwardsCompatibleConstructors`: by default, constructors that are empty after the migration are deleted. This can lead to compilation errors like the one I'm mentioning above. To prevent that, you can generate backward-compatible constructors with this option 
(which looks like: `constructor(...args: unknown[]);`). By default: `false`;
- `nonNullableOptional`: whether to cast the optional inject sites to be non-nullable or not. By default: `false`.

The migration is _optional_ and the Angular team explicitly said that the constructor injection will still be supported in the future.
However, it does indicate that the future of Angular might be to use the `inject` function.

Another optional migration has been added to convert standalone components used in routes
to be lazy-loaded if that's not the case:

```bash
ng g @angular/core:route-lazy-loading
```

This will update your code from:

```ts
{
  path: 'users',
  component: UsersComponent
}
```

to:

```ts
{
  path: 'users',
  loadComponent: () => import('./users/users.component').then(m => m.UsersComponent)
}
```

The only option for this migration is the `path`.

## Diagnostics

A new diagnostic has been added to catch uncalled functions in event bindings: 

```html
<button (click)="login">Log in</button>
```

throws: `NG8111: Function in event binding should be invoked: login()`.

Another one was added to catch unused `@let` declaration (a new feature introduced in [Angular 18.1](/2024/07/10/what-is-new-angular-18.1)): `NG8112: @let user is declared but its value is never read.`


## Angular CLI

The application builder now supports attribute-based loader configuration

For example, an SVG file can be imported as text via:
```
// @ts-expect-error TypeScript cannot provide types based on attributes yet
import contents from './some-file.svg' with { loader: 'text' };
```

This overrides all other configurations (for example a `loader` defined in `angular.json`).


## Summary

That's all for this release, stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
