---
layout: post
title: What's new in Angular 12.0?
author: cexbrayat
tags: ["Angular 12", "Angular"]
description: "Angular 12 is out!"
---

Angular&nbsp;12.0.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#1200-2021-05-12">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This new major version contains quite a few changes!

## View Engine is deprecated

The Ivy project started in 2018, and was first released in Angular v8,
before becoming the default in v9.
Since then most applications switched from View Engine,
which is now officially deprecated.
New applications with Angular v12 can still consume libraries compiled with View Engine,
but they are now required to run with Ivy.
The bridge between the two compilers/runtimes is done thanks to `ngcc`,
the Angular compatibility compiler,
which will still be around for some time.

In the future, libraries will have to publish an Ivy version,
and we'll get rid of `ngcc`.
To be accurate, libraries will be published as a "partially compiled" Ivy version,
thanks to the Angular linker.
Publishing a View Engine version is now deprecated.

There is a high-level introduction of this topic on the [Angular blog](https://blog.angular.io/upcoming-improvements-to-angular-library-distribution-76c02f782aa4)
and we wrote [an article about how the linker works](/2021/01/27/angular-linker/)
if you're interested in the nerdy details 🤓.

Note that trying to consume this new Ivy library format in a View Engine application
will throw an error ([NG6999](https://angular.io/errors/NG6999)).

To sum up:

- if you're developing an Angular application, you now have to use Ivy
- if you're developing an Angular library, you can now ship an Ivy version, removing the need for `ngcc` to handle it
(check out our article linked above to see how).

The libraries we maintain
([ngx-valdemort](https://github.com/Ninja-Squad/ngx-valdemort)
and [ngx-speculoos](https://github.com/Ninja-Squad/ngx-speculoos))
are available in the new format.
It means that `ngcc` will just skip them and your build will be faster than before!

## IE 11 is deprecated

After some discussions on the [RFC](https://github.com/angular/angular/issues/41840),
Angular v12 deprecated the support for IE 11, and will remove it in v13.


## TypeScript 4.2

TypeScript v4.2 has been released, and Angular now officially supports it.
You can read the [announcement post](https://devblogs.microsoft.com/typescript/announcing-typescript-4-2/)
on the Microsoft blog to learn more about the new TS features.

Note that Angular v12 drops the support of TS 4.0 and 4.1,
so you'll have to update your TS version when upgrading.

While we're on the topic of dropping support, Angular v12 is no longer supporting Node v10.


## Templates

The nullish coalescing operator (`??`) introduced in TS 3.7 is now supported in templates.
This allows us to write:

{% raw %}
    <div>{{ user.name ?? 'Anonymous' }}</div>
{% endraw %}

The template compiler now also keeps track of the HTML comments.
It might sound useless, but it allows tools like `angular-eslint` to leverage them.
So we can now directly disable a lint warning from the template!

{% raw %}
    <!-- eslint-disable-next-line @angular-eslint/template/no-any -->
    <div>{{ $any(user).name }}</div>
{% endraw %}

## Forms

You can use the `min` and `max` validators in a template-driven form (with `ngModel`).
These validators have been available since Angular v4.2 both in templates and in code with `Validators.min` and `Validators.max`.
But the template version quickly got reverted as it introduced a breaking change in a minor Angular version.
The plan was to re-introduce them in a later major version, and 4 years later, here there are 😆.
You can now use them in templates as well (we prefer using `ReactiveForms` at Ninja Squad).
Note that this is a breaking change, as the `min` and `max` attributes were previously ignored,
and will now be detected as validators.

    <input [(ngModel)]="user.age" min="1" [max]="max" />

Another change in forms is the addition of the `emitEvent` option to most methods that handle controls in `FormGroup` (`addControl`, `removeControl`, `setControl`) and `FormArray` (`push`, `insert`, `removeAt`, `clear`, `setControl`).
The default is `true` to keep the current behavior, but you can now specify `false` to avoid emitting a value and status change
when using these methods. For example:

    this.userForm.removeControl('login', { emitEvent: false });
    // does not emit the new value of `userForm`


## Http

### Params as numbers and booleans

A tiny change in the `common/http` package I'm happy with (because I made it 😬)
is the possibility to use numbers or booleans as HTTP parameters,
without the need of transforming them to strings.
For example, we used to write:

    // `page` is a number
    this.http.get('api/users', { params: { page: `${page}` }})

Now we can write:

    this.http.get('api/users', { params: { page: page }});
    // or even better
    this.http.get('api/users', { params: { page }});

A small win, but as we're writing this kind of code every day, it feels good.

### HttpStatusCode
Another change is the introduction of an enum called `HttpStatusCode`
representing a human-readable list of HTTP status codes:

    // the response is a 401
    if (response.status === HttpStatusCode.Unauthorized) {
      // we redirect to login
      this.router.navigateByUrl('/login');

You'll probably never run into my favorite [HTTP status code 418](https://en.wikipedia.org/wiki/Hyper_Text_Coffee_Pot_Control_Protocol)
though: `ImATeapot`.

### HttpContext

A long-requested feature for `HttpClient` is the ability to store
and retrieve custom metadata for requests, especially in interceptors.
This is now possible thanks to `HttpContext`! 🎉

It used to be painful to give some context to an interceptor.
The most common workaround was to use headers:

    const headers = { 'should-not-handle-error': 'true' };
    return this.http.get('/api/users', { headers });

And then check and remove this header in the interceptor:

    intercept(req: HttpRequest<unknown>, next: HttpHandler) {
      // if there is a header specifically asking for not handling the error, we don't handle it
      const shouldNotHandleError = req.headers.get('should-not-handle-error');

      if (shouldNotHandleError) {
        // don't send the header to the server
        req.headers.delete('should-not-handle-error');
      }

Now it gets easier thanks to `HttpContext`.
The context uses a type safe token (`HttpContextToken`),
so you can define something like this in your interceptor:

    export const SHOULD_NOT_HANDLE_ERROR = new HttpContextToken<boolean>(() => false);

And simplify the interceptor to:

    intercept(req: HttpRequest<unknown>, next: HttpHandler) {
      // if there is a context specifically asking for not handling the error, we don't handle it
      const shouldNotHandleError = req.context.get(SHOULD_NOT_HANDLE_ERROR);

All HTTP methods have been updated to accept a new `context` option,
which is a Map that you can build in a type-safe way by using the token defined previously:

    const context = new HttpContext().set(SHOULD_NOT_HANDLE_ERROR, true);
    return this.http.get('/api/users', { context });

### XhrFactory

Note that the super low level `XhrFactory` class moved from `angular/common/http`
to `angular/common`.
No worries, an automatic migration will rewrite your imports if you're using it when running `ng update`.


## Core

### APP_INITIALIZER now supports Observable

`APP_INITIALIZER` is a special token that you can use to provide functions that you want to run
on the application initialization.
If the function returns a `Promise`,
Angular waits for the promise to resolve to start the application.
We can now also return an `Observable` in Angular v12,
which is handy as all the Angular ecosystem favors observables over promises.

### emitDistinctChangesOnlyDefaultValue

The `emitDistinctChangesOnlyDefaultValue` option for queries, introduced in v11.2,
 now defaults to `true` (which is a breaking change).
If you don't know what this option is about,
check out our explanation in [our blog post about Angular v11.2](/2021/02/11/what-is-new-angular-11.2/) 🤗.


## Router

### routerLinkActive has more fine-tuned options

The router offers a directive called `routerLinkActive`
to add a CSS class to the link if it points to the current URL.
The directive accepts an option to specify if you want an exact match or not:

    <a
      routerLink="/admin/users"
      routerLinkActive="active-link"
      [routerLinkActiveOptions]="{ exact: true }">
      Users
    </a>

The `exact` option was a bit raw though: if `true`, all paths (URL segments) _and_ query params must be the same,
but the fragment and the matrix parameters were ignored.

Angular v12 introduces more fined-tuned options that allow specifying exactly what you want to match with 4 options
for the 4 parts of the URL: `paths`, `queryParams`, `matrixParams` and `fragment`.

The `queryParams` and `matrixParams` options can receive the value `exact`, `ignored`
or `subset` (if you want to match part of the params but not necessarily all),
while the `paths` option can receive `exact` or `subset`
and the `fragment` option can only receive `exact` or `ignored`:

    <a
      routerLink="/admin/users"
      routerLinkActive="active-link"
      [routerLinkActiveOptions]="{ paths: 'exact', queryParams: 'subset', matrixParams: 'ignored', fragment: 'ignored' }">
      Users
    </a>

`exact: true` is the same as `paths: 'exact', queryParams: 'exact', matrixParams: 'ignored', fragment: 'ignored'`,
and `exact: false` is the same as `paths: 'subset', queryParams: 'subset', matrixParams: 'ignored', fragment: 'ignored'`.

The `isActive` method of the router now takes the same options as well.

### fragment is now nullable

`ActivatedRouteSnapshot.fragment` is now nullable.
This is a potential breaking change, so `ng update` will automatically add non-null assertions to your code if you're using it.


## Animations

It is now possible to disable the animations based on runtime information.
Previously, we could only either include the `BrowserAnimationsModule` or the `NoopAnimationsModule`
to enable/disable the animations.

It is now possible to use `BrowserAnimationsModule.withConfig({ disableAnimations: true })`.


## i18n

Angular v12 offers a tool called `localize-migrate` to migrate your message IDs to the new format
(see [our blog post about Angular v11](/2020/11/11/what-is-new-angular-11.0/)).
The legacy message format is now deprecated.

The migration is fairly easy:

    ng extract-i18n --format=legacy-migrate
    npx localize-migrate --files=*.xlf --map-file=messages.json

And you can now use the new message ID format!


## Language Service

The Ivy Language Service (that powers the autocomplete in your IDE) keeps improving,
and is now enabled by default.
We wrote [an article about the Language Service](https://blog.ninja-squad.com/2021/01/19/angular-language-service/) if you want to dive in.


## Zone.js

Angular v12 drops the support for zone.js v0.10.x,
so you now have to use at least v0.11.4.


## A new secret profiler

The `ng` object that you can access in the browser console gained a new `ɵsetProfiler` function,
available even in production.

You can call it from your browser console with a callback that will be called
on some specific events:

- TemplateCreateStart (1)
- TemplateCreateEnd (2)
- TemplateUpdateStart (3)
- TemplateUpdateEnd (4)
- LifecycleHookStart (5)
- LifecycleHookEnd (6)
- OutputStart (7)
- OutputEnd (8)

To get a sense of what this does, type the following code in your browser console (in an Angular 12 application):

    ng.ɵsetProfiler((event, value) => {
      console.log(event, value)
    })
    // logs
    // 3 - { title: 'App' }
    // and a ton of other traces


You should see a bunch of traces indicating when the template function of a component runs,
when a lifecycle hook executes and when an output handler is evaluated.
This profiler is a bit raw of course,
but we can imagine that some tooling will leverage this in the future and give us an accurate feedback
on how our applications are behaving.

Note that this API is private and experimental, so it might change in the future.

Another function has been added on `ng` as, called `getDirectiveMetadata`.
It is now available along `getComponent`, `getInjector`, etc.
It allows grabbing the information of a directive or a component directly from the console.
Again, this is a bit raw, but will probably be used by tools to analyze a running application.
You can test it in your browser console:

    const userElement = document.querySelector('app-user');
    const userComponent = ng.getComponent(userElement);
    const userMetadata = ng.getDirectiveMetadata(userComponent)
    console.log(userMetadata);
    // logs
    // { inputs: { userModel: "userModel" }, outputs: {}, changeDetection: 1, encapsulation: 0 }



All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!