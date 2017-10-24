---
layout: post
title: What's new in Angular 5?
author: cexbrayat
tags: ["Angular 2", "Angular", "Angular 4", "Angular 5"]
description: "Angular 5 is out! Which new features are included?"
---

Angular&nbsp;5.0.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#TODO">
    <img class="img-rounded img-responsive" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

## Angular compiler is now much faster and more powerful!

As you may know, Angular has two ways to work:
- one where the templates are compiled at runtime (Just in time, JiT)
- one where the templates are compiled at build time (Ahead of time, AoT)

The second way is far better, as the work is done on the developer's machine at build time,
and not for each user at runtime, making the application start faster.
It also allows compiling all the templates of the application and catch errors early.
But this compiler was a bit slow before Angular&nbsp;5.0, and as a result,
most of us were using the JiT mode in development and the AoT mode only for production
(that's what Angular CLI does by default).

The main reason for this slowness was that every template change was triggering a full compilation of the application! That's no longer the case: leveraging the new "pipeline transformer" ability of the TypeScript compiler (introduced in TS 2.3, as I was talking about in [my previous article](/2017/07/17/what-is-new-angular-4.3/)), the Angular compiler, `ngc`, is now able to only compile what is necessary with the introduction of a new `watch` mode:

    ngc --watch

A new flag `--diagnostics` has also been introduced to print how much time the compiler spent on a compilation in watch mode.

We can expect the Angular CLI to use this new watch mode and it will probably become the default mode very soon!

The compiler can also check more thoroughly your templates, with the new option `fullTemplateTypeCheck`.
It can for example catch that a pipe is not used with the proper type:

    {% raw %}
    <!-- lowercase expects a string -->
    <div>{{ 12.3 | lowercase }}</div>
    {% endraw %}

This example will compile with `ngc` but not if `fullTemplateTypeCheck` is activated:

    Argument of type '12.3' is not assignable to parameter of type 'string'

It can also analyze the local variables referencing a directive in your templates.
For example, let's say you created a variable to reference a `ngModel`,
and want to access the `hasError()` method, but made a typo:

    {% raw %}
    <input [(ngModel)]="user.password" required #loginCtrl="ngModel">
    <!-- typo in `hasError()` method -->
    <div *ngIf="loginCtrl.hasEror('required')">Password required</div>
    {% endraw %}

This will also compile with `ngc`, except if `fullTemplateTypeCheck` is activated:

    Property 'hasEror' does not exist on type 'NgModel'. Did you mean 'hasError'?

That's super cool! Right now the default value of `fullTemplateTypeCheck` is `false`,
but we can expect to see it become `true` in a future release.
(Side note: this feature is currently a bit flaky, and I ran into issues testing it.
You might want to wait 5.0.x to try it!).

The compiler is now also smarter to understand factories,
and there's thus no need to use this weird trick anymore:

    export function webSocketFactory() {
      return WebSocket;
    }

    @NgModule({
      providers: [
        { provide: WEBSOCKET, useFactory: webSocketFactory },
      ]
    })
    export class AppModule {

You can now directly write:

    @NgModule({
      providers: [
        { provide: WEBSOCKET, useFactory: () => WebSocket },
      ]
    })
    export class AppModule {


## Forms

Forms have a tiny but really useful addition to their API:
the ability to decide when the validity and value of a field or form is updated.
This is something we already had in AngularJS 1.x, but not yet in Angular.

To do so, the `FormControl` allows to use an `options` object as the second parameter,
to define the synchronous and asynchronous validators,
and also the `updateOn` option.
Its value can be:

- `change`, it's the default: the value and validity are updated on every change;
- `blur`, the value and validity are then updated only when the field lose the focus;
- `submit`, the value and validity are then updated only when the parent form is submitted.

So you can now do something like this:

    this.passwordCtrl = new FormControl('', {
      validators: Validators.required,
      updateOn: 'blur'
    });

It's also possible to define this option on the `FormGroup` level,
to have all the fields of the group behaving the same:

    this.userForm = new FormGroup({
      username: '',
      password: ''
    }, { updateOn: 'blur' });

This is of course also possible in template-driven form,
with the `ngModelOptions` input of the `NgModel` directive:

    <input [(ngModel)]="user.login" [ngModelOptions]="{ updateOn: 'blur' }">

or the new `ngFormOptions` input of the `NgForm` directive to apply on all fields:

    <form [ngFormOptions]="{ updateOn: 'submit' }">

You can learn more about the plans for forms in this [design docs](https://docs.google.com/document/d/1dlJjRXYeuHRygryK0XoFrZNqW86jH4wobftCFyYa1PA/edit#).

## Http

The old `@angular/http` module is now officially deprecated and replaced by `@angular/common/http`,
the new `HttpClient` [introduced in 4.3](/2017/07/17/http-client-module/).
You can probably expect that `@angular/http` will be removed in Angular&nbsp;6.0.

`HttpClient` has been slightly improved with Angular&nbsp;5.0, as we are now able to directly use object literals
as headers or parameters, whereas we had to use the classes `HttpHeaders` and `HttpParams`.

So this kind of code:

    const headers = new HttpHeaders().set('Authorization', 'secret');
    const params = new HttpParams().set('page', '1');
    return this.http.get('/api/users', { headers, params });

can now be simplified into:

    const headers = { 'Authorization': 'secret' };
    const params = { 'page': '1' };
    return this.http.get('/api/users', { headers, params });

## Animations

Two new transition aliases are introduced: `:increment` and `:decrement`.
Let's say you want to animate a carousel with 5 elements,
with a nice animation based on the index of the element displayed.
You had to declare a transition like: `transition('0 => 1, 1 => 2, 2 => 3, 3 => 4', ...)`.
With Angular&nbsp;5, you can now use `transition(':increment')`!

## Router

The router gains two new events to track the activation of individual routes:

- `ChildActivationStart`
- `ChildActivationEnd`

These events are introduced to give a more fine-grained control than using the global `NavigationStart`/`NavigationEnd` events, if you for example want to display a spinner while some children components are loading.

More newsworthy, it's now possible to reload a page when the router
receives a request to navigate to the same URL.
Until now it was ignoring such a request,
making it impossible to build a "refresh" button.

It's now configurable at the router level, using `onSameUrlNavigation`,
which can receive either `reload` or `ignore` (currently the default).

    providers: [
      // ...
      RouterModule.forRoot(routes, {
        onSameUrlNavigation: 'reload'
      })
    ]

## i18n

The messages extracted from your application now include the interpolations used in the template.

Before:

    <source>
      Welcome to Ponyracer
      <x id="INTERPOLATION"/>
      <x id="INTERPOLATION_1"/>!
    </source>

Now:

    {% raw %}
    <source>
      Welcome to Ponyracer
      <x id="INTERPOLATION" equiv-text="{{ user.firstName }}"/>
      <x id="INTERPOLATION_1" equiv-text="{{ user.lastName }}"/>!
    </source>
    {% endraw %}

This can be really helpful for the translators,
as they now have a hint about the interpolations.

A notable change in i18n is that the i18n comments are now deprecated.
In Angular 4, you could use:

    {% raw %}
    <!--i18n: @@home.justText -->
      I don't output an element, just text
    <!--/i18n-->
    {% endraw %}

Starting with Angular 5, you are encouraged to use an already possible alternative with `ng-container`:

    {% raw %}
    <ng-container i18n="@@home.justText">
      I don't output an element, just text
    </ng-container>
    {% endraw %}

## Pipes, i18n and breaking changes

More importantly, the pipes that were helping with the internationalization (`number`, `percent`, `currency`, `date`)
have been completely overhauled.
They don't rely on the [Intl API](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl) anymore. This internationalization API was supposed to be provided by the browser,
but that was not always the case, so we had to use a polyfill,
and inconsistencies between browsers (and polyfills) led to numerous bugs.

If you don't do anything when you upgrade, you'll use the new pipes by default.
The good news is that there should be less bugs and you can remove the Intl polyfill you likely included.
The bad news is that they don't all have the same parameters and behavior as previously,
and that can break your application.

Using a different locale than the default one (`en-US`) now requires to load additional locale data:

    import { registerLocaleData } from '@angular/common';
    import localeFr from '@angular/common/locales/fr';

    registerLocaleData(localeFr);

All the i18n pipes now take a locale as their last parameter, allowing to dynamically override it:

    {% raw %}
    @Component({
      selector: 'ns-locale',
      template: `
        <p>The locale is {{ locale }}</p>
        <!-- will display 'en-US' -->

        <p>{{ 1234.56 | number:'1.0-3':'fr-FR' }}</p>
        <!-- will display '1 234,56' -->        
      `
    })
    class DefaultLocaleComponentOverridden {
      constructor(@Inject(LOCALE_ID) public locale: string) { }
    }
    {% endraw %}

The currency pipe now takes a string as it second parameter,
allowing to chose between `'symbol'` (default), `'symbol-narrow'` or `'code'`.
For example, with canadian dollars:

    {% raw %}
    <p>{{ 10.6 | currency:'CAD' }}</p>
    <!-- will display 'CA$10.60' -->

    <p>{{ 10.6 | currency:'CAD':'symbol-narrow' }}</p>
    <!-- will display '$10.60' -->

    <p>{{ 10.6 | currency:'CAD':'code':'.3' }}</p>
    <!-- will display 'CAD10.600' -->
    {% endraw %}

The date pipe has several breaking changes.
I won't list them, it's easier to check out the [commit message](https://github.com/angular/angular/commit/079d884).

All things are not lost if you want to keep the "old" pipes for now,
as they have been kept in a new module `DeprecatedI18NPipesModule`,
that you can import if you want to still use them:

    @NgModule({
      imports: [CommonModule, DeprecatedI18NPipesModule],
      // ...
    })
    export class AppModule {

## Service Workers

Angular has a package called `@angular/service-worker`,
which has been in beta for quite some time and in a different repository.
It received a little bit of love with Angular&nbsp;5, as it graduated to the main repository,
so we can expect it to be brought to the same quality standards as the other packages,
and to be out of beta soon!

If you don't know about service workers, you can picture them as small proxies in your browser.
If you activate them in an app, it allows to cache static assets,
and to not fetch them on every reload, improving performances.
You can even go offline, and your app can still respond!

`@angular/service-worker` is a small package, but filled with cool features.
Did you know that if you add it to your Angular CLI application,
and turn a flag on (`"serviceWorker": true` in `.angular-cli.json`),
the CLI will automatically generate all the necessary stuff to cache your static assets by default?
And it will only download what has changed when you deploy a new version,
allowing blazingly fast application start!

But it can even go further, allowing to cache external resources (like fonts, icons from a CDN...),
route redirection and even dynamic content caching (like calls to your API),
with different strategies possible (always fetch for fresh data, or always serve from cache for speed...).
The package also offers a module called `ServiceWorkerModule` that you can use in your application to react
to push events and notifications!


## Other breaking changes

A few things that were deprecated in Angular&nbsp;4.0 have now been definitely removed.

There is a last breaking change that should not really impact you.
I feel morally obligated to show it to you,
but it's totally not interesting.

If you are declaring extra providers in the `platformXXXX()` or `bootstrapModule()` methods,
you now need to use the (new) `StaticProvider`, which is really similar to a `Provider`,
but forces you to explicitly declare the dependencies.
It does _not_ impact the providers you declare in your modules and components,
don't worry.

So if you have something like this:

    platformBrowserDynamic([
      MyCustomProviderA,
      MyCustomProviderB // depends on MyCustomProviderA
    ]).bootstrapModule(AppModule);

It must now be in 5.0:

    platformBrowserDynamic([
      { provide: MyCustomProviderA, deps: [] },
      { provide: MyCustomProviderB, deps: [MyCustomProviderA] }
    ]).bootstrapModule(AppModule);

I honestly couldn't come up with a decent real use-case,
as it is quite rare to give extra providers to these methods,
and this only impact the two cases in the example
and not `useValue`, `useFactory`, `useExisting`...
So I don't think many apps will be impacted :)

On the other hand, this change allows Angular to not depend on the `Reflect` API,
and that gives us (slightly) smaller bundles \o/.

Another change is the removal of the ES5 API to write Angular applications
without decorators.
This API was also depending on `Reflect` and is now gone.

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](http://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
