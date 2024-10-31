---
layout: post
title: What's new in Angular 18.0?
author: cexbrayat
tags: ["Angular 18", "Angular"]
description: "Angular 18.0 is out!"
---

Angular&nbsp;18.0.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/18.0.0">
    <img class="rounded img-fluid" style="max-width: 60%" src="/assets/images/angular_gradient.png" alt="Angular logo" />
  </a>
</p>

This is a major release with some nice features: let's dive in!

## Control flow syntax is now stable!

The control flow syntax introduced in Angular 17 is no longer a developer preview feature and can safely be used.
As it is now the recommended way to write templates, you should consider using it in your applications.
You can easily migrate your applications using the provided schematics.

👉 To learn more, check out our dedicated [blog post](/2023/10/11/angular-control-flow-syntax).

Since we wrote this blog post, two warnings have been added to catch potential issues in your templates with for loops.

As you know the `track` option is now mandatory in `@for` loops.
A new warning has been added in development mode to warn you if you have duplicated keys used by the `track` option:

```bash
WARN: 'NG0955: The provided track expression resulted in duplicated keys for a given collection.
Adjust the tracking expression such that it uniquely identifies all the items in the collection.
Duplicated keys were:
key "duplicated-key" at index "0" and "1".'
```

This is a warning that you can see in the browser console or when running unit tests.
It typically happens if you pick a property that is not unique in your collection.

Another warning has been added to catch potential issues with the tracking expression.
If the tracking expression leads to the destruction and recreation of the complete collection, a warning will be displayed:

```bash
WARN: 'NG0956: The configured tracking expression (track by identity)
caused re-creation of the entire collection of size 20.
This is an expensive operation requiring destruction and subsequent creation of DOM nodes, directives, components etc.
Please review the "track expression" and make sure that it uniquely identifies items in a collection.'
```

This typically happens if you use the `track item` option and if you recreate all the collection items when there is a change.
Note that the warning only applies if the repeated element is considered "expensive" to create, but the bar is currently set quite low (a text node with a binding is already considered expensive).

## Defer syntax is stable

The `@defer` syntax is also stable.
`@defer` lets you define a block of template that will be loaded lazily when a condition is met
(with all the components, pipes, directives, and libraries used in this block lazily loaded as well).

👉 We wrote a detailed [blog post about this feature](/2023/11/02/angular-defer) if you want to learn more about it.


## Signal standardization proposal

This is not an Angular v18 news, but as you may have heard, some of the most popular framework authors
(included the Angular and Vue team for example) have been working on a proposal to standardize signals in the JavaScript language.

The proposal is at the first stage, so it might take a long time,
probably at least several years, or even never happened.

