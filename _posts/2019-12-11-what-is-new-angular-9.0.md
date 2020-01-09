---
layout: post
title: What's new in Angular 9.0?
author: cexbrayat
tags: ["Angular 9", "Angular 8", "Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4"]
description: "Angular 9.0 is out!"
---

Angular&nbsp;9.0.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#TODO">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

## Ivy, sweet Ivy

This is a long awaited release for the community,
as Ivy is now the default compiler/renderer in Angular 🌈.

If you want to learn more about Ivy itself,
check out [our dedicated blog post](/2019-05-07-what-is-angular-ivy/).

In a few words, if you're in a hurry,
Ivy is a complete rewrite of the underlying compiler and renderer.
The main goals are:
- a cleaner architecture of the framework, which is a stepping stone to optimizations and new features in the future
- a faster and stricter compilation, to help developers and avoid slowing them down
- smaller bundle sizes, especially in big applications right now, and all over the place in the future.

As you can probably imagine,
Ivy is a very big change internally,
and the team worked a lot to ensure that our applications are compatible.
Bundle sizes should improve in the future,
as well as runtime performances
(which are currently roughly on par with View Engine,
faster in some cases, slower in others).

As this is a big change,
I strongly encourage you to thoroughly test this update,
more thoroughly than the v5, v6, v7 or v8 updates.
If you encounter a problem,
open an issue with a reproduction,
and stay on v8 or use v9 without Ivy for the moment (`enableIvy: false`).

The new design will allow some cool features in the future,
like high order components, a better i18n, etc.
For this last point, guess what? It's already here!

## Internationalization with $localize

A new package appears with this release: `@angular/localize`.
This package is now in charge of all i18n concerns,
and offers quite a few interesting things.

In fact there are so many topics to cover
that we wrote a dedicated article about it:
[Angular i18n with $localize](/2019/12/10/angular-localize/).

This article talks about compile-time i18n,
the much awaited possibility to have translations in code,
and how all this works under the hood.
Check it out!

Note that even if you are not using i18n in your application,
but that one of your dependencies does (like ng-bootstrap for example),
then you have to add `@angular/localize` to your application.
This is fairly straightforward:

    ng add @angular/localize

