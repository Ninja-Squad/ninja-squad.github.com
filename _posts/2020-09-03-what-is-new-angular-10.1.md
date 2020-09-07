---
layout: post
title: What's new in Angular 10.1?
author: cexbrayat
tags: ["Angular 10", "Angular"]
description: "Angular 10.1 is out!"
---

Angular&nbsp;10.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#1010-2020-09-02">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

Tha Angular team also publicly released [a roadmap](https://blog.angular.io/a-roadmap-for-angular-1b4fa996a771) if you want to see what we can expect in the future.

This is a small release in terms of features,
let's see what it brings us.

## TypeScript 4.0

This new release supports TypeScript 4.0.
Even if 4.0 sounds like a big deal, TypeScript does not follow semver, so this is not really an exceptional release.
There are still a few interesting features though.
You can check the [official blog post](https://devblogs.microsoft.com/typescript/announcing-typescript-4-0/) to learn about variadic tuple types for example (yes, it's a thing 🤓).

## i18n

`@angular/localize` is improving and now offers a tool to extract messages.
The awesome news is that it can extract messages from your TypeScript code 🎉
If you want to learn more about that,
check out our article about the [CLI v10.1](/2020/09/03/angular-cli-10.1/).

The [PeerTube](https://joinpeertube.org/) team builds their app in 20 languages,
and started to use localize now that it supports this feature:
their build time dropped from [80 minutes to 12 minutes](https://twitter.com/chocobozzz/status/1295263873730334720) 😍.

## Compiler

The compiler has a new strictness option called `strictInputAccessModifiers`.
If enabled, it reports an error when an input binding attempts to assign to a restricted field (readonly, private, or protected) on a directive or component.

Note that this is not enabled by default, even if you have enabled `strictTemplates`, as this would be a breaking change.
It will be enabled by default in the future,
but you can already use it by manually adding it to your application.

The compiler also received a few commits to improve the compilation performances
(by not generating type checking code when it's not necessary).

## Forms

The forms error messages (that we all see from time to time when developing 😅) are now removed from the production builds.
That was not the case until now, and these messages, designed to guide the developers, were included in the final bundles.
This reduces the forms bundle by ~20%,
so our applications should be a bit lighter 🎉.

## Lightweight injection token

This is a new feature, but this is really only interesting for library developers.
When you develop a library that offers components or services that might not be used by all client applications, you may think that the tree-shaking process of the build will remove these components and services if not used.
But it's not always the case, because of how Angular stores the injection tokens.
That's where lightweight tokens can be useful.
For once the documentation is explaining the use-cases very well,
so I'll let you check it out: [angular.io/guide/lightweight-injection-tokens](https://angular.io/guide/lightweight-injection-tokens).

Angular Material (and similar libraries)
will benefit from this new feature,
and should be able to reduce their bundle sizes.

## async() helper renamed

The testing helper function `async` has been deprecated and renamed `waitForAsync`.

The reason behind this renaming is that it can be confusing to have a function named `async()` when we now have a JavaScript keyword named `async` (that keyword did not exist when the Angular function was created), which is slightly similar (you can await asynchronous calls), but different (`async()` waits for all asynchronous calls, where `async` only waits for the calls marked with `await`).

You can simply replace it everywhere and you're good to go: there is no change in behavior between `async()` and the new `waitForAsync()`.

In my opinion, this helper is not necessary in most cases.
I explain why in [our CLI v10.1 article](/2020/09/03/angular-cli-10.1/).


All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
