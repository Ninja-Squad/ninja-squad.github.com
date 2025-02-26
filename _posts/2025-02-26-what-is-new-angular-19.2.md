---
layout: post
title: What's new in Angular 19.2?
author: cexbrayat
tags: ["Angular 19", "Angular"]
description: "Angular 19.2 is out!"
---

Angular&nbsp;19.2.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/19.2.0">
    <img class="rounded img-fluid" style="max-width: 60%" src="/assets/images/angular_gradient.png" alt="Angular logo" />
  </a>
</p>

This is a minor release with some nice features: let's dive in!

## Angular the documentary

This is not really linked to Angular v19.2, but it's worth mentioning
that the Honeypot channel released a documentary retracing the history of Angular,
with interviews of the Angular team members (old and new):

👉 [Documentary on youtube](https://youtu.be/cRC9DlH45lA?si=pStu61Y3hPOGzh8X)

## TypeScript 5.8 support

Angular v19.2 now supports TypeScript 5.8, which is still in RC but should be out soon.
This means you'll be able to use the latest version of TypeScript in your Angular applications.
You can check out the [TypeScript 5.8 release notes](https://devblogs.microsoft.com/typescript/announcing-typescript-5-8-rc/)
to learn more about the new features.

## resource() and rxResource() changes

Some changes happened in the recently introduced `resource` and `rxResource` APIs.
`resource` was introduced in [Angular 19.0](/2024/11/19/what-is-new-angular-19.0/)
as an experimental API to handle asynchronous resources in Angular applications:

```ts
list(): ResourceRef<Array<UserModel> | undefined> {
  return resource({
    loader: async () => {
      const response = await fetch('/users');
      return (await response.json()) as Array<UserModel>;
    }
  });
}
```

Angular v19.2 adds the possibility to define a `defaultValue` option that will be used as the initial value of the resource
or when the resource is in error (instead of `undefined` by default):

```ts
list(): ResourceRef<Array<UserModel>> {
 return resource({
    // 👇 used when idle, loading, or in error
    defaultValue: [],
    loader: async () => {
 const response = await fetch('/users');
      return (await response.json()) as Array<UserModel>;
 }
 });
}
```

Angular v19.2 also added the possibility to create resources with streamed response data.
A streaming resource is defined with a stream option instead of a loader option.
This stream function returns a promise of a signal (yes, I needed to read it twice as well).
The signal value must be of type `ResourceStreamItem`:
an object with a value or an error property.
When the promise is resolved, the loader can continue to update that signal over time,
and the resource will update its value and error every time the signal’s item changes.

You can build this stream yourself, using a WebSocket for example.
We can also imagine that some libraries such as Firebase
could provide a stream function that would be directly usable:

```ts
list(): ResourceRef<Array<UserModel> | undefined> {
 return resource({
    // firebaseCollection does not exist in real-life
    stream: async ({ abortSignal }) => await firebaseCollection('users', abortSignal)
 });
}
```

This stream feature had been leveraged by the `rxResource` API,
and you can now have a stream of values by returning an observable that emits several times.
The resource will be updated every time a new value is emitted,
whereas only the first value was emitted when introduced in Angular v19.

```ts
readonly sortOrder = signal<'asc' | 'desc'>('asc');
readonly usersResource = rxResource({
  request: () => ({ sort: this.sortOrder() }),
  // 👇 stream that fetches the value now and every 10s
  loader: ({ request }) =>
    timer(0, 10000).pipe(
      switchMap(() => this.httpClient.get<Array<UserModel>>('/users', { params: { sort: request.sort } }))
 )
});
```

## New httpResource() API!

The main feature of this release is the introduction of the `httpResource` API.
This API allows you to easily create resources that fetch data from an HTTP endpoint.

We wrote a dedicated blog post to explain how to use it:

👉 [A guide to HTTP calls with `httpResource()`](/2025/02/20/angular-http-resource/)

The official RFCs for [Resource Architecture](https://github.com/angular/angular/discussions/60120)
and [Resource APIS](https://github.com/angular/angular/discussions/60121)
are also out if you're curious.

## Template strings in templates

The Angular compiler now supports template strings in templates:

{% raw %}

```html
<p>{{ `Hello, ${name()}!` }}</p>
<button [class]="`btn-${theme()}`">Toggle</button>
```

{% endraw %}

Here `name` and `theme` are signals that contain strings.
You can even use pipes in the dynamic part of the template string:

{% raw %}

```html
<p>{{ `Hello, ${name() | uppercase}!` }}</p>
```

{% endraw %}
git
This is a nice addition and I hope we'll see arrow functions in templates soon!

## Migration to self-closing tags

A migration has been added to convert void elements to self-closing tags.
This is just a cosmetic change, and some of you may have already done it via `angular-eslint`
and its `prefer-self-closing-tags` rule.

If that's not the case for you, you can run:

```sh
ng generate @angular/core:self-closing-tag
```

## Forms validators

The `Validators.required`, `Validators.minLength`, and `Validators.maxLength` validators
now work with `Set` in addition to `Array` and `string`:

```ts
const atLeastTwoElementsValidator = Validators.minLength(2);
// minLength error before v19.2
atLeastTwoElementsValidator(new FormControl("a")); // string
atLeastTwoElementsValidator(new FormControl(["a"])); // Array
// 👇 NEW in v19.2! minLength error as well with a Set
atLeastTwoElementsValidator(new FormControl(new Set(["a"]))); // Set
```

## Animation package

The `@angular/animations` package is slowly being retired:
there has been no major update since its author left the Angular team a few years ago,
and it is not actively maintained anymore.
The team has removed dependencies on it in most packages (and in Angular Material as well),
which means that you now safely remove it from your project if you don't use it directly.
To reflect that, the project skeleton generated by the CLI does not include it anymore in v19.2.

## Angular CLI

### AoT support for Karma, Jest, and WTR

It is now possible to run your tests with AOT compilation with Karma, Jest, and Web Test Runner, instead of the default JIT compilation that has been used so far.
This is great as it can catch issues in your test components (missing required inputs, etc).

Sadly, some test features are not available with AOT compilation in tests.
For example, `TestBed.overrideComponent`, `TestBed.overrideTemplate`, etc are not supported
as they rely on JIT compilation.
I really hope that we'll soon have new `TestBed` APIs that work with AOT compilation!

In the meantime, you can give it a try by adding the `aot: true`
option in your `angular.json` configuration file.

### Karma builder

The Karma application builder (introduced in [v19](/2024/11/19/what-is-new-angular-19.0/))
has been moved to the `@angular/build` package.
This means you can now only use this dependency
and get rid of the `@angular-devkit/build-angular` one.

### SSR

`provideServerRoutesConfig` has been deprecated and renamed `provideServerRouting`,
and its `appShellRoute` option has been replaced with a `withAppShell` option,
to make the API similar to the other in Angular.

Before:

```ts
provideServerRoutesConfig(serverRoutes, { appShellRoute: "" });
```

After:

```ts
provideServerRouting(serverRoutes, withAppShell(AppComponent));
```

A note-worthy new feature: routes defined with a `matcher` are now supported by Angular SSR,
allowing us to define their render mode.
Note that it can only be `Server` or `Client` for these routes but not `Prerender`.

## Summary

That's all for this release.
The next one should be v20, and we hope to see some news on the "forms with signals" 🤞
Stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