But really you should check out [the blog post we wrote](/2019/12/10/angular-localize/)
or the updated chapter in [our ebook](https://books.ninja-squad.com/angular).

Unrelated to this new package,
the locale data now include the directionality of the locale (`ltr` or `rtl`).
You can get this information by using `getLocaleDirection(locale)`.

## Better type-checking

In the Ivy section, I was mentioning that the compilation is a bit stricter.
And indeed it is smarter!
If you use `fullTemplateTypeCheck`, you'll have the same level of strictness that you had before.
But if you want to go one step further,
you can try the `strictTemplates` option in your `tsconfig.json`:

    "angularCompilerOptions": {
      "strictTemplates": true
    }

Until now, you could for example give a string to `@Input()`
that was expecting a number: you now get a nice compilation error.
`ngFor` elements were previously typed as `any`,
and are now properly typed.
So:

{% raw %}
    <div *ngFor="let user of users">{{ user.nam }}</div>
{% endraw %}

is now caught by the compiler if you typed `nam` instead of `name`.
The `$event` parameter and `#ref` variables in templates are now also properly typed.

`strictTemplates` is just a shortcut to activate a bunch of strictness flags,
so if one particular check bothers you, you can disable it.
For example, if you don't want to check the type of the inputs:

    "angularCompilerOptions": {
      "strictTemplates": true,
      "strictInputTypes": false
    }

Check out the official list of flags in the [documentation](https://angular.io/guide/template-typecheck).

As a component author,
there is a convoluted way to accept other types than the declared one for your input.
It is mostly useful for library maintainers,
and you can check out the [official documentation for an example](https://angular.io/guide/aot-compiler#input-setter-coercion).


## Better auto-completion

The language service (the package responsible for the nice auto-completion we have in our IDEs) has been improved and now offers some really nice new features.
For example if you hover on a component or a directive in template,
you'll see if it is the former or the latter and from which module it comes from.
It should be way smarter and more robust overall.

## TypeScript 3.6

This release also comes with the need to upgrade to TypeScript 3.6.
You can check out which new features TS 3.6 offers on the [Microsoft blog](https://devblogs.microsoft.com/typescript/announcing-typescript-3-6/).

## Automatic migrations

If you are using the CLI `ng update @angular/core` command,
you'll notice that several automatic migrations will run.

If you are still using the deprecated `Renderer`, the schematic updates your code to use `Renderer2`. You can read more about that in the [official deprecation guide](https://angular.io/guide/deprecations#renderer-to-renderer2-migration).
The `Renderer` class was deprecated for a long time and has been removed from Angular.

If you are using a base class for a component or a directive, that base class must be annotated with a simple `@Directive()` decorator for Ivy.
For example:

    class WithRouter {
      constructor(public router: Router) {}
    }

    @Component({
      // ...
    })
    export class MenuComponent extends WithRouter {
      // uses `this.router` from `WithRouter`

Then after the migration, `WithRouter` has a `@Directive()` decorator added on its class:

    @Directive()
    class WithRouter {
      constructor(public router: Router) {}
    }

Note that this `@Directive()` decorator does not have a selector:
this was not possible before v9,
and it has been introduced for this use-case specifically.

The `@Directive()` decorator is also added to your base class
if it has decorated fields,
like `@Input()`, `@Output()`, `@ViewChild()`, `@HostBinding()`, etc..

Another migration adds an `@Injectable()` decorator on all services that don't have one.
It was not necessary for View Engine
(check [this blog post](/2016/12/08/angular-injectable/) if you want to know why)
but it is now with Ivy.
So everything that is referenced as a service in your application must now have
an `@Injectable()` decorator.

`ModuleWithProvider` must also provide its generic type,
so a schematic adds it if it is missing in your code.

You may also remember the `static` flag added in Angular 8.0,
to ease the migration to Ivy.
If you don't, check out what [we wrote about it at that time](/2019/05/29/what-is-new-angular-8.0/)
in the `Query timing` section.
This flag is now no longer required now that Angular uses Ivy.
So a migration will remove every `static: false` you have in your codebase,
as it is the default value.

All the migrations are properly documented in
the [official documentation for the v9 update](https://angular.io/guide/updating-to-version-9).

## Dependency injection

Until now, when using `@Injectable()`,
you could give only two values: an Angular module or `root`
(which is an alias for the root module of your application).
It now also accepts `platform` and `any`.
The latter has no use for application developers like you and me,
but the former could be useful if you have several Angular applications
or Angular Elements on the same page,
and want them to share a service instance.

## Deprecations

### entryComponents is no longer necessary

Until now you had to declare the component dynamically loaded,
typically in a modal, in the `entryComponents` of a module.
This is no longer necessary with Ivy!
You can safely remove `entryComponents` from your modules.

### TestBed.inject

The `TestBed.get` method that you probably use all over your unit tests
has been deprecated and replaced by `TestBed.inject`.
`TestBed.get` returns `any`, so you had to manually type the value returned.
It is now no longer necessary with `TestBed.inject`.
You can then replace:

    const service = TestBed.get(UserService) as UserService;

by

    const service = TestBed.inject(UserService);

## Breaking changes

### NgForm

The directive `NgForm` used to have `ngForm` as a possible selector
and it's now no longer the case.
It had already been deprecated in [Angular 7.0](/2018-10-18-what-is-new-angular-7/).

### Hammer

Until v9, an Angular application was offering [Hammer.JS](https://hammerjs.github.io/) support by default,
even if you were not using it.
To gain a few kB in our bundles, this is no longer the case,
and you'll have to import `HammerModule` explicitly in your root module
if you want to keep using Hammer.

## Intl API

The i18n pipes (`number`, `percent`, `currency`, `date`)
were using the Intl API,
and were rewritten to not depend on it in Angular&nbsp;5.0.
The current version of these pipes works without the Intl API.
If you really wanted to keep the old version,
you had to import `DeprecatedI18NPipesModule` in your application
when migrating to Angular&nbsp;5.0.
This is no longer possible as all the deprecated pipes have been removed.

This is a big update, and I'm sure you're dying to try it 😎.
You can also check out
[our blog post about the CLI v9](/2019/12/11/angular-cli-9.0/)
to see what's new there.

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
