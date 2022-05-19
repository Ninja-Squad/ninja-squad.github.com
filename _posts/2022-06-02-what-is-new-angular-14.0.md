---
layout: post
title: What's new in Angular 14?
author: cexbrayat
tags: ["Angular 14", "Angular"]
description: "Angular 14 is out!"
---

Angular&nbsp;14.0.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/14.0.0">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This is a major release with really interesting features: let's dive in!

## Strictly typed forms

The [most up-voted issue](https://github.com/angular/angular/issues/13721)
in the Angular repository is solved in Angular v14:
we now have strictly typed forms!

As there is quite a bit to explain between the migration,
the new API, and the addition of `FormRecord` and `NonNullableFormBuilder`,
we wrote a dedicated blog post:

👉 [Strictly typed forms](/2022/04/21/strictly-typed-forms-angular)

TL;DR: with some elbow grease, it's now possible to have form values
perfectly typed, and no longer of type `any` ✨.

#### Other forms improvements

It is now possible to use negative indices on `FormArray` methods,
like the `Array` methods do in JavaScript.
For example `formArray.at(-1)` is now allowed and returns the last control of the form array.

## Standalone components (see ya NgModule!)

The other big feature of the release is the addition of the (experimental) standalone APIs.
Same here: as there is a lot to cover, we wrote a dedicated blog post:

👉 [A guide to standalone components](/2022/05/12/a-guide-to-standalone-components-in-angular)

TL;DR: it's now possible (but experimental) to get rid of NgModule in your applications,
and use the new standalone components/directives and pipes ✨.

## inject function

You can now use the `inject()` function from `'@angular/core'` (which already existed but has been improved)
to inject a token programmatically.

For example you can use it in a component:

    constructor() {
      const userService = inject(UserService);
      // ...
    }

It can only be called in some specific areas:

- in a constructor as above;
- to initialize a class field;
- in a factory function.

It opens the door to some interesting patterns,
especially for library authors.

## Router

The router received a lot of attention in this release.

#### Page title

It's now possible to set a page title directly in a route declaration:

    export const ROUTES: Routes = [
      { path: '', title: 'Ninja Squad | Home', component: HomeComponent },
      { path: 'trainings', title: 'Ninja Squad | Trainings', component: TrainingsComponent }
    ]

You can also define a resolver for the title:

    export const ROUTES: Routes = [
      { path: 'trainings/:trainingId', title: TrainingTitleResolver, component: TrainingComponent }
    ]

    @Injectable({
      providedIn: 'root'
    })
    export class TrainingTitleResolver implements Resolve<string> {
      resolve(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): string {
        return `Ninja Squad | Training ${route.paramMap.get('trainingId')}`;
      }
    }

This is not super flexible though, as you'll probably often want to display something more meaningful
like `Ninja Squad | Angular training` and not `Ninja Squad | Training 13`,
and that data lives in the component: the resolver can't access it.
But it's still a nice addition for adding static (or not too dynamic) titles.

It's also possible to write a custom strategy to build the title
by extending the built-in `TitleStrategy`.
For example, if I want to prepend `Ninja Squad | ` to all titles, I can do:

    @Injectable()
    export class CustomTitleStrategyService extends TitleStrategy {
      constructor(@Inject(DOCUMENT) private readonly document: Document) {
        super();
      }

      override updateTitle(state: RouterStateSnapshot) {
        const title = this.buildTitle(state);
        this.document.title = `Ninja Squad | ${title}`;
      }
    }

Then, use this custom strategy instead of the default one:

    @NgModule({
      //...
      providers: [{ provide: TitleStrategy, useClass: CustomTitleStrategyService }]
    })
    export class AppModule {}

And just define the specific part of the title on each route:

    export const ROUTES: Routes = [
      { path: '', title: 'Home', component: HomeComponent },
      { path: 'trainings', title: 'Trainings', component: TrainingsComponent }
    ]

#### Types

Some types have been improved in the router.
For example, all router events now have a `type` property, allowing to narrow their type like this:

    // send hits to analytics API only on navigation end events
    this.router.events
      .pipe(
        filter((event: Event): event is NavigationEnd => event.type === EventType.NavigationEnd),
        mergeMap(event => this.sendHit(event.url))
      )
      .subscribe();

`pathMatch` is now also more strictly typed and only accepts the two valid options `'full'|'prefix'`.
That's why a migration will add the explicit `Route` or `Routes` types on your routes declaration
if you don't have them when running `ng update`. Otherwise, TypeScript will be unhappy with `pathMatch: 'full'` as it'll think that `'full'` is a `string` and not a const.

#### Route providers, standalone routes, loadComponent

A bunch of new things have been added to the router to support the new standalone APIs.
For example, you can now define providers directly on a route, or lazy-load just a component.
Check out our blog post about [standalone components to learn more](/2022/05/12/a-guide-to-standalone-components-in-angular).

#### Accessibility

`routerLinkActive` gained a new input called `ariaCurrentWhenActive`,
which allows to set [`aria-current` a11y property](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-current).
The possible values are `'page' | 'step' | 'location' | 'date' | 'time' | true | false`.
For example:

    <a class="nav-link" routerLink="/" routerLinkActive="active" ariaCurrentWhenActive="page">Home</a>

## TestBed

It's now possible to configure the TestBed
to throw errors on unknown elements or properties found in a template.
Currently, Angular has two compilation modes: Just in Time (jit) and Ahead of Time (aot).
When you run `ng serve` or `ng build`, the aot mode is used.
But when running `ng test`, the jit compilation is used.
Weirdly enough, an error in a template results in just a warning in the console when the template compilation fails on an unknown element or property in jit mode.
That's why you can sometimes see `NG0303` and `NG0304` warnings in the console when you run your tests,
typically when you forgot to import or declare a component/directive necessary to test your component.

Starting with Angular v14, it is now possible to configure the TestBed to throw an error for these issues,
and thus make sure we don't miss them. I think this is amazing (but that's probably because I implemented it 😬):

    getTestBed().initTestEnvironment(
      BrowserDynamicTestingModule,
      platformBrowserDynamicTesting(),
      { 
        errorOnUnknownElements: true, 
        errorOnUnknownProperties: true 
      }
    );

