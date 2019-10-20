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
- a support for runtime i18n.

For this last point, guess what? It's already here!

## Internationalization with $localize

A new package appears with this release: `@angular/localize`.
This package is now in charge of all i18n concerns,
and offers quite a few interesting things.

In fact there are so many topics to cover
that we wrote a dedicated article about it:
[Angular i18n with $localize](TODO add link).

This article talks about compile-time i18n, the much awaited runtime i18n,
and how all this works under the hood.
Check it out!

Note that even if you are not using i18n in your application,
but that one of your dependencies does (like ng-bootstrap for example),
then you have to add `@angular/localize` to your application.
This is fairly straightforward:

    ng add @angular/localize

But really you should check out [the blog post we wrote](TODO add link)
or the updated chapter in [our ebook](https://books.ninja-squad.com/angular).

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

Another migration adds an `@Injectable()` decorator on all services that don't have one.
It was not necessary for View Engine
(check [this blog post](/2016-12-08-angular-injectable/) if you want to know why)
but it is now with Ivy.
So everything that is referenced as a service in your application must now have
an `@Injectable()` decorator.

You may also remember the `static` flag added in Angular 8.0,
to ease the migration to Ivy.
If you don't, check out what [we wrote about it at that time](/2019-05-29-what-is-new-angular-8.0/)
in the `Query timing` section.
This flag is now no longer required now that Angular uses Ivy.
So a migration will remove every `static: false` you have in your codebase,
as it is the default value.

## Dependency injection

Until now, when using `@Injectable()`,
you could give only two values: an Angular module or `root`
(which is an alias for the root module of your application).
It now also accepts `platform` and `any`.
The latter has no use for application developers like you and me,
but the former could be useful if you have several Angular applications
or Angular Elements on the same page,
and want them to share a service instance.

## TestBed.inject

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


All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
