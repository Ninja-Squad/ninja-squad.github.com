---
layout: post
title: Angular - How to use HttpClientModule?
author: cexbrayat
tags: ["Angular 2", "Angular", "Angular 4"]
description: "Angular 4.3 introduced the new HttpClientModule. How do we migrate our applications to use it?"
---

Angular 4.3 introduced a new module, `HttpClientModule`,
which is a complete rewrite of the existing `HttpModule`.

This article will show you how to easily migrate to this new module,
and why you should (spoiler: because it's way better&nbsp;🦄).

Here is a short video we made to show you what's new with this `HttpClientModule`.

<div class="video-wrapper">
    <iframe width="560" height="315" frameborder="0" allowfullscreen
    src="https://www.youtube.com/embed/jIgUrfXmrLM"></iframe>
</div>

The rest of the article focuses on what you have to do to migrate your apps.
It assumes an app generated with Angular CLI,
but if that's not your case, you'll still be able to follow,
minus some file names that might differ for you.

# Migrate your application

The first step is to remove the `@angular/http` package from your
`package.json` file.
Indeed the new `HttpClientModule` is in the `@angular/common/http` package,
and `@angular/common` should already be in your `package.json` file.

Save your file, and run NPM or Yarn to update the `node_modules`.
You should start to see compilation errors in your application,
as all the imports from `@angular/http` are now breaking.
That's good, because it tells you all the files you'll have to migrate.

The first obvious one is your `app.module.ts` file,
which contains your main NgModule.
Replace `HttpModule` with `HttpClientModule`
in your module's `imports` field,
and update the TypeScript import from:

    import { HttpModule } from '@angular/http';

to:

    import { HttpClientModule } from '@angular/common/http';

The second step is to replace every instance of the service `Http`
with the new service `HttpClient`.
This is will usually be the case in your services.
This is where using the new `HttpClient` will shine:
you don't have to manually extract the JSON anymore \o/!

So a service which was looking like that:

    import { Injectable } from '@angular/core';
    import { Http } from '@angular/http';
    import 'rxjs/add/operator/map';

    @Injectable()
    export class UserService {

      constructor(private http: Http) {}

      list() {
        return this.http.get('/api/users')
          .map(response => response.json())
      }
    }

can be rewritten as:

    import { Injectable } from '@angular/core';
    import { HttpClient } from '@angular/common/http';

    @Injectable()
    export class UserService {

      constructor(private http: HttpClient) {}

      list() {
        return this.http.get('/api/users');
      }
    }

Feels good to remove this code, doesn't it?

# Migrate your tests

Now let's move on to the unit tests.

Testing services with HTTP requests was really verbose with `HttpModule`...
You probably had something like:

    describe('UserService', () => {

      beforeEach(() => TestBed.configureTestingModule({
        imports: [HttpModule],
        providers: [
          MockBackend,
          BaseRequestOptions,
          {
            provide: Http,
            useFactory: (backend, defaultOptions) => new Http(backend, defaultOptions),
            deps: [MockBackend, BaseRequestOptions]
          },
          UserService
        ]
      }));

      it('should list the users', async(() => {
        const userService = TestBed.get(UserService);
        const mockBackend = TestBed.get(MockBackend);
        // fake response
        const users = [{ name: 'Cédric' }];
        const response = new Response(new ResponseOptions({ body: users }));
        // return the response if we have a connection to the MockBackend
        mockBackend.connections.subscribe((connection: MockConnection) => {
          expect(connection.request.url).toBe('/api/users');
          expect(connection.request.method).toBe(RequestMethod.Get);
          connection.mockRespond(response);
        });

        userService.list().subscribe(users => {
          expect(users.length).toBe(1);
        });
      }));
    });

You can now use the new testing APIs,
which are much, much nicer:

    describe('UserService', () => {

      beforeEach(() => TestBed.configureTestingModule({
        imports: [HttpClientTestingModule],
        providers: [UserService]
      }));

      it('should list the users', () => {
        const userService = TestBed.get(UserService);
        const http = TestBed.get(HttpTestingController);
        // fake response
        const users = [{ name: 'Cédric' }];

        userService.list().subscribe(users => {
          expect(users.length).toBe(1);
        });

        http.expectOne('/api/users').flush(users);
      });
    });

That should remove a lot of errors you have,
maybe all of them.

Maybe you were also adding headers or params to your requests.
The new `HttpClient` allows it too:

    const params = new HttpParams().set('page', '1');
    this.http.get('/api/users', { params });

    const headers = new HttpHeaders().set('Authorization', `Bearer ${token}`);
    this.http.get('/api/users', { headers });

In the example above, I set the JWT token needed in the `Authorization` header.
This is something you probably repeat a lot of times in your services,
as every request needs it.

The new module introduces a very interesting feature: the interceptors.
These interceptors are called for every request and response,
and allow to easily handle tasks like adding a header to every request,
or handling error in a generic away for example.

First create your interceptor:

    @Injectable()
    export class GithubAPIInterceptor implements HttpInterceptor {

      intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
        return next.handle(req);
      }

    }

Then add your custom logic,
for example to add an OAUTH token to every Github API request,
but not to the other requests:

    @Injectable()
    export class GithubAPIInterceptor implements HttpInterceptor {

      intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {

        // if it is a Github API request
        if (req.url.includes('api.github.com')) {
          // we need to add an OAUTH token as a header to access the Github API
          const clone = req.clone({ setHeaders: { 'Authorization': `token ${OAUTH_TOKEN}` } });
          return next.handle(clone);
        }
        // if it's not a Github API request, we just handle it to the next handler
        return next.handle(req);
      }

    }

If you want to learn more about this API and Angular in general,
you can check out our [ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](http://ninja-squad.com/training/angular)!