You can deep dive into [the proposal](https://github.com/tc39/proposal-signals) or into this interesting [blog post](https://eisenbergeffect.medium.com/a-tc39-proposal-for-signals-f0bedd37a335) to learn more about it.

TL;DR: `new Signal.State()` would be the equivalent of `signal()` in Angular.
`new Signal.Computed()` would be the equivalent of `computed()`.
There are no equivalents for `effect`:
as all frameworks have slightly different needs, this is left out of the scope of the proposal, and frameworks can implement it as they see fit based on `new Signal.subtle.Watcher()`.

Fun fact: the current Signal [polyfill](https://github.com/proposal-signals/signal-polyfill) in the proposal is based on the Angular implementation!


## Zoneless change detection

Angular v18 introduces a new way to trigger change detection.
Instead of relying on ZoneJS to know when something has possibly changed,
the framework can now schedule a change detection by itself.

To do so, a new scheduler has been added to the framework (called `ChangeDetectionScheduler`),
and this scheduler is internally used to trigger change detection.
This new scheduler is enabled by default in v18, even if you use ZoneJS.
However, the goal is to progressively move away from ZoneJS and rely only on this new scheduler.

With this new scheduler, the framework no longer only relies on ZoneJS to trigger change detection.
Indeed, the new scheduler triggers a change detection when a host or template listener is triggered,
when a view is attached or removed, when an `async` pipe detects a new emission,
when the `markForCheck()` method is called, when you set a signal value, etc.
It does so by calling `ApplicationRef.tick()` internally.

### Opting out of the new scheduler

The new scheduler is enabled by default in v18.
This means that Angular gets notified of potential changes by ZoneJS (as it used to)
and by the new scheduler (when a signal is set, an `async` pipe receives a new value, etc.).
The framework then runs the change detection.
This should not impact your application,
as Angular will only run the change detection once even if notified by several sources.
But if you want to opt out of the new scheduler,
you can use the `provideZoneChangeDetection()` function with `ignoreChangesOutsideZone` set to `true`:

```ts
bootstrapApplication(AppComponent, {
  providers: [
    // this restores the behavior of Angular before v18
    // and ignores the new scheduler notifications
    provideZoneChangeDetection({ ignoreChangesOutsideZone: true })
  ]
});
```

### Experimental zoneless change detection

But you can also try to _only_ rely on this new scheduler, and no longer on ZoneJS, to trigger change detection.
This is an experimental feature, and you can enable it by using the provider function `provideExperimentalZonelessChangeDetection()` in your application.

```ts
bootstrapApplication(AppComponent, {
  providers: [
    // 👇
    provideExperimentalZonelessChangeDetection()
  ]
});
```

When doing so, the framework will no longer rely on ZoneJS to trigger change detection.
So you can remove ZoneJS from your application if you want to 
(and if you have no dependencies that rely on it, of course).
In that case, you can remove `zone.js` from the `polyfills` in your `angular.json` file.

It should work out of the box if all your components are `OnPush` and/or rely on signals! 🚀

I tried it on a small application fully written with signals and it worked like a charm.
Of course, this is not something we will be able to do in all applications,
but it's a nice step forward towards a zoneless Angular.
In particular, if you use a component library that isn't ready for zoneless support, you'll have to wait until it is.
If you want to prepare your application for this new feature,
you can start by progressively moving your components to `OnPush`.

### Testing

Note that the `provideExperimentalZonelessChangeDetection` function can also be used in tests,
so you can test your application without ZoneJS,
and make sure your components are correctly working with this new feature.

You can currently add the provider in each test, or globally to all your tests by adding it in the `TestBed` configuration,
in the `test.ts` file of your application (this file is no longer generated in new projects, but you can add it back manually):

```ts
@NgModule({
  providers: [provideExperimentalZonelessChangeDetection()]
})
export class ZonelessTestModule {}

getTestBed().initTestEnvironment(
  [BrowserDynamicTestingModule, ZonelessTestModule],
  platformBrowserDynamicTesting()
);
```

Then, instead of relying on `fixture.detectChanges()`
that triggers the change detection, 
you can simply use `await fixture.whenStable()` and let Angular trigger the change detection
(as it would when running the application).
This is because the `ComponentFixture` used by the framework in zoneless mode
uses the "auto detect changes" strategy by default.

So, similarly to using `OnPush` in your components to prepare for the zoneless future,
a good way to prepare your tests is to progressively replace `detectChanges()` with `await fixture.whenStable()`
and enable "auto-detect changes" in your tests.

This is something that has been existing for quite some time in Angular.
If you want to use it in your current tests, even without using `provideExperimentalZonelessChangeDetection`,
you can either call `fixture.autoDetectChanges()` at the beginning of your test,
or add the following provider to your test configuration:

```ts
providers: [
  { provide: ComponentFixtureAutoDetect, useValue: true }
]
```

We're probably going to update our ebook and the tests we provide in our online training to use this strategy.

Note that some testing features that use ZoneJS are not supported with 
`provideExperimentalZonelessChangeDetection()`, like `fakeAsync` and `tick()`.
If you need to fake time in your tests, you can use the `jasmine.clock` APIs instead.

### Debugging existing applications

If you want to check if your current application is ready for zoneless change detection,
you can use `provideExperimentalCheckNoChangesForDebug()`:

```ts
bootstrapApplication(AppComponent, {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }), // or provideExperimentalZonelessChangeDetection()
    provideExperimentalCheckNoChangesForDebug({
      interval: 1000, // run change detection every second
      useNgZoneOnStable: true, // run it when the NgZone is stable as well
      exhaustive: true // check all components
    })
  ]
});
```

This will run a change detection every second and check if any component has been changed without triggering a change detection.
If such a change is detected, a `NG0100: ExpressionChangedAfterItHasBeenCheckedError` error will be thrown in the console.
This should allow you to track down the components that need to be updated to work with zoneless change detection.

### Zone.js status

ZoneJS is still a dependency of Angular and will be for a while.
It is now officially in maintenance mode, and will not ship new features,
but will still be maintained for bug fixes and security issues.


## Fallback for ng-content

`<ng-content>` is a powerful feature in Angular, but it has a cumbersome limitation: it can't have fallback content.
This is no longer the case in Angular&nbsp;v18!

We can now add some content inside the `<ng-content>` tag, and this content will be displayed if no content is projected in the component.

For example, let's consider a `CardComponent` with a title and a content
that can be projected:

```html
<div class="card">
  <div class="card-body">
    <h4 class="card-title">
      <!-- 👇 If the title is not provided, we display a default title -->
      <ng-content select=".title">Default title</ng-content>
    </h4>
    <p class="card-text">
      <ng-content select=".content"></ng-content>
    </p>
  </div>
</div>
```

Now, if we use this component without providing a title, the default title will be displayed!


## Forms events

The `AbstractControl` class (the base class for form controls, groups, arrays, and records) now has a new property called `events`.

This field is an observable that emits events when the control's value, status, pristine state, or touched state changes.
It also emits when the form is reset or submitted.

For example, let's consider a form group for a user with a login and a password:

```ts
fb = inject(NonNullableFormBuilder);
userForm = this.fb.group({
  login: ['', Validators.required],
  password: ['', Validators.required]
});

  constructor() {
    this.userForm.events.subscribe(event => {
      if (event instanceof TouchedChangeEvent) {
        console.log('Touched: ', event.touched);
      } else if (event instanceof PristineChangeEvent) {
        console.log('Pristine: ', event.pristine);
      } else if (event instanceof StatusChangeEvent) {
        console.log('Status: ', event.status);
      } else if (event instanceof ValueChangeEvent) {
        console.log('Value: ', event.value);
      } else if (event instanceof FormResetEvent) {
        console.log('Form reset');
      } else if (event instanceof FormSubmitEvent) {
        console.log('Form submit');
      }
    });
  }
```

As you can see, several types of events can be emitted:
`TouchedChangeEvent`, `PristineChangeEvent`, `StatusChangeEvent`, `ValueChangeEvent`, `FormResetEvent` and `FormSubmitEvent`.

If I enter a first character in the login field, the console will display:

```
Pristine: false
Value: Object { login: "c", password: "" }
Status: INVALID
Touched: true
```

All events also have a `source` property that contains the control that emitted the event
(here the login control). The `source` contains the form itself for form reset and submission events.


## Router and redirects

The `redirectTo` property of a route now accepts a function instead of just a string.
Previously, we were only able to redirect our users to a static route
or a route with the same parameters.
The `RedirectFunction` introduced in v18 allows us to access part of the `ActivatedRouteSnapshot` to build the redirect URL.
I say "part of" because the activated route is not fully resolved when the function is called. For example, the resolvers haven't run yet, the child routes aren't matched, etc.
But we do have access to the parent route params or the query params for example,
which was not previously possible.
This function is also similar to guards, and is run in the environment injector:
this means you can inject services if needed.
The function can return a string or a `UrlTree`.


```ts
provideRouter([
  // ...
  {
    path: 'legacy-users',
    redirectTo: (redirectData) => {
      const userService = inject(UserService);
      const router = inject(Router);
      // You also have access to 'routeConfig', 'url', 'params', 'fragment',  'data',  'outlet', and 'title'
      const queryParams = redirectData.queryParams;
      // if the user is logged in, keep the query params
      if (userService.isLoggedIn()) {
        const urlTree = router.parseUrl('/users');
        urlTree.queryParams = queryParams;
        return urlTree;
      }
      return '/users';
    }
  }
])
```

A similar improvement has been made in guards.
The `GuardResult` type returned by a guard has been augmented from `boolean | UrlTree` to `boolean | UrlTree | RedirectCommand`.
A guard could already return an `UrlTree` to redirect the user to another route,
but now it can also return a `RedirectCommand` to redirect the user to another route with a specific navigation behavior, as a `RedirectCommand` is an object
with two properties: `redirectTo` (the `UrlTree` to navigate to) and `navigationBehaviorOptions` (the [navigation behavior](https://angular.io/api/router/NavigationBehaviorOptions) to use):

```ts
provideRouter([
  // ...
  {
    path: 'users',
    component: UsersComponent,
    canActivate: [
      () => {
        const userService = inject(UserService);
        return userService.isLoggedIn() || new RedirectCommand(router.parseUrl('/login'), {
          state: { requestedUrl: 'users' } 
        });
      }
    ],
  }
])
```

Resolvers can now also return a `RedirectCommand`.
The first resolver to do so will trigger a redirect and cancel the current navigation.

`withNavigationErrorHandler()` has also been updated to be able to return a `RedirectCommand`.


## HttpClientModule deprecation

Now that the ecosystem is moving towards standalone components,
we're starting to see the deprecation of the first Angular modules.
Starting with v18, `HttpClientModule` (and `HttpClientTestingModule`, `HttpClientXsrfModule`, and `HttpClientJsonpModule`) are deprecated.

As you probably know, you can now use `provideHttpClient()` (with options for XSRF or JSONP support) and `provideHttpClientTesting()` as a replacement.

But, as usual, the Angular team provides a schematic to help you migrate your application. When running `ng update @angular/core`, you'll be prompted to migrate your HTTP modules if you still have some in your application.


## Internationalization

The utility functions offered by `@angular/common` to work with locale data have been deprecated in favor of the `Intl` API.
It is no longer recommended to use `getLocaleCurrencyCode()`, `getLocaleDateFormat()`,
`getLocaleFirstDayOfWeek()`, etc.
Instead, you should use the `Intl` API directly,
for example [Intl.DateTimeFormat](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/DateTimeFormat) to work with locale dates.

## Server-Side Rendering

We have two new features in Angular v18 that are related to Server-Side Rendering (SSR).

### SSR and replay events

It is now possible to record user interactions during the hydration phase,
and replay them when the application is fully loaded.
As you may know, the hydration phase is the phase where the server-rendered HTML
is transformed into a fully functional Angular application,
where listeners are added to the existing elements.

But during this phase, the user can interact with the application,
and these interactions are lost (if the hydration process is not fast enough).

So for some applications, it can be interesting to record these interactions
and replay them when the application is fully loaded.

This used to be done via a project called _preboot_ in Angular,
but this project was no longer maintained.
Instead of reviving preboot, the Angular team decided to implement this feature directly in the framework.
But they did not start from scratch:
in fact, they used something that already existed inside Google, in the Wiz framework.
Wiz is not open-source, but it is widely used by Google for their applications (Google Search, Google Photos, etc.).
You can read about the ambitions of the Wiz and Angular teams to "merge" the two frameworks in this [blog post on angular.io](https://medium.com/angular-blog/angular-and-wiz-are-better-together-91e633d8cd5a).
Wiz started to use the signals API from Angular (that's why Youtube is now using Signals),
and now Angular is using the replay events feature from Wiz.
That's why these two features are in a `packages/core/primitives` directory in the Angular codebase:
they are part of Angular but are shared by the two frameworks.

To enable this feature, you can use the `withEventReplay()` (developer preview) function in your server-side rendering configuration:

```ts
providers: [
  provideClientHydration(withEventReplay())
]
```

When doing so, Angular will add a JS script at the top of your HTML page,
whose job is to replay events that happened during the hydration phase.
To do so, it adds a listener at the root of the document,
and listens to a set of events that can happen on the page
using [event delegation](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Building_blocks/Events#event_delegation).
It does know which events it needs to listen to,
as Angular collected them when rendering the page on the server.
So for example, if you render a page that contains elements which have a `(click)` or a `(dblclick)` handler,
Angular will add listeners for these events:

```html
<script>window.__jsaction_bootstrap('ngContracts', document.body, "ng", ["click","dblclick"]);</script>
```

When the application is loaded and stable,
the script then replays the events that happened during the hydration phase,
thus triggering the same actions as the user did.
Quite a nice feature, even if it is probably useful only for some applications.

### SSR and Internationalization

The Angular SSR support is improving with each version.
One year ago, Angular v16 introduced progressive hydration,
as we explained in this [blog post](/2023/05/03/what-is-new-angular-16.0).
There was one missing feature at the time:
the internationalization support.
Angular would skip the elements marked with `i18n` during SSR.
This is now solved in v18! 
If your application uses the builtin i18n support of the framework,
you can now use SSR.
The support is in developer preview, and can be enabled with `withI18nSupport()`.


## Angular CLI

The CLI has also been released in version v18, with some notable features.

### Performance improvements

The CLI now builds projects with a larger number of components faster.
The commit mentions some [really nice gains](https://github.com/angular/angular-cli/commit/0a4943556ffa3c0888aa09f96d7508af56db637e) but I was not able to reproduce them in my experiments on large projects. 

### ng dev

The `ng serve` command is now aliased to `ng dev` (in addition to the existing `ng s`).
This aligns with the Vite ecosystem, where the development server is usually started using `npm run dev`.

Speaking of commands, the `ng doc` command has been removed from the CLI in v18.

### New build package

The Angular CLI now has a new package for building applications: `@angular/build`.
It contains the esbuild/Vite builders, that were previously in the `@angular-devkit/build-angular` package.
This allows the new package to only have Vite and ESBuild as dependencies,
and not Webpack.
The `serve`/`build`/`extract-i18n` builders are now in this new package.
The `@angular-devkit/build-angular` package can still be used,
as it provides an alias to the now-moved builders.

You'll notice that an optional migration can be run when updating your application to v18, to update your `angular.json` file to use the new package 
(where `@angular-devkit/build-angular` is replaced by `@angular/build`)
and update your `package.json` accordingly (to add `@angular/build` and remove `@angular-devkit/build-angular`).

This will only be done if you don't use any Webpack-based builders in your applications,
so the migration does nothing if you have tests using Karma for example (as they run using Webpack).

### Less and PostCSS dependencies

The CLI supports Sass, Less, and PostCSS out of the box,
and until now, these dependencies were installed in your `node_modules`
when creating a new application (even if you were not using these dependencies).

Less and PostCSS are now optional dependencies for the new `@angular/build` package and need to be installed explicitly if you switch to the new package.

When you update your application to v18, these dependencies will be added automatically by `ng update` if you choose to switch to `@angular/build` (and if you're using them of course).

### Native async/await in zoneless applications

ZoneJS has a particularity: it can't work with async/await.
So you may not know it, but every time you use async/await in your application,
your code is transformed by the CLI to use "regular" promises.
This is called downleveling, as it transforms ES2017 code (async/await) into ES2015 code (regular promises).

As we are now able to build applications without ZoneJS (even if it is still experimental),
the CLI doesn't downlevel async/await when `zone.js` is not in the application polyfills.
This should make the build a tiny bit faster and lighter in that case.

### New project skeleton updates

If you want to upgrade to v18 without pain (or to any other version, by the way), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (17.3.0 for example), and the target version (18.0.0 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/17.3.0...18.0.0](https://github.com/cexbrayat/angular-cli-diff/compare/17.3.0...18.0.0).
It can be a great help along with the official `ng update @angular/core @angular/cli` command.

You'll notice that the `assets` folder has been replaced by a `public` folder in new projects.
You'll also note that the `app.config.ts` file now contains the `provideZoneChangeDetection()` provider by default with the `eventCoalescing` option set to `true` (which avoids the change detection being triggered several times by ZoneJS when an event bubbles and is listened to by several template listeners). 


## Summary

That's all for this release.
v19 will probably be dedicated to stabilizing the signals APIs introduced these past months.
We should also see a new feature to declare variables in the template itself, using `@let`, as well as an option to switch to Intl-based internationalization.
Stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
