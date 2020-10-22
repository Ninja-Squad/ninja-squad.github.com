---
layout: post
title: What's new in Angular 10.2?
author: cexbrayat
tags: ["Angular 10", "Angular"]
description: "Angular 10.2 is out!"
---

Angular&nbsp;10.2.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#1020-2020-10-21">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This is mostly a maintenance release with bugfixes,
but as it contains a potential breaking change,
this was turned into a minor release.

The [breaking change](https://github.com/angular/angular/commit/71fb99f062b85fb10391f5d774886e23a8278777)
only impacts those who are using server-side rendering,
so it may not even be relevant for you.

Let's see what the rest of the release brings us.


## i18n

`ng add @angular/localize` now adds the package in the `devDependencies`
rather than in the `dependencies` as it used to.
The reasoning is that, for most applications, localize is only used at build time.
If you still want to use it at runtime, you can add the flag `--use-at-runtime`,
and the package is added to the `dependencies`.
In an existing application, you can of course manually move the `@angular/localize` package
to the `devDependencies`.

## ngcc

The `ngcc` compiler should be faster after the introduction of some caching mechanisms.
It should also consume less memory.
The commit mentions a 2-4x improvement in a CLI project,
and as [I mentioned on Twitter](https://twitter.com/cedric_exbrayat/status/1306681520061583361),
I do agree that this makes a difference 🚀.

On a related note, the "linker" project, which will allow to ship and consume Ivy libraries directly
and get rid of `ngcc` in the long term, is making some progress 💪.

We'll have more interesting features in the next major release v11,
which should be in November, stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
