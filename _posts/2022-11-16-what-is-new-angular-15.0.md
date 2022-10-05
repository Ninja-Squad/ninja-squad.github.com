---
layout: post
title: What's new in Angular 15?
author: cexbrayat
tags: ["Angular 15", "Angular"]
description: "Angular 15 is out!"
---

Angular&nbsp;15.0.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/15.0.0">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This is a major release with a ton of interesting features: let's dive in!

## Standalone components are stable! ✨

Here we are: standalone components are now stable!
You can officially build Angular applications without modules if you want to.

A few improvements landed in v15.

The HTTP support evolved, and we can now use `provideHttpClient` to provide `HttpClient` without using `HttpClientModule` (see below).

We can now use `provideHttpClientTesting()` to provide `HttpClient` in tests,
and... `provideLocationMocks()` to test components using the router:

    TestBed.configureTestingModule({
      providers: [
        // 👇 similar to RouterTestingModule
        provideLocationMocks(), 
        provideRouter([]), 
        // 👇 similar to HttpClientTestingModule
        provideHttpClientTesting(), 
        provideHttpClient() 
      ],
    });

The `NgForOf` directive is now aliased as `NgFor` which makes it simpler to import it in your standalone components, as you previously had to know `ngIf` was the `NgIf` directive, and `ngFor` was the `NgForOf` directive 😅.

The same kind of thing has been done with the `RouterLink` directive in the router:
there was previously a `RouterLink` directive and a `RouterLinkWithHref` directive.
They are now merged into one, making it a no-brainer to import it.
A schematic will automatically migrate your code if you were using `RouterLinkWithHref`.

The language service (used for the autocompletion and type-checking in your IDE) has been improved for standalone components, and it now automatically offers to import a standalone directive/component/pipe
in your component, if you use one in its template ✨.

## HTTP with provideHttpClient

The HTTP support evolves and adapts to the new world of Angular 15, where modules are optional.
It's now possible to provide the `HttpClient` using `provideHttpClient()`.
HTTP interceptors are also evolving and can now be defined as functions.

We wrote a dedicated article about this:

👉 [HTTP in a standalone Angular application with provideHttpClient](/2022/11/09/angular-http-in-standalone-applications)

## Directive composition API

The other big feature of Angular&nbsp;v15 is the directive composition API.
We also wrote a dedicated article about this:

👉 [Directive Composition API in Angular](/2022/10/19/directive-composition-api-in-angular)

## NgOptimizedImage is stable

The `NgOptimizedImage` directive is now stable and can be used in production.
Introduced in Angular&nbsp;v14.2, it allows you to optimize images.
You can check out our explanation in our [blog post about v14.2](/2022/08/26/what-is-new-angular-14.2/).

Note that there is a change in the API: the `NgOptimizedImage` directive now has inputs named `ngSrc` and `ngSrcset` (whereas they were originally called `rawSrc` and `rawSrcset`).

{% raw %}
    <img [ngSrc]="imageUrl" />
{% endraw %}

Another input called `sizes` has also been added.
When you provide it a value, then the directive will automatically generate a responsive `srcset` for you.

{% raw %}
    <img [ngSrc]="imageUrl" sizes="100vw" />
{% endraw %}

It uses the default breakpoints `[16, 32, 48, 64, 96, 128, 256, 384, 640, 750, 828, 1080, 1200, 1920, 2048, 3840]` (and thus generates a big `srcset` with all these values) but they can be configured.

    providers: [
      {
        provide: IMAGE_CONFIG, useValue: { breakpoints: [1080, 1200] }
      },
    ]

This generates the following `srcset`: `https://example.com/image.png 1080w, https://example.com/image.png 1200w`.

This behavior can be disabled via the `disableOptimizedSrcset` input of the directive.

The directive also gained a new `fill` boolean input,
which removes the requirements for height and width on the image,
adds inline styles to cause the image to fill its containing element
and adds a default `sizes` value of `100vw` which will cause the image to have a responsive `srcset` automatically generated:

{% raw %}
    <img [ngSrc]="imageUrl" fill />
{% endraw %}

Last but not least, the directive triggers the generation of a `preload` link in the `head` of your document for priority images when used in SSR/Angular Universal.

## Dependency injection

The `providedIn: NgModule` syntax of the `@Injectable()` decorator is now deprecated.
You generally want to use `providedIn: 'root'`.
If providers should truly be scoped to a specific NgModule, use
`NgModule.providers` instead.
The `providedIn: 'any'` syntax is also deprecated.

## Router

The router now auto-unwraps default exports from lazy-loaded modules, routes or components.
You can replace:

    loadChildren: () => import('./admin/admin.module').then(m => m.AdminModule)
    // of for routes
    loadChildren: () => import('./admin/admin.routes').then(c => c.adminRoutes)
    // or for component
    loadComponent: () => import('./admin/admin.component').then(m => m.AdminComponent)

with the shorter:

    loadChildren: () => import('./admin/admin.module')
    // of for routes
    loadChildren: () => import('./admin/admin.routes')
    // or for component
    loadComponent: () => import('./admin/admin.component')

if `AdminModule`, `AdminComponent` and `adminRoutes` are default exports.

## Forms

Some utility functions have been added to the forms package:
`isFormControl`, `isFormGroup`, `isFormRecord`, `isFormArray`.

They are particularly useful when you want to write a custom validator,
as custom validators have `AbstractControl` in their signature,
but you often _know_ that the validator you write is for a specific `FormControl`, `FormGroup`, etc.

    positiveValues(control: AbstractControl) {
      if (!isFormArray(control)) {
        return null;
      }
      // check that every value is positive
      // we can use `control.controls` here \o/
      if (control.controls.some(c => c.value < 0)) {
        return { positiveValues: true };
      }
      return null;
    }

## Common

Angular v13 introduced the toke `DATE_PIPE_DEFAULT_TIMEZONE` to configure the default timezone of the `DatePipe` (see [our blog post about v13](/2021/11/03/what-is-new-angular-13.0)).

This token has been deprecated in v15 and replaced with `DATE_PIPE_DEFAULT_OPTIONS` which accepts an object with a `timezone` property _and_ a `dateFormat` property to specify the default date format that the pipe should use.

    providers: [{ provide: DATE_PIPE_DEFAULT_OPTIONS, useValue: { dateFormat: 'shortDate'} }]

## Devtools

The devtools now allow you to inspect the source code of a directive

## Angular CLI

As usual, you can check out our dedicated article about the new CLI version:

👉 [Angular CLI v15](/2022/11/16/angular-cli-15.0)


## Summary

This release is packed with features as you can see,
and the future is exciting with the standalone APIs.
The roadmap includes work on the CLI to be able to generate standalone applications without modules.
It also mentions some efforts on the server-side rendering story,
which is not the strong suit of Angular (compared to other mainstream frameworks)
and the possibility to use Angular without zone.js.

That's all for this release, stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
