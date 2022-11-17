---
layout: post
title: HTTP in a standalone Angular application with provideHttpClient
author: cexbrayat
tags: ["Angular"]
description: "Angular now supports building applications without modules. But how to use HTTP in a standalone application?"
---

Angular&nbsp;v14 introduced the concept of standalone components/directives/pipes and allows writing applications without modules.

How do you use and test HTTP in a standalone application?

## provideHttpClient

For a long time, the `HttpClient` was provided by the `HttpClientModule` that you imported into your application module.

    @NgModule({
      imports: [BrowserModule, HttpClientModule],
      declarations: [AppComponent],
      bootstrap: [AppComponent]
    })
    export class AppModule {}

When the standalone APIs were introduced in Angular&nbsp;v14,
it opened the door to writing applications without modules.

The Angular team introduced an `importProvidersFrom()` function, that you could use in the `bootstrapApplication` function 
to import providers from an existing module, as most of the ecosystem was structured around modules.

So to provide the `HttpClient` in a standalone application, you could do:

    import { bootstrapApplication, importProvidersFrom } from '@angular/core';
    import { HttpClientModule } from '@angular/common/http';

    bootstrapApplication(AppComponent, {
      providers: [importProvidersFrom(HttpClientModule)]
    });

But since Angular&nbsp;v15, this can be replaced by `provideHttpClient()`,
a new function that does the same thing as `importProvidersFrom(HttpClientModule)`:

    import { bootstrapApplication } from '@angular/core';
    import { provideHttpClient } from '@angular/common/http';
    import { AppComponent } from './app.component';
    
    bootstrapApplication(AppComponent, {
      providers: [provideHttpClient()]
    });

`HttpClient` is then available for injection in your application.

`provideHttpClient()` is more "tree-shakable" than importing `HttpClientModule`,
as you can enable the features you want by giving it some parameters.

For example, if you want JSONP support, you can write:

    import { bootstrapApplication } from '@angular/core';
    import { provideHttpClient, withJsonpSupport } from '@angular/common/http';
    import { AppComponent } from './app.component';
    
    bootstrapApplication(AppComponent, {
      providers: [provideHttpClient(withJsonpSupport())]
    });

In the same vein, Angular provides XSRF protection (cross-site request forgery) out-of-the-box, by adding a custom header containing a random token provided by the server in a cookie (which is a common technic to mitigate these attacks).

As you probably want to keep this security, it's enabled by default in `provideHttpClient()`, but you can configure it with `withXsrfConfiguration()` 
to specify a custom header name and cookie name:

    import { bootstrapApplication } from '@angular/core';
    import { provideHttpClient, withXsrfConfiguration } from '@angular/common/http';
    import { AppComponent } from './app.component';
    
    bootstrapApplication(AppComponent, {
      providers: [provideHttpClient(withXsrfConfiguration({
        cookieName: 'TOKEN', // default is 'XSRF-TOKEN'
        headerName: 'X-TOKEN' // default is 'X-XSRF-TOKEN'
      }))]
    });

or you can disable it completely with `withNoXsrfProtection()`:

    import { bootstrapApplication } from '@angular/core';
    import { provideHttpClient, withNoXsrfProtection } from '@angular/common/http';
    import { AppComponent } from './app.component';
    
    bootstrapApplication(AppComponent, {
      providers: [provideHttpClient(withNoXsrfProtection())]
    });

There is another feature that you can enable,
but first I need to introduce the concept of functional interceptors.

## Functional interceptors

In Angular, interceptors are classes that implement the `HttpInterceptor` interface.
They are used to intercept HTTP requests and responses and can be used to add headers, log requests, etc.

    @Injectable()
    export class LoggerInterceptor implements HttpInterceptor {
      intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
        console.log(`Request is on its way to ${req.url}`);
        return next.handle(req);
      }
    }

