---
layout: post
title: What's new in Angular 15.2?
author: cexbrayat
tags: ["Angular 15.2", "Angular"]
description: "Angular 15.2 is out!"
---

Angular&nbsp;15.2.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/15.2.0">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This is a minor release with some interesting features and some big news: let's dive in!

## Easily migrate to standalone components!

The Angular team is releasing a set of schematics to automatically migrate your application
to standalone components. It does an amazing job at analyzing your code,
migrating your components/pipes/directives to their standalone versions,
and removing the obsolete modules of your application 😍.

Sounds interesting? We wrote a guide about it:

👉 [Migrate to standalone components with Angular schematics](/2023/02/21/migrate-an-angular-application-to-standalone/)

## Angular Signals

The Angular team has been working on a different way to handle reactivity in your application for the past year.
The first step of the result has been publicly released (even if there is nothing to use yet):
the [discussion about Angular Signals](https://github.com/angular/angular/discussions/49090).

Signals are a concept that is used in many other frameworks, like SolidJS, Vue, Preact and even the venerable KnockoutJS.
The idea is to offer a few primitives to define reactive state in your application
and to allow the framework to know which components are impacted by a change, rather than having to detect changes on the whole tree of components.

This would be a significative change to how Angular works, as it currently relies on zone.js to detect changes in the whole tree of components by default.
Instead, with signals, the framework would only re-render the components that are impacted by a change.

This also opens the door to zoneless applications, i.e. applications where Angular applications don't need to include Zone.js (which makes them lighter), and don't have to patch all the browser APIs (which makes them start faster).

The first draft of the API is available and looks like this:

    // define a signal
    const count = signal(0);
    // get the value of the signal
    const value = count();
    // set the value of the signal
    count.set(1);
    // update the value of the signal, based on current value
    count.update((value) => value + 1);
    // mutate the value of the signal (handy for objects/arrays)
    const user = signal({ name: 'JB', favoriteFramework: 'Angular' });
    user.mutate((user) => user.name = 'Cédric');

Once you have defined signals, you can define computed values that derive from them:

    const double = computed(() => count() * 2);

Computed values are automatically computed when one of the signals they depend on changes.

    count.set(2);
    console.log(double()); // logs 4

Note that they are lazily computed and only re-computed
when one of the signals they depend on produces a new value.

Finally, you can use the `effect` function to react to changes in your signals:

    // log the value of the count signal when it changes
    effect(() => console.log(count()));

This does look like like a `BehaviorSubject`, but it has some subtle differences, the most important one being that unsubscribing is unnecessary thanks to the usage of 
[weak references](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakRef).

That's pretty much it for now!
The next step is to integrate this API with the framework,
and make it interoperate with RxJS.

In an ideal future,
we may be able to build a component with fields that are signals and computed values used in the template.
The framework would be notified when an expression has changed thanks to the signals, and would thus only need to re-render the components affected by the change, without having to check for changes on unrelated components, without the need for zone.js.
But there is a long way ahead, as several things needs to be rethought in the framework to make this work
(what about inputs, outputs, queries, lifecycle methods, etc?).

This is anyway an exciting project, and it's quite interesting how frameworks inspire each others,
with Angular taking inspiration from Vue and SolidJS for the reactivity part,
whereas other frameworks are increasingly adopting the template compilation approach of Angular,
with no Virtual DOM needed at runtime.

## Deprecation of class-based guards and resolvers

The class-based guards and resolvers are now officially deprecated on a route definition.
As you may know, it is possible to write them as functions since Angular&nbsp;v14.2 
(check out our [blog post about that](/2022/08/26/what-is-new-angular-14.2/)).

You can migrate your guards and resolvers to functions fairly easily
or you can simply wrap the class with `inject()` as a quick way to get rid of the deprecation warning:

    { path: 'users', component: UsersComponent, canActivate: () => inject(LoggedInGuard).canActivate() }

Note that the `CanActivate`, `CanDeactivate`, etc interfaces will be deleted in a future version of Angular.

## RouterTestingHarness

The `RouterTestingModule` now provides a `RouterTestingHarness`
that can be used to write tests.
It can be handy to test components that expect an `ActivatedRoute` for example,
or when you want to trigger navigations in your tests to test guards or resolvers.

`RouterTestingHarness` has a static method `create` that can be called with an optional initial navigation.
This method returns a promise of the created harness, that can then be used to trigger navigations,
using `navigateByUrl`.

    // load the routes in the TestBed
    TestBed.configureTestingModule({
      imports: [RouterTestingModule.withRoutes(routes)],
    });
    // create the harness
    const harness = await RouterTestingHarness.create();
    // explicitly cast the component returned with `<UserComponent>`
    const component = await harness.navigateByUrl<UserComponent>('/users/1');
    // or pass the type as the second argument
    // in that case, the test fails if the component is not of the expected type when navigating to /users/1
    const component = await harness.navigateByUrl('/users/1', UserComponent);
    
The harness provides a `routeDebugElement` property that returns the `DebugElement` of the component
you navigated to, and a `routeNativeElement` property that returns the native element of the component.
If you want to get the component instance, you can either get it as the return value of `navigateByUrl`,
or by accessing `harness.routeDebugElement.componentInstance`.

The harness does not have a property to access the `ComponentFixture` as we usually have in tests,
but directly provides a `detectChanges` method that will trigger change detection on the component.

    const harness = await RouterTestingHarness.create();
    const component = await harness.navigateByUrl('/users/1', UserComponent);
    component.name = 'Cédric';
    harness.detectChanges();
    expect(harness.routeNativeElement!.querySelector('#name')!.textContent).toBe('Cédric');
    

## withNavigationErrorHandler

A new feature called `withNavigationErrorHandler` has been added to the router.
It can be used in `provideRouter` to provide a custom error handler for navigation errors.

    provideRouter(routes, withNavigationErrorHandler((error: NavigationError) => {
      // do something with the error
    }))

This is roughly equivalent to the (now deprecated) `errorHandler` you could configure on the `RouterModule`.

## NgOptimizedImage

`NgOptimizedImage` has a new `loaderParams` input that accepts an object.

{% raw %}
    <!-- params = { isBlackAndWhite: true } for example -->
    <img [ngSrc]="source" [loaderParams]="params"></img>
{% endraw %}

This object will be passed to your custom loader when it is called,
as a property `loaderParams` in the `ImageLoaderConfig`.

    const customLoader = (config: ImageLoaderConfig) => {
        const { loaderParams } = config;
        // do something with loaderParams        
    };

## Performances

The `NgClass` directive has been rewritten to improve performances.
Its algorithm is now a bit smarter and triggers less change detections and DOM updates.
You don't have to change anything, you'll get that for free when upgrading 😍.

## Angular CLI

The CLI had few changes in this release, so no dedicated article this time.

The esbuild builder now supports Less stylesheets, CommonJS dependency checks and node modules license extraction. Maybe more importantly, it now uses the new incremental rebuild of esbuild,
introduced in [esbuild v0.17](https://github.com/evanw/esbuild/releases/tag/v0.17.0).
Watch mode should now be even faster.

Another tiny new feature: `ng update` now logs the number of files modified by the migrations.

## Summary

That's all for this release, stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
