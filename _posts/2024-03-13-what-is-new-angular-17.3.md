---
layout: post
title: What's new in Angular 17.3?
author: cexbrayat
tags: ["Angular 17", "Angular"]
description: "Angular 17.3 is out!"
---

Angular&nbsp;17.3.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/17.3.0">
    <img class="rounded img-fluid" style="max-width: 60%" src="/assets/images/angular_gradient.png" alt="Angular logo" />
  </a>
</p>

This is a minor release with some nice features: let's dive in!

## TypeScript 5.4 support

Angular v17.3 now supports TypeScript 5.4. This means that you can use the latest version of TypeScript in your Angular applications. You can check out the [TypeScript 5.4 release notes](https://devblogs.microsoft.com/typescript/announcing-typescript-5-4/) to learn more about the new features.

## New template compiler

Angular now uses a new template compiler! The work on this compiler started more than a year ago and has been done in parallel with the other features we saw in the previous releases to eventually pass all of the existing tests. It's now the case, and this new compiler is now the default in Angular 17.3.

This compiler is based on an intermediate representation of template operations,
a common concept in compilers, for example in LLVM.
This _IR_ semantically encodes what needs to happen at runtime to render and change-detect the template.
Using an _IR_ allows for different concerns of template compilation to be processed independently,
which was not the case with the previous implementation.
This new compiler is easier to maintain and extend,
so it is a great foundation for future improvements in the framework.

Note that the compiler emits the same code as the previous one,
so you should not see any difference in the generated code.

## output functions

A new (developer preview) feature was added to allow the declaration
of outputs similarly to the `input()` function.

As for inputs, you can use the `output()` function to define an output:

```ts
ponySelected = output<PonyModel>();
// ^? OutputEmitterRef<PonyModel>
```

The `output()` function returns an `OutputEmitterRef<T>`
that can be used to emit values.
`OutputEmitterRef` is an Angular class,
really similar to a simplified `EventEmitter`
but that does not rely on `RxJS`
(to limit the coupling of Angular with RxJS).

The function accepts a parameter to specify options,
the only one available for now is `alias` to alias the output.

As with `EventEmitter`, you can use the `emit()` method to emit a value:

```ts
ponySelected = output<PonyModel>();
// ^? OutputEmitterRef<PonyModel>
select() {
  this.ponySelected.emit(this.ponyModel());
}
```

You can also declare an output without a generic type,
and the `OutputEmitterRef` will be of type `OutputEmitterRef<void>`.
You can then call `emit()` without a parameter on such an output.

`OutputEmitterRef` also exposes a subscribe method
to manually subscribe to the output.
This is not something you’ll do often, but it can be handy in some cases.
If you manually subscribe to an output,
you’ll have to manually unsubscribe as well.
To do so, the subscribe method returns an `OutputRefSubscription` object with an `unsubscribe` method.

Two new functions have been added to the `rxjs-interop` package to convert an output to an observable,
and an observable to an output.

Angular always had the capability of using observables other than `EventEmitter` for outputs.
This is not something that is largely used, but it’s possible.
The new `outputFromObservable` function allows you to convert an observable to an output:

```ts
ponyRunning$ = new BehaviorSubject(false);
ponyRunning = outputFromObservable(this.ponyRunning$);
// ^? OutputRef<boolean>
```

The `outputFromObservable` function returns an `OutputRef<T>`, and not an `OutputEmitterRef<T>`,
as you can’t emit values on an output created from an observable.
The output emits every event that is emitted by the observable.


```ts
startRunning() {
  this.ponyRunning$.next(true);
}
```

It is also possible to convert an output to an observable using the `outputToObservable` function if needed.
You can then use `.pipe()` and all the RxJS operators on the converted output.

These interoperability functions will probably be rarely used.
`output()`, on the other hand, will become the recommended way to declare outputs in Angular components.

## HostAttributeToken

Angular has always allowed to inject the value of an attribute of the host element.
For example, to get the type of an input, you can use:

```ts
@Directive({ 
  selector: 'input',
  standalone: true
})
class InputAttrDirective {
  constructor(@Attribute('type') private type: string) {
    // type would be 'text' if `<input type="text" />
  }
}
```

Since Angular v14, injection can be done via the `inject()` function as well,
but there was no option to get an attribute value with it.

This is now possible by using a special class `HostAttributeToken`:

```ts
type = inject(new HostAttributeToken('type'));
```

Note that `inject` throws if the attribute is not found (unless you pass a second argument `{ optional: true }`).

## RouterTestingModule deprecation

The `RouterTestingModule` is now deprecated.
It is now recommended to `provideRouter()` in the `TestBed` configuration instead.

## New router types

The router now has new types to model the result of guards and resolvers.

For example, the CanActivate guard was declared like this:

```ts
export type CanActivateFn = (route: ActivatedRouteSnapshot, state: RouterStateSnapshot) => Observable<boolean | UrlTree> | Promise<boolean | UrlTree> | boolean | UrlTree;
```

This is because the guard can return a boolean to allow or forbid the navigation, or an `UrlTree` to trigger a redirection to another route. This result can be synchronous or asynchronous.

The signature has been updated to:

```ts
export type CanActivateFn = (route: ActivatedRouteSnapshot, state: RouterStateSnapshot) => MaybeAsync<GuardResult>;
```

`GuardResult` is a new type equal to `boolean | UrlTree`,
and `MaybeAsync<T>` is a new generic type equal to `T | Observable<T> | Promise<T>`.

A resolver function now also returns a `MaybeAsync<T>`.
You can keep using the older signatures but the new ones are more concise.

## Angular CLI

Angular CLI v17.3 doesn't bring a lot of new features,
but we can note that `deployUrl` is now supported in the application builder.
It was initially marked as deprecated but was re-introduced after community feedback.

## Summary

That's all for this release.
The next stop is v18, where we should see some developer preview features becoming stable.
Stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
