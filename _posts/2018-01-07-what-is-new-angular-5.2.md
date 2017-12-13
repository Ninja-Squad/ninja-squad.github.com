---
layout: post
title: What's new in Angular 5.2?
author: cexbrayat
tags: ["Angular 5", "Angular", "Angular 2", "Angular 4"]
description: "Angular 5.2 is out! Which new features are included?"
---

Angular 5.2.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#520-TODO">
    <img class="img-rounded img-responsive" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

Let's see what 5.2 has in stock for us!

## Templates

Angular{nbsp}5.0 introduced the `fullTemplateTypeCheck` option in the compiler.
When activated, the Angular compiler will check more strictly your templates and catch potential type errors
(check our [Angular{nbsp}5.0 blog post](/2017/11/02/what-is-new-angular-5/) to learn more).
The feature is really powerful but sometimes you can run into expressions in your templates that you know will work at runtime,
even if the compiler can't type-check them.

Angular{nbsp}5.2 introduces a new function you can use in your templates, called `$any()`.
`$any()` can be used in binding expressions to disable type checking of this expression.
This is really similar to `as any` in TypeScript, and allows expressions that work at runtime but do not type-check.

    interface Pony {
      name: string;
    }

    @Component({
      template: '<p>Hello {{ $any(pony).age }}'
    })
    export class PersonComponent {
      pony: Pony;
      // pony has no field age, so the template should not compile
    }

As for `any` in TypeScript, I'm not really fan of using this:
I usually prefer to have a correct type instead of "cheating" with `any` or `$any()`.
So this is not really for the day to day use.
This is more targeted to help the applications using `fullTemplateTypeCheck`
which can raise type errors hard to fix, usually from third party libraries.
This was also introduced for internal use in the framework.

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](http://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
