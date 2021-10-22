---
layout: post
title: What's new in Angular 13?
author: cexbrayat
tags: ["Angular 13", "Angular"]
description: "Angular 13 is out!"
---

Angular&nbsp;13.0.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#1300-2021-11-03">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This new major version contains a few changes,
and the Angular team also published a few RFCs about the future of Angular,
that we discuss at the end of this post.

## Typescript 4.4, RxJS 7, NodeJS 16 support

Angular&nbsp;13 requires your code to be written in Typescript 4.4,
and dropped the support of TS 4.2 and 4.3.
Angular now also officially support RxJS v7,
so you can upgrade your applications in peace
(but Angular itself still uses RxJS v6 internally).
The NodeJS versions from v12.20+ to v16.10+ are now supported.

The update to TypeScript 4.4 removes the need for Angular to workaround
a limitation of TypeScript which did not allow a setter to have a different type than its getter.
So until now, if you wanted a component to accept a boolean or a string for an `@Input()` setter, and the getter to only return a boolean, you had to use the weird "input type coercion" syntax with:

    @Input() get disabled(): boolean { return this._disabled; }
    set disabled(value: boolean) { this._disabled = (value === '') || value; }
    // ngAcceptInputType is a hint for the Angular compiler to know that the input
    // can in fact be a boolean or a string
    static ngAcceptInputType_disabled: boolean | string;

This can now be removed as TypeScript supports a different type for the getter/setter pair \o/. There are no migration or warning messages for this change, so you'll have to search for `ngAcceptInputType` yourself.


## IE11 support dropped

Angular dropped support for IE11,
and code specific to this browser is starting to be removed from the framework and the CLI.
Hopefully this shouldn't be a problem for you, as IE11 is now something like 0.5% of the market share,
and even big companies like Google don't support it anymore.
The CLI will now output a warning message if you're still trying to build for IE11.


## View Engine end-of-life

It's official, View Engine is no longer supported,
and the code will slowly disappear from the framework.

As a related good news, Angular now ships partially compiled packages!

Since Angular v12, it was possible to ship libraries in the "partially compiled" format,
making them directly consumable by Ivy projects, without the need to run `ngcc` on them.
Angular itself was, weirdly enough, still shipping View Engine packages,
making `ngcc` a required step to compile Angular itself in Ivy format,
and slowing down the first build.

