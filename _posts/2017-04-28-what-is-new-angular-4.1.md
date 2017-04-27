---
layout: post
title: What's new in Angular 4.1?
author: cexbrayat
tags: ["Angular 2", "Angular", "Angular 4"]
description: "Angular 4.1 is out! Which new features are included?"
---

Angular 4.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#410-2017-04-26" title="Become a ninja with Angular">
    <img class="img-rounded img-responsive" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This will be a short blog post,
because there are not a lot of new features...

The most part of the work has been done on the official docs,
which are now an Angular CLI app,
and this migration takes some time.
We can then expect to have nice new content
when this will be done.

So, what are the new features? Let's dive in!

# i18n

The internationalization module has a few bugfixes,
and a notable new feature:
the extracted messages file now has the source file for each message.
It will far easier for developers to know where the messages come from!

    <trans-unit id="home.title" datatype="html">
      <source>Welcome to Ponyracer</source>
      <target/>
      <context-group purpose="location">
        <context context-type="sourcefile">src/app.component.ts</context>
        <context context-type="linenumber">10</context>
      </context-group>
    </trans-unit>

# Core

The main new feature of this release is the support
of the upcoming TypeScript 2.3 version,
and the support of `strictNullChecks`.

This option allows to check if you won't run into nullability problems in your app.
Angular itself now has correct types.
For example, when you try to retrieve a `FormControl` from a `FormGroup` with `get`,
the returned type is `AbstractControl | null`
(because the control might not exist).
If you don't have the `strictNullCheck` option, you can do:

    static passwordMatch(control: FormGroup) {
      const password = control.get('password').value;
    }

but when you enable it, the compiler will complain,
and you have to do something like:

    static passwordMatch(control: FormGroup) {
      const passwordCtrl = control.get('password');
      const password = passwordCtrl !== null ? passwordCtrl.value : '';
    }

Or you can use the `!` post-fix expression operator introduced by TypeScript,
to basically say to the compiler "Shut up":

    static passwordMatch(control: FormGroup) {
      const password = control.get('password')!.value;
    }

That's all for this small release!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](http://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
