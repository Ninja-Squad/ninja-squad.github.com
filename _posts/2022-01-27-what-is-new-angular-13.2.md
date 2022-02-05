---
layout: post
title: What's new in Angular 13.2?
author: cexbrayat
tags: ["Angular 13", "Angular"]
description: "Angular 13.2 is out!"
---

Angular&nbsp;13.2.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/13.2.0">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This is a minor release with a few interesting features. Let's dive in!

## Safe calls in templates

The template compiler now supports safely calling functions that may be undefined inside template expressions. For example, if `getName` is not always available on `user`, you can write:

{% raw %}
    <p>Hello {{ user.getName?.() }}!</p>
{% endraw %}

This has been supported in TypeScript for a while, and it's now also possible in templates.

## Extended template diagnostics

You're probably aware that you can configure Angular to check your templates
with `strictTemplate: true` in the `angularCompilerOptions` section of your `tsconfig.json` file.

Angular v13.2 introduces "extended diagnostics" that adds a few more checks.
In this release, two additional checks are shipped and enabled by default if you use `strictTemplates`:

- `invalidBananaInBox`
- `nullishCoalescingNotNullable`

The first one logs a warning ([code NG8101](https://angular.io/extended-diagnostics/NG8101))
if you write a two-way binding ngModel with `([ngModel)]` instead of `[(ngModel)]`:

    Warning: src/app/login/login.component.html:10:61 - warning NG8101: In the two-way binding syntax the parentheses should be inside the brackets, ex. '[(ngModel)]="credentials.login"'.
    Find more at [https://angular.io/guide/two-way-binding](https://angular.io/guide/two-way-binding)


The second check logs a warning ([code NG8102](https://angular.io/extended-diagnostics/NG8102))
if you use the nullish coalescing operator `??` on an expression that can not be null (and have `strictNullChecks` enabled).

For example:

{% raw %}
    {{ date ?? 'Now' }}
{% endraw %}

throws if `date` is never `null`:

    Warning: src/app/home/home.component.html:17:4 - warning NG8102: The left side of this nullish coalescing operation does not include 'null' or 'undefined' in its type, therefore the '??' operator can be safely removed.

By default, the checks log a warning.
To configure them to throw errors, the new `extendedDiagnostics` option can be used.
Add the following to your TS config file:

    "angularCompilerOptions": {
      "strictTemplates": true,
      "extendedDiagnostics": {
        "defaultCategory": "error"
      }
    }

`defaultCategory` is the default category for all checks. Its default value is `warning`,
but you can change it for `error` as I did, or to `suppress` to disable all checks.
It is also possible to fine-tune each check:

    "angularCompilerOptions": {
      "strictTemplates": true,
      "extendedDiagnostics": {
        "checks": {
          "invalidBananaInBox": "error",
          "nullishCoalescingNotNullable": "warning"
        }
      }
    }

## Router

The router now allows using Symbols for the keys of the `data` and `resolve` properties.
Until now, you had to use a string. Symbols are becoming more and more common,
so the router now allows to write:

    const usernameKey = Symbol('username');
    //...
    const routes: Routes = [
      {
        path: '',
        component: HomeComponent,
        data: {
          [usernameKey]: 'cexbrayat'
        }
      }
    ];

## Forms

The [Typed Forms RFC](https://github.com/angular/angular/discussions/44513)
is now public. Even if it is not yet available, a few PRs landed in the forms module
to prepare for it.

It is now possible to define that a control must reset to its initial value.
In that case, a call to `.reset()` will reset the form control not to `null` as it does currently,
but to the initial value defined.

    const form = new FormGroup({
      login: new FormControl('cexbrayat', { initialValueIsDefault: true }),
    });
    form.get('login').reset(); // sets the field to `cexbrayat`

This will help when using Typed Forms, as the type of the value will be inferred as `string` if `initialValueIsDefault` is `true`, instead of `string | null` if it isn't (as a call to `reset()` may have set the value to `null`).

In the future, the `initialValueIsDefault` option may become the default behavior,
and that the option will no longer be necessary.


You'll find more interesting features in our article about the
[CLI v13.2.0 release](/2022/01/27/angular-cli-13.2).

Stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
