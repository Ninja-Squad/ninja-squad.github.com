---
layout: post
title: A guide to Standalone Components in Angular
author: cexbrayat
tags: ["Angular 14", "Angular"]
description: "Angular 14 introduces optional NgModules with the new standalone components!"
---

Angular v14 introduces one major (experimental) feature,
after [months of discussion](https://github.com/angular/angular/discussions/45554):
the possibility to declare standalone components/pipes/directives,
and to get rid of `NgModule` in your application if you want to 😍.

In this article, we'll see:

- how to declare standalone entities,
- how to use them in existing applications
- how to get rid of `NgModule` if you want to
- how the router has changed to leverage this new feature
- and more nerdy details!

_Disclaimer:_ this blog post is based on early releases of Angular v14,
and some details may change based on the feedback the Angular team gets.
That's why, for once, we write a blog post on a feature before its final release:
this is a great opportunity to give it a try and gather feedback!

## Standalone components

Components, directives, and pipes can now be declared as `standalone`.

    @Component({
      selector: 'ns-image',
      standalone: true,
      templateUrl: './image.component.html'
    })
    export class ImageComponent {
    }

When that's the case,
the component/directive/pipe can't be declared in an `NgModule`.
But it can be directly imported into another standalone component.
For example, if my `ImageComponent` above is used in the template of a standalone `UserComponent`,
you have to import `ImageComponent` in `UserComponent`:

    @Component({
      selector: 'ns-user',
      standalone: true,
      imports: [ImageComponent],
      templateUrl: './user.component.html' 
      // uses `<ns-image>`
    })
    export class UserComponent {
    }

This is true for every component/directive/pipe you use in a standalone component.
So if the template of `UserComponent` also uses a standalone `FromNowPipe` and a standalone `BorderDirective`, then they have to be declared into the imports of the component:

    @Component({
      selector: 'ns-user',
      standalone: true,
      imports: [ImageComponent, FromNowPipe, BorderDirective],
      templateUrl: './user.component.html' 
      // uses `<ns-image>`, `fromNow` and `nsBorder`
    })
    export class UserComponent {
    }

This is also true for components, directives, and pipes offered by Angular itself.
If you want to use `ngIf` in a template, the directive has to be declared.
But `ngIf` is not a standalone directive: it is offered via the `CommonModule`.
That's why `imports` lets you import any `NgModule` used as well:

    @Component({
      selector: 'ns-user',
      standalone: true,
      imports: [CommonModule, RouterModule, ImageComponent, FromNowPipe, BorderDirective],
      templateUrl: './user.component.html' 
      // uses `*ngIf`, `routerLink`, `<ns-image>`, `fromNow` and `nsBorder`
    })
    export class UserComponent {
    }

You can of course import your own existing modules or modules offered by third-party libraries.
If you use the `DragDropModule` from Angular Material for example:

    @Component({
      selector: 'ns-user',
      standalone: true,
      imports: [CommonModule, RouterModule, DragDropModule, ImageComponent],
      templateUrl: './user.component.html' 
      // uses `*ngIf`, `routerLink`, `cdkDrag`, `<ns-image>`
    })
    export class UserComponent {
    }

A standalone component can also define `schemas` if you want to ignore some custom elements in its template with `CUSTOM_ELEMENTS_SCHEMA` or even ignore all errors with `NO_ERRORS_SCHEMA`.

## Usage in existing applications

This is all great, but how can we use our new standalone `UserComponent`
in an existing application that has no standalone components?

Maybe you guessed it:
you can import a standalone component like `UserComponent`
in the `imports` of an `NgModule`!

    @NgModule({
      declarations: [AppComponent],
      imports: [BrowserModule, HttpClientModule, UserComponent], // <---
      bootstrap: [AppComponent]
    })
    export class AppModule {}

This is probably a sound strategy to start using
standalone components, pipes, and directives in existing applications.
Angular applications tend to have a `SharedModule` with commonly used
components, directives, and pipes.
You can take these and convert them to a standalone version.
It's usually straightforward, as they have few dependencies.
And then, instead of importing the full `SharedModule` in 
every `NgModule`, you can import just what you need!

## CLI support

The Angular CLI team added a new flag `--standalone` to `ng generate` in v14,
allowing to create standalone versions of components, pipes, and directives:

    ng g component --standalone user

The component skeleton then has the `standalone: true` option,
and the `imports` are already populated with `CommonModule`
(that will be used in pretty much all components anyway):

    @Component({
      selector: 'pr-user',
      standalone: true,
      imports: [CommonModule],
      templateUrl: './user.component.html',
      styleUrls: ['./user.component.css']
    })
    export class UserComponent implements OnInit {

The generated test is also slightly different.
A standalone component is declared in the `imports` option 
of `TestBed.configureTestingModule()` instead of in the `declarations` option.

If you want to generate all components with the `--standalone` flag,
you can set the option directly in `angular.json`:

    "schematics": {
      "@schematics/angular:component": {
        "standalone": true
      }
    }

You can of course do the same for the `directive` and `pipe` schematics.

## Application bootstrap

If you want to, you can go one step further and write an application
with only standalone entities, and get rid of all `NgModule`s.
In that case, we need to figure out a few details.

First, if we don't have an Angular module, how can we start the application?
A typical `main.ts` contains a call to `platformBrowserDynamic().bootstrapModule(AppModule)` which bootstraps the main Angular module of the application.

In a standalone world, we don't want to use `NgModule`,
so we don't have an `AppModule`.

Angular now offers a new function called `bootstrapApplication()` in `@angular/platform-browser`.
The function expects the root standalone component as a parameter:

    bootstrapApplication(AppComponent);

This creates an application and starts it.

For SSR, you can use the new `renderApplication` function,
which renders the application as a string:

    const output: string = await renderApplication(AppComponent, { appId: 'app' });

## Optional NgModules

`NgModule` is a weird concept in Angular if you think about it.
They fulfill several roles at once.
We use them to declare what is usable in the templates of the components,
but also to configure the available providers.
We can export entities, to make them available in other modules.
Modules are eagerly executed,
which means you can add code in their constructors if you want to run something on their initialization.
They are also necessary if you want to lazy-load parts of your application.

If modules are now optional, how can we do all these tasks?

## Providers

`NgModule`s allow defining providers available for components in the module.
For example, if you want to use `HttpClient`,
you add `HttpClientModule` to the `imports` of your main module.

In an application with no module, you can achieve the same by
using the second parameters of `bootstrapApplication()`,
which allows declaring `providers`:

    bootstrapApplication(AppComponent, { providers: [] });

In the long run,
Angular will probably offer a function returning the HTTP providers. 
For now, to bridge the gap with modules that expose providers,
we can use `importProvidersFrom(module)`:

    bootstrapApplication(AppComponent, { 
      providers: [importProvidersFrom(HttpClientModule)]
    });

You can also use `importProvidersFrom` to configure the router:

    bootstrapApplication(AppComponent, { 
      providers: [importProvidersFrom(RouterModule.forRoot([/*...*/]))]
    });

Note that the `BrowserModule` providers are automatically included
when starting an application with `bootstrapApplication()`.

It's also worth noting that you _can't_ use `importProvidersFrom`
in component providers: it's only usable in `bootstrapApplication()`.
`bootstrapApplication()` is now responsible for the Dependency Injection work,
and that's where providers must be declared.

Note: since Angular&nbsp;v15, it's now possible to use `provideRouter()`
and `provideHttpClient()` (see our blog post about [Angular HTTP in a standalone application](/2022/11/09/angular-http-in-standalone-applications/)).

## Lazy loading routes

The lazy-loading story in Angular has always revolved around `NgModule`.
Let's say you wanted to lazy-load an `AdminComponent`.
You had to write an `NgModule` like the following:

    @NgModule({
      declarations: [AdminComponent],
      imports: [
        CommonModule, 
        RouterModule.forChild([{ path: '', component: AdminComponent }])
      ],
    })
    export class AdminModule {}

and then load the module with the router function `loadChildren`:

    { 
      path: 'admin',
      loadChildren: () => import('./admin/admin.module').then(m => m.AdminModule)
    }

You can now get rid of `AdminModule` if `AdminComponent` is standalone,
and directly lazy-load the component with `loadComponent`:

    { 
      path: 'admin',
      loadComponent: () => import('./admin/admin.component').then(m => m.AdminComponent)
    }

This is a really nice addition!
All the lazy-loaded components must be standalone of course.
It's worth noting that this feature exists in all other mainstream frameworks,
and Angular was lacking a bit on this.

We can also lazy-load several routes at once,
by directly loading the routes config with `loadChildren`:

    { 
      path: 'admin',
      loadChildren: () => import('./admin/admin.routes').then(c => c.adminRoutes)
    }

We now have a nice symmetry between `children`/`loadChildren`
and `component`/`loadComponent`!

But `NgModule`s also allow to define providers for a lazy-loaded module:
the providers are then only available in the components
of the lazy-loaded module.
To achieve the same thing, you can now declare providers directly on a route,
and the providers will be available only for this route and its children:

    { 
      path: 'admin',
      providers: [AdminService],
      loadComponent: () => import('./admin/admin.component').then(c => c.AdminComponent)
    }

This works with all types of routes 
(with `component`, `loadComponent`, `children`, `loadChildren` with routes or `NgModule`).
In my example above, the component is lazy-loaded, but the service is not.
If you want to lazy-load the service as well, you can use:

    { 
      path: 'admin',
      loadChildren: () => import('./admin/admin.routes').then(c => c.adminRoutes)
    }

and define the `providers` in `adminRoutes`:

    export const adminRoutes: Routes = [
      { 
        path: '',
        pathMatch: 'prefix',
        providers: [AdminService], // <--
        children: [
          { path: '', component: AdminComponent }
        ]
      }
    ];

## Initialization

An `NgModule` can also be used to run some initialization logic,
as they are eagerly executed:

    @NgModule({ /*...*/ })
    export class AppModule {
      constructor(currentUserService: CurrentUserService) {
        currentUserService.init();
      }
    }

To achieve the same without a module,
we can now use a new multi-token `ENVIRONMENT_INITIALIZER`.
All the code registered with this token will be executed
during the application initialization.

    bootstrapApplication(AppComponent, {
      providers: [
        {
          provide: ENVIRONMENT_INITIALIZER,
          multi: true,
          useValue: () => inject(CurrentUserService).init()
        }
      ]
    });

Note that `importProvidersFrom(SomeModule)` is smart enough to automatically 
register the initialization logic of `SomeModule` in `ENVIRONMENT_INITIALIZER`.

## Angular compiler and Vite

On a low level, `NgModule`s are the smallest unit
that the compiler can re-compile when running `ng serve`.
Indeed, if you update the selector of a component for example,
then the Angular compiler has to check all the templates of the module that
contains this component to see if something changed,
and also all the modules that import that module.
Right now, the Angular compiler is tightly
coupled with the TypeScript compiler
and does a lot of bookkeeping to only recompile what's necessary.
In an application with no `NgModule`s,
the compiler has a more straightforward task:
it will for example only recompile the components that directly import the modified component.

This can be good news for the future of Angular tooling.
The frontend world has been taken by storm by [Vite](https://vitejs.dev/).
We talked about Vite, and the differences with Webpack,
in [this blog post](https://blog.ninja-squad.com/2022/02/23/getting-started-with-vite-and-vue/).

TL;DR: Vite only re-compiles the files needed to display a page
and skips the TypeScript compilation to only do a simple transpilation,
often in parallel.

This works great for Vue, React, or Svelte, but not so great for Angular,
where a lot more needs to be recompiled, and where TypeScript is needed.
Standalone components are a nice step in this direction,
and may allow a future Angular CLI with Vite instead of Webpack
and way faster re-builds.

## Caveats

To be honest, the standalone API feels great.
We migrated a few applications, and this is really nice to use,
and it feels good to get rid of `NgModule`s!

A few pain points though.

1. There are no "global imports": you need to import a component/pipe/directive
every time you use it.
`ngIf`, `ngFor`, and friends are available in every standalone component generated
by the CLI, as the skeleton includes the import of `CommonModule`.
But `routerLink` for example is not:
you need to import `RouterModule` if you need it.
Other frameworks, like Vue for example,
allow registering some components globally,
to avoid importing them over and over.
That's not the case in Angular.

1. Sometimes you forget to add an import, and your template doesn't work,
with no compilation error.
For example, adding a link with `[routerLink]="['/']` does not compile,
but `routerLink="/"` does compile (and doesn't work).
I feel that these kinds of errors happen more often than they did
with `NgModule`. 
IDEs will probably help us here, and I suppose typing `routerLink` in a template
will result in an automatic addition of `RouterModule` in the component's imports
in VS Code/Webstorm/whatever is a few months.

1. You can't bootstrap multiple components at once 
with the new `bootstrapApplication()` function,
whereas it was possible with the NgModule-based bootstrap.

1. `TestBed` works with standalone components,
but will probably include more specific APIs to simplify tests in the future.
Note that it is already easier to test standalone components than classic components,
as you don't have to repeat in `configureTestingModule` all the dependencies the component needs.

## Summary

Six years after the initial release,
we can finally get rid of `NgModule` in Angular if we want to.
Their addition to Angular was a bit rushed: 
they were introduced in Angular v2.0.0-rc.5 two months (!!) before the stable release,
mainly to help the ecosystem build libraries.
As often in our field, the rushed design resulted in an entity that mixed several concerns,
with some concepts quite hard to understand for beginners.

The new "mental model" is easy to grasp:
providers are declared on an application level
and components just have to import what they need in their templates.
It will also probably be easier for newcomers to understand how Angular works.

These standalone APIs are trying to make things clearer,
and it looks like they did ♥️.

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