Since Angular&nbsp;v15, you can also use functional interceptors.
They are functions that take an `HttpRequest` and a `HttpHandlerFn` as parameters:

    export function loggerInterceptor(req: HttpRequest<unknown>, next: HttpHandlerFn): Observable<HttpEvent<unknown>> {
      console.log(`Request is on its way to ${req.url}`);
      return next.handle(req);
    }

As this is a function, you can't use the usual dependency injection via constructor parameters to inject services in it.
But you can use the `inject()` function:

    export function loggerInterceptor(req: HttpRequest<unknown>, next: HttpHandlerFn): Observable<HttpEvent<unknown>> {
      const logger = inject(Logger);
      logger.log(`Request is on its way to ${req.url}`);
      return next.handle(req);
    }

Functional interceptors have to be registered via `withInterceptors()`:

    import { bootstrapApplication } from '@angular/core';
    import { provideHttpClient, withInterceptors } from '@angular/common/http';
    import { AppComponent } from './app.component';
    
    bootstrapApplication(AppComponent, {
      providers: [provideHttpClient(withInterceptors([loggerInterceptor()]))]
    });

Note that you can also register class-based interceptors via `withInterceptorsFromDi()`:

    import { bootstrapApplication } from '@angular/core';
    import { provideHttpClient, withInterceptorsFromDi } from '@angular/common/http';
    import { AppComponent } from './app.component';
    
    bootstrapApplication(AppComponent, {
      providers: [
        { provide: HTTP_INTERCEPTORS, useClass: LoggerInterceptor, multi: true },
        provideHttpClient(withInterceptorsFromDi())
      ]
    });

But this API may be phased out in the future,
so it's better to use `withInterceptors()` and functional interceptors.

## Interceptors and lazy-loading

A long-standing issue with Angular was that interceptors are not inherited in lazy-loaded modules (see [this issue](https://github.com/angular/angular/issues/20575) for more context).

For example, let's say we have a lazy-loaded part of the application for the administration of our website:

    {
      path: 'admin',
      loadChildren: () => import('./admin/admin.routes').then(c => c.ADMIN_ROUTES)
    },

If it provides the `HttpClient` as well (which is not a good idea to be honest, but let's say that's the case for this example):

    export const ADMIN_ROUTES: Routes = [
      {
        path: '',
        pathMatch: 'prefix',
        providers: [provideHttpClient()], // <--
        children: [{ path: '', component: AdminComponent }]
      }
    ];

then all requests made in the `AdminComponent` will _not_ be intercepted by the interceptors registered in our application.

If we want them to go through our `loggerInterceptor`,
we can use `withRequestsMadeViaParent()`: 

    export const ADMIN_ROUTES: Routes = [
      {
        path: '',
        pathMatch: 'prefix',
        providers: [provideHttpClient(withRequestsMadeViaParent(), withInterceptors([adminInterceptor()]))],
        children: [{ path: '', component: AdminComponent }]
      }
    ];

Then the requests made in the `AdminComponent` will then go through the `adminInterceptor` and are then handed off to the parent `HttpClient`, and will be intercepted by the `loggerInterceptor` registered at the application bootstrap.

## Testing HTTP

When using `HttpClientModule` in your application,
you can import the `HttpClientTestingModule` in your tests to mock HTTP requests.

But if you use `provideHttpClient()` instead,
you can use `provideHttpClientTesting()` to mock HTTP requests in your tests (in addition to `provideHttpClient()`):

    import { TestBed } from '@angular/core/testing';
    import { provideHttpClientTesting } from '@angular/common/http/testing';
    
    beforeEach(() =>
      TestBed.configureTestingModule({
        providers: [provideHttpClient(), provideHttpClientTesting()]
      })
    );

You can then inject `HttpController` to mock HTTP requests as you usually do.

## Summary

The `provideHttpClient()` API is the way to go if you work with an Angular application and don't want to use `NgModule`.
When migrating an existing application to the standalone APIs,
you will need to replace the usage of `HttpClientModule` with `provideHttpClient()` and the usage of `HttpClientTestingModule` with `provideHttpClientTesting()` in your tests.
You can also gradually migrate your class-based interceptors to functional interceptors.

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
