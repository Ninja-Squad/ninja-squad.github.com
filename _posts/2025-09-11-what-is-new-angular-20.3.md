---
layout: post
title: What's new in Angular 20.3?
author: cexbrayat
tags: ["Angular 20", "Angular"]
description: "Angular 20.3 is out!"
---

Angular&nbsp;20.3.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/20.3.0">
    <img class="rounded img-fluid" src="/assets/images/angular_gradient.png" alt="Angular logo" />
  </a>
</p>

Angular v20 will be one of the very few versions to have a third minor release.
The main reason is a security patch for a vulnerability in the `platform-server`/`ssr` packages. The fix is a breaking change which was released across all active LTS versions.

## Vulnerability fix in platform-server and ssr

The vulnerability is described on the Angular repo: [CVE-2025-59052](https://github.com/angular/angular/security/advisories/GHSA-68x2-mx4q-78m7).

As explained there, an attacker could potentially send multiple requests and inspect responses for leaked information from other users' requests in SSR applications.

The cause is that the platform injector was shared globally during SSR.
When multiple requests were processed concurrently,
they could share or overwrite this global state,
causing one request to respond with data meant for a different request
(which could lead to bugs in addition to being a security vulnerability).

Three APIs received breaking changes to address this issue:
`bootstrapApplication`, `getPlatform`, and `destroyPlatform`.

The new approach introduces a `BootstrapContext`
that is passed to the `bootstrapApplication` function.
This context provides a platform reference that is scoped to the individual request,
ensuring that each server-side render has an isolated platform injector.

Instead of:

```typescript
const bootstrap = () => 
  bootstrapApplication(AppComponent, config);
```

you now need to do:

```typescript
const bootstrap = (context: BootstrapContext) =>
  bootstrapApplication(AppComponent, config, context);
```

`getPlatform` and `destroyPlatform` now returns `null` and are no-op on the server.

A schematic has been included in the release to help you migrate your code,
so you just have to run `ng update @angular/core`.

## Extended diagnostics

The Angular compiler already checks that signals are properly invoked in interpolations and bindings.
The extended diagnostics in v20.3 now also check them in `@if` and `@switch`:

```
✘ [ERROR] NG8109: user is a function and should be invoked: user() [plugin angular-compiler]

    src/app/home/home.html:10:8:
      10 │   @if (!user) {
```

## Angular CLI

The CLI was also released in version 20.3.0,
with the same security fix as above for `@angular/ssr`.

The only notable change that I noticed otherwise is that the variable names
are now kept when serving the application in dev mode.
This means the error messages will no longer contain weird underscores like `_App` or `_UserService`, which is a nice improvement for debugging.

That's all for this small release.
The next one will be v21, and will include experimental signal forms.
We have a dedicated article about it coming soon, so stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
