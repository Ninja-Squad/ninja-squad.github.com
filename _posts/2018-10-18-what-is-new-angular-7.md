---
layout: post
title: What's new in Angular 7?
author: cexbrayat
tags: ["Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4"]
description: "Angular 7 is out! Read about the support of the new versions of TypeScript, the progress made on Ivy, the router features and the deprecations introduced!"
---

Angular&nbsp;7.0.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#700-2018-10-18">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

Not a lot of new features in this release:
the Angular team is mainly focused on the Ivy project,
rewriting the Angular compiler and runtime code to make it smaller, better, faster.
But Ivy is not ready for prime time yet.

So don't expect a lot of shiny things in Angular 7.0:
there was not enough material to make a video as we did for [Angular 5](/2017/11/02/what-is-new-angular-5) or [Angular 6](/2018/05/04/what-is-new-angular-6).
This will be a short blog post for once,
and a fast and easy upgrade for you!

## TypeScript 3.1 support

One of the main new features is the support of TypeScript 3.1,
which is the latest release! It is in fact mandatory to bump to TS 3.1 for Angular 7.
Usually Angular lags a few releases behind,
so it's great to be able to use the latest TypeScript version for once!
You can check out what was introduced in [TypeScript 3.0](https://blogs.msdn.microsoft.com/typescript/2018/07/30/announcing-typescript-3-0/) and [TypeScript 3.1](https://blogs.msdn.microsoft.com/typescript/announcing-typescript-3-1/) on the Microsoft blog.

## Angular compilation options

As you may know, you can define `compilerOptions` for TypeScript
and `angularCompilerOptions` for Angular in your `tsconfig.json` files:

    {
      "extends": "../tsconfig.base.json",
      "compilerOptions": {
        "experimentalDecorators": true,
        // ...
      },
      "angularCompilerOptions": {
        "fullTemplateTypeCheck": true,
        "preserveWhitespaces": true,
        // ...
      }
    }

TypeScript allows you to extend the `compilerOptions` of another file
(see the `extends` part in the example),
but it was not doing anything with the Angular compiler options.
The Angular compiler is now fixed,
and you can define Angular compiler options in a base config,
then extend them in another file.
The options will be merged with the one defined in the inheriting config file,
as they are for the TypeScript compiler options!

## Ivy progress

The rewrite is making progress, but Ivy is still not usable in this release.
If you refer to the [official feature tracking](https://github.com/angular/angular/blob/master/packages/core/src/render3/STATUS.md),
a good chunk of the work is done.
But in reality, there is still a long way to go before we can use it.

Ivy has several pieces:

- `ngtsc`: the compiler that compiles your Angular application and generates JavaScript from your HTML templates. This piece of code has made good progress but still misses a few features.
- `ngcc`: a tool that explores all the dependencies you have, to convert existing code into "Ivy compatible" code. This is still very early stage, and barely usable at the moment if you don't know how to workaround a few issues
([Olivier](https://twitter.com/OCombe) and [Pete](https://twitter.com/petebd) from the Angular team were nice enough to help me).
- the renderer itself, which takes the generated code and makes the magic happen at runtime. It still moves a lot, as new optimizations and new issues are found by the team.

Another part that is eagerly awaited is the support of "runtime i18n".
The implementation work has just started this week,
so this is also far from being done.

I gave Ivy a few shots lately but it is definitely not ready for prime time yet.
Internally at Google, the Angular team needs to migrate the huge number of projects
they have to gather feedback and fix issues.
So it will take a few more months.

But you can check it out yourself, as the CLI added an `--experimental-ivy` flag
to generate an application with the configuration needed to try it.

    ng new ivy-test --experimental-ivy
    cd ivy-test
    $(npm bin)/ngcc
    ng serve --aot

Note that the change detection is not working as I'm writing these lines,
so this is very limited right now :).

## Slots with Angular Elements

It is possible to use `ViewEncapsulation.ShadowDom` since
[Angular 6.1](/2018/07/26/what-is-new-angular-6.1),
which is great for Angular Elements
(Angular components packaged as Web components that you can use alone).
But there was a missing feature to be able to use `<slot>`,
a new standard HTML element, introduced by the
[Web Component specification](https://developer.mozilla.org/en-US/docs/Web/Web_Components).
This feature is now available,
enabling components with a template like:

    @Component({
      selector: 'ns-card',
      template: `
        <header>
          <slot name="card-header"></slot>
        </header>
        <slot></slot>`,
      encapsulation: ViewEncapsulation.ShadowDom,
      styles: []
    })
    export class CardComponent {
    }

That can later be used as an Angular Element like this:

    <ns-card>
      <span slot="card-header">Become a ninja with Angular</span>
      <p>A wonderful book from Ninja Squad</p>
    </ns-card>

## Router

A new warning has been added if you try to trigger a navigation outside of the Angular zone,
As it doesn't work if you do so,
Angular now logs a warning (only in development mode).
This is pretty rare but can happen for example
if you try to redirect your users when an error occurs in the application
by providing a custom [`ErrorHandler`](https://angular.io/api/core/ErrorHandler)
(as the `handleError` method will run outside the ngZone to avoid a potential infinite loop).
The warning looks like:

    Navigation triggered outside Angular zone, did you forget to call 'ngZone.run()'?

Sadly, this introduces warnings in your unit tests if you use the router in some of them,
and looks like it's an issue in Angular itself (see [this issue](https://github.com/angular/angular/issues/25837) if you want to add a thumb up).

Another internal work that we can't really see has been the rewrite of the router to
use a single Observable under the hood, that will automatically cancel the previous navigations.
It will not affect you,
but should fix a bunch of issues when multiple navigations were triggered at the same time
and will allow new features more easily in the future.

## Deprecations

As it's usually the case with major releases, a few things have been deprecated.
If you are using `<ngForm>` to declare a form in your template
(you don't have to, as `form` also activates the NgForm directive),
this selector is now deprecated and should be replaced by `<ng-form>`.

As you can see, the release contains very few interesting features,
but Ivy is making progress and Angular 8.0 will probably have more cool stuff!

In the meantime, the upgrade of your applications should be very easy.

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
