---
layout: post
title: What's new in Angular 13.1?
author: cexbrayat
tags: ["Angular 13", "Angular"]
description: "Angular 13.1 is out!"
---

Angular&nbsp;13.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/13.1.0">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This minor version is out a week earlier,
so we all have time to update before the end of the year break.

## Typescript 4.5

Angular&nbsp;13.1 now supports TypeScript 4.5.
You can check out what's new in TS 4.5 on the [Microsoft blog](https://devblogs.microsoft.com/typescript/announcing-typescript-4-5/).

## Http

The `HttpContext` class now has a new method `has()`
to check the existence of a token in the context.

Note that the `error()` method that you can use in HTTP tests
has a new signature: it now takes a `ProgressEvent` instead of an `ErrorEvent`
(to align with what browsers do).
You must now write:

    const mockError = new ProgressEvent('error');
    httpTestingController.expectOne(..).error(mockError);

## entryComponents removal

`entryComponents` has been deprecated since Angular&nbsp;9 (check [our blog post](/2020/02/07/what-is-new-angular-9.0/) for more details).
When updating to v13.1, a schematics will automatically remove `entryComponents` from your `@Component` and `@NgModule` if you still have some.

That's all for the visible part of this small release.
The team is still working hard though: View Engine code is getting chomped out of the codebase
(you now have an error if you try to compile with VE),
and the "strongly typed forms" experiment is making progress.

You'll find more interesting features in our article about the
[CLI v13.1.0 release](/2021/12/10/angular-cli-13.1).

Stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
