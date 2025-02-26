---
layout: post
title: A guide to HTTP calls in Angular using httpResource()
author: cexbrayat
tags: ["Angular 19", "Angular"]
description: "Angular 19.2 introduces a new function called `httpResource()`. Let's dive in!"
---

Angular v19.2 introduced a dedicated (and experimental) function
to create resources that use HTTP requests: `httpResource()` in the `@angular/common/http package`.

This function uses `HttpClient` under the hood,
allowing us to use our usual interceptors, testing utilities, etc.

The most basic usage is to call this function with the URL from which you want to fetch data:

```ts
readonly usersResource = httpResource<Array<UserModel>>('/users');
```

`httpResource()` returns an `HttpResourceRef` with the same properties as `ResourceRef`,
the type returned by `resource()`, as it is built on top of it
(check out our [blog post about Angular v19.0](/2024/11/19/what-is-new-angular-19.0/) to learn more about `resource()`):

- `value` is a signal that contains the deserialized JSON response body;
- `status` is a signal that contains the resource status (idle, loading, error, resolved, etc.);
- `error` is a signal that contains the error if the request fails;
- `isLoading` is a signal that indicates if the resource is loading;
- `reload()` is a method that allows you to reload the resource;
- `update()` and `set()` are methods that allow you to change the value of the resource;
- `asReadonly()` is a method that allows you to get a read-only version of the resource;
- `hasValue()` is a method that allows you to know if the resource has a value;
- `destroy()` is a method that allows you to stop the resource.

It also contains a few more properties specific to HTTP resources:

- `statusCode` is a signal that contains the status code of the response as a `number`;
- `headers` is a signal that contains the headers of the response as `HttpHeaders`;
- `progress` is a signal that contains the download progress of the response as a `HttpProgressEvent`.

It is also possible to define a reactive resource 
by using a function that returns the request as a parameter.
If the function uses a signal,
the resource will automatically reload when the signal changes:

```ts
readonly sortOrder = signal<'asc' | 'desc'>('asc');
readonly sortedUsersResource = httpResource<Array<UserModel>>(() => `/users?sort=${this.sortOrder()}`);
```

When using a reactive request,
the resource will automatically reload when a signal used in the request changes.
If you want to skip the reload,
you can return `undefined` from the request function (as for `resource()`).

If you need more fine-grained control over the request,
you can also pass an `HttpResourceRequest` object to the `httpResource(`) function,
or a function that returns an `HttpResourceRequest` object 
in case you want to make the request reactive.

This object must have a `url` property
and can have other options like `method` (`GET` by default), `params`, `headers`, `reportProgress`, etc.
If you want to make the request reactive,
you can use signals in the `url`, `params` or `headers` properties.

The above example would then look like:

```ts
readonly sortedUsersResource = httpResource<Array<UserModel>>(() => ({
  url: `/users`,
  params: { sort: this.sortOrder() },
  headers: new HttpHeaders({ 'X-Custom-Header': this.customHeader() })
}));
```

You can of course send a body with the request,
for example for a POST/PUT request,
using the `body` property of the request object.
Note that, as we create the resource in a method,
we have to pass the `injector` in the options as a second argument:

```ts
injector = inject(Injector);
filterUserResource: HttpResourceRef<UserModel | undefined> | undefined;

filterUser() {
  this.filterUserResource = httpResource<UserModel>(
    {
      url: `/users`,
      method: 'POST',
      body: {
        name: 'JB'
      }
    },
    {
      injector: this.injector
    }
  );
```

Note that we will probably keep using the `HttpClient` for mutations.

In these options, you can also define:

- `defaultValue`, a default value of the resource, to use when idle, loading, or in error;
- an `equal` function that defines the equality of two values;
- a `map` function that allows you to transform the response before setting it in the resource.

It is also possible to request something else than JSON,
by using the `httpResource.text()`, `httpResource.blob()` or `httpResource.arrayBuffer()` functions.

Some of you may get a feeling of déjà vu with all this,
as it’s quite similar to the [TanStack Query library](https://tanstack.com/query/latest),
I must insist that this is experimental and will probably evolve in the future.
Let’s see what the RFC process will bring us!

Update: the RFCs are out for 
[Resource Architecture](https://github.com/angular/angular/discussions/60120)
and [Resource APIS](https://github.com/angular/angular/discussions/60121).

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
