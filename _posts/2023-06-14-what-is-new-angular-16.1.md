---
layout: post
title: What's new in Angular 16.1?
author: cexbrayat
tags: ["Angular 16", "Angular"]
description: "Angular 16.1 is out!"
---

Angular&nbsp;16.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/16.1.0">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This is a minor release with some nice features: let's dive in!

## TypeScript 5.1 support

Angular v16.1 now supports TypeScript 5.1. This means that you can use the latest version of TypeScript in your Angular applications. You can check out the [TypeScript 5.1 release notes](https://devblogs.microsoft.com/typescript/announcing-typescript-5-1/) to learn more about the new features.

## Transform input values

Angular v16.1 introduces a new `transform` option in the `@Input` decorator.
It allows transforming the value passed to the input before it is assigned to the property.
The `transform` option takes a function that takes the value as input and returns the transformed value.
As the most common use cases are to transform a string to a number or a boolean, Angular provides two built-in functions to do that: `numberAttribute` and `booleanAttribute` in `@angular/core`.

Here is an example of using `booleanAttribute`:

    @Input({ transform: booleanAttribute }) disabled = false;

This will transform the value passed to the input to a boolean so that the following code will work:

{% raw %}
    <my-component disabled></my-component>
    <my-component disabled="true"></my-component>
    <!-- Before, only the following was properly working -->
    <my-component [disabled]="true"></my-component>
{% endraw %}

The `numberAttribute` function works the same way but transforms the value to a number.

    @Input({ transform: numberAttribute }) value = 0;


It also allows to define a fallback value, in case the input is not a proper number (default is NaN):

    @Input({ transform: (value: unknown) => numberAttribute(value, 42) }) value = 0;

This can then be used like this:

{% raw %}
    <my-component value="42"></my-component>
    <my-component value="not a number"></my-component>
    <!-- Before, only the following was properly working -->
    <my-component [value]="42"></my-component>
{% endraw %}

## Fetch backend for the Angular HTTP client

The HTTP client has a new backend implementation based on the [Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API).

This is an experimental and opt-in feature, that you can enable with:

    provideHttpClient(withFetch());

It does not support the progress reports on uploads,
and of course, requires a browser that supports the Fetch API.
The fetch API is also experimental on Node but available without flags from Node 18 onwards.

This is mainly interesting for server-side rendering, as the XHR implementation is not supported natively in Node and requires a polyfill (which has some issues).

## Angular CLI

The CLI now has a `--force-esbuild` option that allows forcing the usage of esbuild for `ng serve`.
It allows trying the esbuild implementation without switching the builder in `angular.json` (and keeping the Webpack implementation for the `ng build` command).

The esbuild builder has been improved. It now pre-bundles the dependencies using the underlying [Vite mechanism](https://vitejs.dev/guide/dep-pre-bundling.html), uses some persistent cache for the TypeScript compilation and Vite pre-bundling, and shows the estimated transfer sizes of the built assets as the Webpack builder does.

## Summary

That's all for this release, stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