The default for `errorOnUnknownElements` and `errorOnUnknownProperties` is `false`,
but we'll probably change it to true in a future release.
You can also enable/disable them in a specific test with `TestBed.configureTestingModule({ /*...*/, errorOnUnknownElements: false })`.

In the distant future, the tests will maybe use the aot compilation,
but [that's not for tomorrow](https://github.com/angular/angular/issues/43133#issuecomment-941151334).
In the meantime, these new options should be helpful!

## Compiler

As you probably know, you can't use a `private` member of a component in a template,
and you can only use `public` members.
Starting with v14, you can now also use `protected` members of a component in the template.

## Http

This is more a bugfix than a feature, but as it is a breaking change that may have an impact,
let's talk about it: `+` in query params are now properly encoded as `%2B`.
They used to be ignored by the `HttpClient` that was otherwise properly encoding the 
other special characters in query parameters.
You had to manually take care of the `+` signs, but this is no longer necessary:
you can now delete the code that was manually encoding them after upgrading to v14.

## Zone.js

Zone.js now supports `Promise.any()`, a [new method](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/any) introduced in ES2021.

## Service worker

The `versionUpdates` observable now emits `NoNewVersionDetectedEvent`
if the service worker did not find a newer version.

## Devtools

The Angular Devtools are now [available on Firefox](https://addons.mozilla.org/fr/firefox/addon/angular-devtools/) as well 🎉.

## Typescript and Node

Angular v14 drops the support of TypeScript v4.4 and 4.5 and now supports for v4.7
(recently [released](https://devblogs.microsoft.com/typescript/announcing-typescript-4-7/)).
It also drops the support of Node v12.

## Angular CLI

As usual, you can check out our dedicated article about the new CLI version:

👉 [Angular CLI v14](/2022/06/02/angular-cli-14.0)

## Summary

This release is packed with features as you can see,
and the future is exciting with the standalone APIs.
The roadmap now also mentions some efforts on the server-side rendering story,
which is not the strong suite of Angular (compared to other mainstream frameworks).

That's all for this release, stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
