---
layout: post
title: What's new in Angular 19.1?
author: cexbrayat
tags: ["Angular 19", "Angular"]
description: "Angular 19.1 is out!"
---

Angular&nbsp;19.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/19.1.0">
    <img class="rounded img-fluid" style="max-width: 60%" src="/assets/images/angular_gradient.png" alt="Angular logo" />
  </a>
</p>

This is a minor release with some nice features: let's dive in!

## TypeScript 5.7 support

Angular v19.1 now supports TypeScript 5.7.
This means that you can use the latest version of TypeScript in your Angular applications.
You can check out the [TypeScript 5.7 release notes](https://devblogs.microsoft.com/typescript/announcing-typescript-5-7/)
to learn more about the new features.

## Automatic removal of unused standalone imports

Since [Angular v19.0](/2024/11/19/what-is-new-angular-19.0/),
there is an extended diagnostic that warns you
if you import a standalone component, or pipe, or directive,
but don't actually use it (making this import unnecessary).
Angular v19.1 goes further:
it provides a schematic that removes all those unnecessary imports for you.
You simply need to execute `ng generate @angular/core:cleanup-unused-imports`
to clean all your imports.

## NgComponentOutlet

You know it's not a big release when one of the most interesting feature
is a new property on a not-very-often-used directive.
But here it is: the `ngComponentOutlet` directive now has a `componentInstance` property,
allowing to access the instance of the component created by the directive.
The directive is now also exposed as `ngComponentOutlet`, allowing to reference it in templates:

```html
<ng-container
  [ngComponentOutlet]="component"
  #myDynamicComponent="ngComponentOutlet"
/>
```

## Devtools

The devtools now have a router graph to view the routes that are loaded in the application.

Some internal work has also been done to add a "tracing" service,
that the framework calls to trace what triggers change detection.
This could be leveraged by the devtools to provide more information
about change detection in the future.

Another addition in v19.1 is the ability to inspect the signal graph of the application.
Currently, it is a private debug function called `ɵgetSignalGraph`
that you can use via `window.ng.ɵgetSignalGraph()` in the console if you enable the debug tools.
We can safely bet that this will be exposed in the devtools in the future
with a nice graph showing the signals and their dependencies.

## Angular CLI

### Templates HMR

As we hinted in our [v19 blog post](/2024/11/19/what-is-new-angular-19.0/),
the CLI now has HMR for templates enabled by default!

v19 enabled HMR for styles, and now it's also enabled for templates in v19.1,
both for inline and external templates.
As for the styles, this required some internal changes in the compiler.
As it is still a fairly new feature,
you may have to manually refresh the page sometimes
or restart your server.
The HMR feature itself can bail out and do a full rebuild,
for example, if too many files were modified (currently 32).
It can be disabled with `--hmr=false` or `--live-reload=false` in the `serve` command,
or by using `NG_HMR_TEMPLATES=0`.

### i18n subPath

It is now easier to specify a customized URL segment for internationalized applications,
like `/fr` for French or `/es` for Spanish.
It was already possible to use `baseHref` in the `i18n` configuration,
but it was still necessary to manually put the generated files in the proper sub-directory yourself.
The `baseHref` option is now deprecated in favor of `subPath`,
which acts as a base href and the name of the folder where the localized version is built:

```json5
"locales": {
  "fr": {
    "subPath": "fr", // can be omitted if it's the same as the locale
    "translation": "src/i18n/messages.fr.json"
  },
  "es": {
    "subPath": "es",
    "translation": "src/i18n/messages.es.json"
  }
```

The generated files will be in `dist/my-app/browser/fr` and `dist/my-app/browser/es`.

### SSR redirection to preferred locale

If your application supports several languages,
the server will now redirect your users to their preferred locales,
based on their browser settings.
This leverages the `Accept-Language` header to determine the preferred locales
(ranked by their quality value, for example, `en-US;q=0.8,fr-FR;q=0.9`)
and redirect the user to the corresponding URL segment based on the supported locales.
It tries to find the exact locales first, then the locales without the region,
then falls back to first supported locale if none of the previous ones are supported.
This works out of the box without needing to configure anything.

### SSR preload lazy-loaded routes

The CLI now preloads lazy-loaded routes during server-side rendering,
by adding `modulepreload` links in the generated HTML.
This is limited to 10 modules
and does not work when the chunk optimization option is enabled
(see our blog post about [Angular v18.1](/2024/07/10/what-is-new-angular-18.1/)).

### ng-packagr builder

The `ng-packagr` package is now available as a builder in the CLI (`@angular/build:ng-packagr`)
and can now be used to build libraries.
It is used by default when you create a library with `ng generate library`
and removes the need to have the `@angular-devkit/build-angular` package installed
as you can see in our [angular-cli-library-diff Github repo](https://github.com/cexbrayat/angular-cli-library-diff/compare/19.1.0-next.2...19.1.0-rc.0)
that tracks changes in a generated library.

Speaking about repositories helping to track differences between CLI versions,
we created a new one for the CLI when generating an application with the `--ssr` option:
[angular-cli-ssr-diff](https://github.com/cexbrayat/angular-cli-ssr-diff) 🚀
(in addition to the one for [libraries](https://github.com/cexbrayat/angular-cli-library-diff)
and the most popular one for [basic CLI applications](https://github.com/cexbrayat/angular-cli-diff)).

### Warning about bad localize import

The CLI will now warn you if you import `@angular/localize/init` directly in your code:

```bash
Direct import of '@angular/localize/init' detected. This may lead to undefined behavior.
```

The proper way to add localize is to add it to your polyfills in `angular.json`
(as `ng add @angular/localize` does).

## Summary

That's all for this release, stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
