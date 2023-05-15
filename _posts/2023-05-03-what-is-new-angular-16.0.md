---
layout: post
title: What's new in Angular 16?
author: cexbrayat
tags: ["Angular 16", "Angular"]
description: "Angular 16 is out!"
---

Angular&nbsp;16.0.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/15.2.0">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This is a major release packed with features: let's dive in!

## Angular Signals

As you may have heard, all the hype around Angular is about the addition of Signals to the framework. As this is a big change that will shape how we build Angular applications in the future, we wrote an introduction to Signals, to cover what you can do with them in v16 and what to expect in the future:

👉 [Angular Signals](/2023/04/26/angular-signals/)

Note that Signals are released as a developer preview in v16 and the API may change in the future.

As Signals are progressing, Angular now allows configuring ZoneJS explicitly with `provideZoneChangeDetection`:

    bootstrapApplication(AppComponent, {
      providers: [provideZoneChangeDetection({eventCoalescing: true})],
    });

This opens the door to zoneless applications in the near future,
where developers could choose to not include ZoneJS in their application.

## Required inputs

Angular v16 added the possibility to mark an input as required,
with `@Input({ required: true})`:

    @Input({ required: true }) user!: UserModel;

In that case, if the parent component does not pass the input, 
then the compiler will throw an error.

This has been a long-awaited feature, we're happy to see this land in Angular!


## Server-Side Rendering and progressive hydration

Angular has been supporting Server-Side Rendering (SSR) for a while now,
but it was a bit limited as it was only possible to render the whole application on the server, and then re-render it on the client when the JavaScript bundle was loaded.
This was resulting in a flickering when the application loaded,
as the DOM was completely wiped out before being re-rendered.

Angular v16 introduces "progressive hydration",
which allows rendering the application on the server,
and then progressively hydrate it on the client.

This means that the server-rendered DOM is not wiped out anymore,
and the client-side rendering is done progressively,
which results in a much smoother experience for the user.

To enable these new behaviors, you simply add `provideClientHydration()` to your providers:

    bootstrapApplication(AppComponent, {
      providers: [provideClientHydration()]
    });

The HttpClient has also been updated to be able
to store the result of a request done on the server,
and then reuse it on the client during the hydration process!
The behavior is enabled by default if you use `provideClientHydration()`,
but can be disabled with `provideClientHydration(withNoHttpTransferCache())`.
You can also disable the DOM reuse with `withNoDomReuse()`.

Note that this is a developer preview, and the API may change in the future.
There are also a few pitfalls to be aware of.
For example, the HTML must be valid when generated on the server (whereas the browser is more forgiving).
The DOM must also be the same on the server and the client,
so you can't manipulate the server-rendered DOM before sending it to the client.
If some parts of your templates don't produce the same result on the server and the client, you can skip them by adding `ngSkipHydration` to the element or component.
i18n is also not supported yet, but that should come soon.

When running in development mode, the application will output some stats to the console to help you debug the hydration process:

    Angular hydrated 19 component(s) and 68 node(s), 1 component(s) were skipped

You can easily give this a try by using Angular Universal.
In the long term, this will probably be part of the CLI directly.

## DestroyRef

Angular v16 introduces a new `DestroyRef` class,
which has only one method called `onDestroy`.

`DestroyRef` can be injected,
and then used to register code that should run
on the destruction of the surrounding context.

    const destroyRef = inject(DestroyRef);
    // register a destroy callback
    destroyRef.onDestroy(() => doSomethingOnDestroy());

For example, it can be used to execute code on the destruction
of a component or directive (as we do now with `ngOnDestroy`).
But this is more useful for cases where you want to execute code
when a component is destroyed, but you don't have access to the component itself,
for example when defining a utility function.

This is exactly what Angular uses internally to implement `takeUntilDestroyed`,
the new RXJS operator introduced in our [Signals blog post](/2023/04/26/angular-signals/).

## provideServiceWorker

One of the last modules that needed to be transitioned to a standalone provider function was `ServiceWorkerModule`. It is now done with `provideServiceWorker`:

    bootstrapApplication(AppComponent, {
      providers: [provideServiceWorker()]
    });

It, of course, accepts the same options as the `ServiceWorkerModule`.
Running `ng add @angular/pwa` will now add `provideServiceWorker` to your providers
if your application is a standalone one.

## TypeScript 5.0 support

Angular v16 now supports TypeScript 5.0. This means that you can use the latest version of TypeScript in your Angular applications. You can check out the [TypeScript 5.0 release notes](https://devblogs.microsoft.com/typescript/announcing-typescript-5-0/) to learn more about the new features.

One important point is that TypeScript now supports the "official" decorator specification.
Their "experimental decorators" (based on a much older specification) are still supported but are now considered legacy. One of the differences between these two specifications is that the legacy one supports decorators on parameters, which is used by Angular for dependency injection (with `@Optional`, `@Inject`, etc.), and the new one doesn't.

It is now possible to use the new decorator specification in Angular, but it requires a few changes in your code, as you can't use decorators on parameters anymore.
This can usually be worked around by using the `inject()` function from `@angular/core`.
There is no rush to use the new decorators instead of the "legacy" ones, but it's something to keep in mind as I wouldn't be surprised if we have to migrate away from `experimentalDecorators` in the future

## Styles removal opt-in

Angular v16 introduces a new opt-in feature to remove the styles of a component
when its last instance is destroyed.

This will be the default behavior in the future, but you can already opt in with:

    { provide: REMOVE_STYLES_ON_COMPONENT_DESTROY, useValue: true }

## Router 

Angular v15.2 deprecated the usage of class-based guards and resolvers
(check out our [blog post for more details](/2023/02/23/what-is-new-angular-15.2/)).
In Angular v16, a migration will run to remove the guard and resolver interfaces from your code (`CanActivate`, `Resolve`, etc.).

To help with the conversion, the router now offers helper functions to convert class-based entities to their function-based equivalent:

- `mapToCanActivate`
- `mapToCanActivateChild`
- `mapToCanDeactivate`
- `mapToCanMatch`
- `mapToResolve`

For example, you can now write:

    { path: 'admin', canActivate: mapToCanActivate([AdminGuard]) };

`RouterTestingModule` is also getting phased out, and will probably be deprecated and removed in the future. It is not needed anymore, because Angular v16 now provides `MockPlatformLocation` in `BrowserTestingModule` by default, which was the main reason to use `RouterTestingModule` in the first place.

You can now directly use `RouterModule.forRoot([])` or `providerRouter([])` in your tests.

Last but not least, the router now offers the possibility to bind parameters as inputs.

To do so, you need to configure the router with `withComponentInputBinding`:

    provideRouter(routes, withComponentInputBinding())

With this option, a component can declare an input with the same name as a route parameter,
query parameter or data, and Angular will automatically bind the value of the parameter or data to this input.

    export class RaceComponent implements OnChanges {
      @Input({ required: true }) raceId!: string;

We can then use this input as a regular input, and react to its change with ngOnChanges or by using a setter for this input:

    constructor(private raceService: RaceService) {}

    ngOnChanges() {
      this.raceModel$ = this.raceService.get(this.raceId);
    }

## Angular CLI

Check out our [dedicated blog post about the CLI](/2023/05/03/angular-cli-16.0/) for more details.

## Summary

That's all for this release, stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
