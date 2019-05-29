---
layout: post
title: What's new in Angular 8.0?
author: cexbrayat
tags: ["Angular 8", "Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4"]
description: "Angular 8.0 is out! Read all about the new Ivy compiler/runtime, the new Bazel support, and all the tiny features and breaking changes!"
---

Angular&nbsp;8.0.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#800-2019-05-28">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

A personal announcement first:
I'm now officially part of the Angular team
as a collaborator,
in an effort from the core team to include more developpers from the community.
Angular&nbsp;8.0 has a little bit more code of mine than the other releases 😊.

This release is mostly about Ivy
and the possibility to give it a try,
but it also includes a few features and breaking changes.
Hopefully the update should be very easy,
as the Angular team wrote a bunch of schematics
that will do the heavy lifting for you.

## TypeScript 3.4

Angular&nbsp;8.0 now supports TypeScript 3.4,
and even requires it, so you'll need to upgrade.

You can checkout out what [TypeScript 3.3](https://devblogs.microsoft.com/typescript/announcing-typescript-3-3/) and [TypeScript 3.4](https://devblogs.microsoft.com/typescript/announcing-typescript-3-4/) brings on the Microsoft blog.

## Ivy

Ivy is obviously a huge part of this release,
and it took most of the effort from the team these last month.
There is so much to say about Ivy that I wrote a
[dedicated article about it](/2019/05/07/what-is-angular-ivy/).

TL;DR: Ivy is the new compiler/runtime of Angular. It will enable very cool features in the future,
but it is currently focused on not breaking existing applications.

Angular&nbsp;8.0 is the first release to officially offer a switch to opt-in into Ivy.
There are no real gains to do so right now,
but you can give it a try to see if nothing breaks in your application.
Because, at some point, probably in v9, Ivy will be the default.
So the Angular team hopes the community will anticipate the switch and provide feedback,
and that we'll catch all the remaining issues before v9.

We tried it on several of our apps and already caught a few regressions,
so we would strongly advise to not use it blindly in production 😄.

If you feel adventurous, you can add `"enableIvy": true` in your `angularCompilerOptions`,
and restart your application: it now uses Ivy!
Check [our article](/2019/05/07/what-is-angular-ivy/)
and the [official guide for more info](https://angular.io/guide/ivy).

## Bazel support

As for Ivy, we wrote a dedicated article on how to build your
[Angular applications with the new Bazel support](/2019/05/14/build-your-angular-application-with-bazel/) 🛠.

<p style="text-align: center;">
  <img class="rounded img-fluid" style="max-width: 20%" src="/assets/images/2019-05-14/bazel.svg" alt="Bazel" />
</p>


## Forms

### markAllAsTouched

The `AbstractControl` class now offers a new method `markAllAsTouched`
in addition to the existing `markAsDirty`, `markAsTouched`, `markAsPending`, etc.
`AbstractControl` is the parent class of `FormGroup`, `FormControl`, `FormArray`,
so the method is available on all reactive form entities.

Like `markAsTouched`, this new method marks a control as `touched`
but also all its descendants.

    form.markAllAsTouched();

### FormArray.clear

The `FormArray` class now also offers a `clear` method,
to quickly remove all the controls it contains.
You previously had to loop over the controls to remove them one by one.

    // `users` is initialized with 2 users
    const users = fb.array([user1, user2]);
    users.clear();
    // users is now empty

## Router

### Lazy-loading with import() syntax

A new syntax has been introduced to declare your lazy-loading routes,
using the `import()` syntax from TypeScript
(introduced in [TypeScript 2.4](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-2-4.html).

This is now the preferred way to declare a lazy-loading route,
and the string form has been deprecated.
This syntax is similar to the
[ECMAScript standard](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/import)
and Ivy will only support this.

So you can change your `loadChildren` declarations from:

    loadChildren: './admin/admin.module#AdminModule'

to:

    loadChildren: () => import('./races/races.module').then(m => m.RacesModule)

A schematic offered by the CLI will automatically migrate your declarations
for you, so this should be painless if you run `ng update @angular/cli`.
Check out our article about [Angular CLI 8.0](/2019/05/29/angular-cli-8.0/)
to learn more about that.

### Location

To help people migrating from AngularJS,
a bunch of things have been added to the location services in Angular.

`PlatformLocation` now offers access to the `hostname`, `port` and `protocol`,
and a new `getState()` method allows to get the `history.state`.
A `MockPlatformLocation` is also available to ease testing.
All this is really useful if you are using `ngUpgrade`,
otherwise you probably won't need it.


## Service worker

### Registration strategy

The service worker registration has a new option
that allows to specify when the registration should take place.
Previously, the service worker was waiting for the application
to be stable to register, to avoid slowing the start of the application.
But if you were starting a recurring asynchronous task (like a polling process) on application bootstrap,
the application was never stable as Angular considers
an application to be stable if there is no pending task.
So the service worker never registered, and you had to manually workaround it.
With the new `registrationStrategy` option, you can now let Angular handle this.
There are several values possible:

- `registerWhenStable`, the default, as explained above
- `registerImmediately`, which doesn't wait for the app to be stable and registers the Service Worker right away
- `registerDelay:$TIMEOUT` with `$TIMEOUT` being the number of milliseconds to wait before the registration
- a function returning an Observable, to define a custom strategy. The Service Worker will then register when the Observable emits its first value.

For example, if you want to register the Service Worker after 2 seconds:

    providers: [
      ServiceWorkerModule.register('/ngsw-worker.js', {
        enabled: environment.production,
        registrationStrategy: 'registerDelay:2000'
      }),
      // ...
    ]

### Bypass a Service Worker

It is now also possible to bypass the Service Worker
for a specific request by adding the `ngsw-bypass` header.

    this.http.get('api/users', { headers: { 'ngsw-bypass': true } });

### Multiple apps on sub-domains

Previously, it was not possible to have multiple applications using
`@angular/service-worker` on different sub-paths of the same domain,
because each Service Worker would overwrite the caches of the others...
This is now fixed!

## Notable and breaking changes

A few things have changed and require some work from your part.
Some of the changes are driven by Ivy,
and are there to prepare our applications.
But the cool news is that the Angular team already wrote schematics
to make our life easier.

Simply run `ng update @angular/core` and the schematics will
update your code.
What do these schematics do? Let's find out!

### Queries timing

The `ViewChild` and `ContentChild` decorators now must have a new option called `static`.
Let me explain why with a very simple example using a `ViewChild`:

    <div *ngIf="true">
      <div #dynamicDiv>dynamic</div>
    </div>

Let's get that element in our component
and log it in the lifecycle hooks `ngOnInit` and `ngAfterViewInit`:

    @ViewChild('dynamicDiv') dynamicDiv: ElementRef<HTMLDivElement>;

    ngOnInit() {
      console.log('init dynamic', this.dynamicDiv); // undefined
    }

    ngAfterViewInit() {
      console.log('after view init dynamic', this.dynamicDiv); // div
    }

Makes sense as [AfterViewInit](https://angular.io/api/core/AfterViewInit) is called
when the template initialization is done.

But in fact, if the queried element is static (not wrapped in an `ngIf` or an `ngFor`),
then it is available in `ngOnInit` also:

    <h1 #staticDiv>static</h1>

gives:

    @ViewChild('staticDiv') staticDiv: ElementRef<HTMLDivElement>;

    ngOnInit() {
      console.log('init static', this.staticDiv); // div
    }

    ngAfterViewInit() {
      console.log('after view init static', this.staticDiv); // div
    }

This was not documented, or recommended,
but that's how it currently works.

With Ivy though, the behavior changes to be more consistent:

    ngOnInit() {
      console.log('init static', this.staticDiv); // undefined (changed)
    }

    ngAfterViewInit() {
      console.log('after view init static', this.staticDiv); // div
    }

A new `static` flag has been introduced to not break existing applications,
so if you want to keep the old behavior even when you'll switch to Ivy,
you can write:

    @ViewChild('static', { static: true }) static: ElementRef<HTMLDivElement>;

and the behavior will be the same as the current one
(the element is also accessible in `ngOnInit`).

Note that if you add `static: true` on a dynamic element (wrapped in a condition or a loop),
then it will not be accessible in `ngOnInit` nor in `ngAfterViewInit`!

`static: false` will be how Ivy behaves by default.

To not break existing applications and to ease the migration,
the Angular team wrote a schematic that automatically analyzes your application,
and adds the `static` flag.
It even offers two strategies:
- one based on your templates, which will make sure that your application works
(so it tends to mark queries as static even when they aren't).
You are sure it works,
but it exposes you to problems if you wrap your static element in a condition or a loop later.
- one based on your usage of the query,
which is more error-prone (as it is harder for the schematic to figure it out),
but will not mark the queries as static if they don't need to be.
So most queries will have `static: false`, which will be the default in Ivy.

The first strategy is used by default when you run `ng update` because it is the safest,
but you can try the usage strategy by using `NG_STATIC_QUERY_USAGE_STRATEGY=true ng update`.

You can check out the [official guide](https://v8.angular.io/guide/static-query-migration) for more information.

This is what the migration looks like (with a failure in one component):

    ------ Static Query Migration ------
    With Angular version 8, developers need to
    explicitly specify the timing of ViewChild and
    ContentChild queries. Read more about this here:
    https://v8.angular.io/guide/static-query-migration

    Some queries could not be migrated automatically. Please go
    those manually and apply the appropriate timing.
    For more info on how to choose a flag, please see:
    https://v8.angular.io/guide/static-query-migration
    ⮑   home/home.component.ts@43:3: undefined

Note that this only concerns `ViewChild` and `ContentChild`,
not `ViewChildren` and `ContentChildren`
(which will work the same way in Ivy and View Engine).

### Template variable reassignment

Currently with View Engine, doing something like:

{% raw %}
    <button
      *ngFor="let option of options"
      (click)="option = 'newButtonText'">{{ option }}</button>
{% endraw %}

works.

In Ivy, that won't be the case anymore:
it will not be possible to reassign a value to a template variable (here `option`).
To prepare the switch to Ivy, a schematic analyzes your templates
when you upgrade to Angular&nbsp;8.0
and warns you if that's the case.

You then have to manually fix it:

{% raw %}
    <button
      *ngFor="let option of options; index as index"
      (click)="options[index] = 'newButtonText'">{{ option }}</button>
{% endraw %}

### DOCUMENT

The [`DOCUMENT` token](https://angular.io/api/common/DOCUMENT)
moved from `@angular/platform-browser` to `@angular/common`.
You can manually change it in your application,
but a provided schematic will take care of it for you.

### Deprecated webworker package

The `@angular/platform-webworker` package enabled running your Angular application in a Web Worker.
As this proved trickier than expected (for building the application, SEO...),
and not that good performance-wise,
the package has been deprecated and will be removed in the future.

### Deprecated HTTP package removed

`@angular/http` has been removed from 8.0,
after being [replaced by `@angular/common/http` in 4.3](/2017/07/17/http-client-module/)
and [officially deprecated in 5.0](/2017/11/02/what-is-new-angular-5/),
18 months ago.
You have probably already migrated to `@angular/common/http`,
but if you didn't, now you have to:
the provided schematic will only remove the dependency from your `package.json`.

You can also find all the deprecated APIs in the
[official deprecations guide](https://angular.io/guide/deprecations).


That's all for Angular&nbsp;8.0!
You can check out our other articles about
[Ivy](/2019/05/07/what-is-angular-ivy/),
the [CLI&nbsp;8.0 release](/2019/05/29/angular-cli-8.0/)
or the [new Bazel support](/2019/05/14/build-your-angular-application-with-bazel/).

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
