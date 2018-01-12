---
layout: post
title: What's new in Angular 5.2?
author: cexbrayat
tags: ["Angular 5", "Angular", "Angular 2", "Angular 4"]
description: "Angular 5.2 is out! Which new features are included?"
---

Angular 5.2.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#520-2018-01-10">
    <img class="img-rounded img-responsive" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

Let's see what 5.2 has in stock for us!

## Templates

Angular&nbsp;5.0 introduced the `fullTemplateTypeCheck` option in the compiler.
When activated, the Angular compiler will be stricter when checking your templates and catch potential type errors
(check our [Angular&nbsp;5.0 blog post](/2017/11/02/what-is-new-angular-5/) to learn more).
The feature is really powerful but sometimes you can run into expressions in your templates that you know will work at runtime,
even if the compiler can't type-check them.

Angular&nbsp;5.2 introduces a new function you can use in your templates, called `$any()`.
`$any()` can be used in binding expressions to disable type checking of this expression.
This is really similar to `as any` in TypeScript, and allows expressions that work at runtime but do not type-check.

    {% raw %}
    interface PonyModel {
      name: string;
    }

    @Component({
      template: '<p>Hello {{ $any(ponyModel).age }}'
    })
    export class PonyComponent {
      ponyModel: PonyModel;
      // ponyModel has no field age, so the template should not compile
    }
    {% endraw %}

As for `any` in TypeScript, I'm not really a fan of using this:
I usually prefer to have a correct type instead of "cheating" with `any` or `$any()`.
So this is not really for the day to day use.

This is rather intended to help the applications using `fullTemplateTypeCheck`
which can raise type errors hard to fix, usually from third party libraries.
For example, we use `ng-bootstrap` and there were two errors in `1.0.0-beta.7`.
We [fixed](https://github.com/ng-bootstrap/ng-bootstrap/commit/f1137aa867cc01e9cc92bd214354a2c44b9cb735) [them](https://github.com/ng-bootstrap/ng-bootstrap/commit/da31c3ed2aca9a217e877c92cc1a779a16028db3), so if you use `ng-bootstrap@1.0.0-beta.8` or a more recent one, you should be OK!

This was also introduced for internal use in the framework (see below).

## Compiler

Still regarding this feature, some work has been done to have more accurate errors in your template if you use the `strictNullChecks` option form the TypeScript compiler (see our blog post about [Angular&nbsp;4.1](/2017/04/28/what-is-new-angular-4.1/) to learn more about this) with `fullTemplateTypeCheck`.

For example, the compiler was not really good at determining a situation like this one:

    {% raw %}
    @Component({
      template: `<div *ngIf="ponyModel">{{ ponyModel.name }}</div>`
    })
    export class PonyComponent {
      // ponyModel can be a pony or null
      @Input() ponyModel: PonyModel | null;
    }
    {% endraw %}

Here, using `strictNullChecks` and `fullTemplateTypeCheck`, the compiled template would raise an error,
as the TypeScript code generated could not see that, because of the `*ngIf` wrapping it,
the evaluation of `ponyModel.name` was safe.
The expression is only evaluated if `ponyModel` is not null, so there is no risk,
but the compiler could not see it and was considering `ponyModel` to be `PonyModel | null`:

    src/app/pony/pony.component.html(1,25): : Object is possibly 'null'.

Some work has been done by the Angular team to fix this:
now the TypeScript code generated will take into account the `*ngIf` guard,
and automatically consider `ponyModel` as a not null entity inside the `*ngIf`!
So where we used to "cheat" and write:

    {% raw %}
    {{ ponyModel!.name }}`
    {% endraw %}

We can now simply write:

    {% raw %}
    {{ ponyModel.name }}
    {% endraw %}

and the compiler will understand the situation!

Note that this a generic feature: if you write your own structural directive,
that works like an `*ngIf`, you can also leverage this type guard feature by adding
a static field called `ngIfUseIfTypeGuard` to your directive.

## Router parameters inheritance

Previously, the router would merge path and matrix params, as well as data/resolve,
with special rules (only merging down when the route was an empty path, or was component-less).

Angular&nbsp;5.2 adds an option called `paramsInheritanceStrategy` which can take different values:

- when set to `always`, it makes child routes unconditionally inherit params from parent routes;
- when set to `emptyOnly`, the default, it only inherits parent params for path-less or component-less
 routes (the former behavior).

## Project Ivy: a faster and smaller renderer

This release doesn't have many features because part of the team is currently
rewriting one piece of the framework: the renderer.

We don't know much about this project (codename *Ivy*) as the design doc is not public right now,
except that it should make the renderer smaller and faster, with a simpler design,
allowing a better incremental compilation (faster builds for us \o/),
and will be fully backwards compatible (hopefully no breaking changes \o/).
We'll keep you up to date when this feature is ready (it's still in early stages).


That's all this release!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](http://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