This is no longer the case, and the packages are now shipped in the "partially compiled" format,
making `ngcc` no longer required, and the first build much faster 🚀.
When the rest of the ecosystem is ready, we'll say goodbye to `ngcc`.
Our own tiny libraries, [ngx-valdemort](https://github.com/Ninja-Squad/ngx-valdemort) for handling form error messages,
and [ngx-speculoos](https://github.com/Ninja-Squad/ngx-speculoos) for simplifying unit-testing,
were already shipped in the "partially compiled" format of course 😎.

## Forms

In a near future, we should finally have strictly typed forms
(see the Angular v14 section below).
In the meantime, a small improvement landed:
`status` and `statusChanges` are now strictly typed as `FormControlStatus` and `Observable<FormControlStatus>` instead of `string` and `Observable<any>` previously.
`FormControlStatus` is a new union type of the various status values:
`'VALID' | 'INVALID' | 'PENDING' | 'DISABLED'`.
This is technically a breaking change,
but unless you were doing weird things,
that should work fine.

## Templates

The `fullTemplateTypeCheck` compiler option is now deprecated
in favor of the `strictTemplates` option.
`strictTemplates` is technically more strict,
as it has more checks, but you should definitely switch to it.

The longhand binding prefixes in the template syntax are also deprecated.
So if you ever used `bind-input` or `on-click` in your templates,
you should now use the shorthand (and way more common) `[input]` and `(click)` syntax.
Did you even know that was a thing? 😉

## Pipes

The `date` pipe has an optional second argument if you want to specify the timezone or timezone offset:

{% raw %}
    {{ date | date: "shortTime":"+1200" }}
{% endraw %}

Angular v13 added the possibility to define the default timezone or timezone offset to use
for the `date` pipe, instead of having to repeat it in every template.
To do so, you'll have to use the special token `DATE_PIPE_DEFAULT_TIMEZONE`:

    providers: [
      { provide: DATE_PIPE_DEFAULT_TIMEZONE, useValue: '+1200' }
    ]

## Core with factory-less APIs

The `createComponent` API has been simplified to accept
a component class directly instead of a component factory.
Until now, you had to use this pretty terrible API
to create a new component instance dynamically:

    constructor(private componentFactoryResolver: ComponentFactoryResolver) {}

    ngAfterViewInit() {
      const greetingsFactory =
        this.componentFactoryResolver.resolveComponentFactory(GreetingsComponent);
      this.greetings.createComponent(greetingsFactory);
    }

Ivy made this change possible, and you can now write:

    ngAfterViewInit() {
      this.greetings.createComponent(GreetingsComponent);
    }

No more factories \o/!

## Tests

The new `teardown` behavior of the `TestBed` is now enabled by default.
This can seriously speed up your tests!
It has been introduced in Angular v12.1,
and you can read more about it in [our blog post](/2021/06/25/what-is-new-angular-12.1).
As it is now the default, you can remove the opt-in flag from your `TestBed` configuration.
Note that an automatic migration will opt-out of this behavior
if you did not opt-in previously,
to avoid potential issues
(if your tests were relying on the broken teardown behavior).
I suggest you remove the `teardown` flag from your `TestBed` configuration
if the migration adds it,
and migrate your tests to the new behavior,
as this can lead to [3 times faster `ng test`](/2020/11/25/faster-ng-test/).

## Router

`routerLink` has a breaking change:
until now, giving it `null` or `undefined` has the same behavior as giving it `[]` (and navigated to the same page),
and there was no way to disable the link navigation.
In v13, if you give `null` or `undefined` to `routerLink`,
then the navigation is disabled (and the `href` attribute is removed from the link).
This is a cool new feature,
and to avoid breaking your code,
a migration will automatically update `[routerLink]=""` to `[routerLink]="[]"`
as this was probably the intended goal.

`routerLinkActive` now has a new output `isActiveChange` that emits `true` when the link becomes active, and `false` when it becomes inactive.
This is handy if you want to apply a style somewhere else than on the link itself: `<a routerLink="/me" routerLinkActive="active-link" (isActiveChange)="doSomething($event)">`.

`routerOutlet` also gained two outputs: `attach` and `detach` to let you know when an instance is detached or re-attached when using a `RouteReuseStrategy`
(which is different than the `activate` and `deactivate` outputs that already existed,
and emits when a component is instantiated or destroyed by the outlet).

A new option called `canceledNavigationResolution` has been added to the `Router`
to correctly restore the browser history in the case a navigation was canceled by `CanDeactivate` guard.
If you encountered [this issue](https://github.com/angular/angular/issues/13586),
you can now add `router.canceledNavigationResolution = 'computed';` to your application.
This may become the default behavior in the future.

## Service worker

The `activateUpdate` and `checkForUpdate` promises now return `true` if the update was activated and `false` if no update was available
instead of `void` until now.
As a result, developers no longer have to check the `activated` observable to know if the call resulted in an update or not.
`activated` is now unnecessary and deprecated.

The `available` observable is also deprecated,
and replaced by `versionUpdates` which provides the same information,
and even more, as it also emits if a new version is available on the server (not yet downloaded) and if an installation of a new version failed.

## Angular v14

What to expect in v14?
As the team is now more openly sharing its goals,
I can freely talk about the next version
(without breaking the NDA I signed as an Angular team member 😅).

Some RFCs have been released and are being discussed by the community.

The most awaited one is probably the one about
[standalone components](https://github.com/angular/angular/discussions/43784) (or how to make modules optionals).
The idea is to introduce a new flag in the `@Component` decorators
(and `@Directive`/`@Pipe` decorators)
to mark them as standalone.
By doing so, a component can then be used without the need to be declared in a module.
It can directly declare what it uses.
This opens a ton of possibilities,
like getting rid of modules in most cases (they would still be useful for a few things),
API simplifications, components lazy-loading, etc 😍.

Another cool discussion started around [faster developer experience with type-checking in the background](https://github.com/angular/angular/issues/43131).
The gist of the idea would be to have `ng serve` running type-checking in the background,
hence making sure that the TypeScript compilation is not slowing down the feedback loop.
In most cases, everything is fine with our code,
and we just want to see the result in the browser as fast as possible.
We would still have compilation errors if something is broken, just a bit later.
One idea would be to leverage the awesome [Vite](https://vitejs.dev/) tooling,
which does that, and much more.
Vite is the new "hot" tool in the JS world, with Vue, Svelte, and React developers already using it.
Without digging too much into the details,
one of the strengths of Vite is to leverage ESM modules
to give a much faster reloading experience while developing.
In this context, the recent packaging changes in the Angular world
that switches the shipped libraries to ESM modules make a lot of sense.
If that ever becomes a reality,
it would bring a massive improvement in the developer experience ✨.

One last really exciting feature is the experimental [PR about typed forms](https://github.com/angular/angular/pull/43834).
This is a feature requested by developers a long long time ago,
and we may see a typed version of the Reactive Forms API in the future (maybe v14?).
The PR is an experiment and will not be merged without a more formal RFC,
but it gives an idea of what it would look like.
Without too many breaking changes, and a lot of TypeScript devilries,
most APIs would be the same, but type-safe.

Even something like `form.get('user.address.street').value` would be properly typed 😲!

Stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
