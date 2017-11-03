---
layout: post
title: What's new in Angular CLI 1.5?
author: cexbrayat
tags: ["Angular 2", "Angular", "Angular 4", "Angular 5", "Angular CLI"]
description: "Angular CLI 1.5 is out! Which new features are included?"
---

[Angular CLI 1.5.0](https://github.com/angular/angular-cli/releases/tag/v1.5.0) is out with some nice new features!

If you want to upgrade to 1.5.0 without pain (or to any other version, BTW), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (1.2.1 for example), and the target version (1.5.0 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/1.2.1…1.5.0](https://github.com/cexbrayat/angular-cli-diff/compare/1.2.1...1.5.0). You have no excuse for staying behind anymore!

Let's see what new features we have!

## Support for Angular 5 and its new compiler

This is probably the biggest feature of this release!
As Angular 5 ships with an improved compiler (check out [our article about that](http://blog.ninja-squad.com/2017/11/02/what-is-new-angular-5/) if you missed it),
the CLI can now use it (and will automatically if your project uses ng 5).
It gives us faster builds,
and even an AoT mode that starts to be usable in development (using the incremental rebuild).

For example, on a medium-size application, where `ng serve` rebuilds in ~400ms,
you can see the difference between the versions if you use AoT compilation:

- `ng serve --aot` with ng 4.4 and CLI 1.4: ~4000-8000ms
- `ng serve --aot` with ng 5.0 and CLI 1.5: ~1800-3600ms

As you may know, building with the AoT mode gives you all the usual TypeScript errors
and the errors you may have in your templates.
Which is pretty useful, but used to be too slow to be usable in development.
Now it starts to be more bearable, even if it's still slower than JiT compilation,
but the Angular team is working hard on this, and it starts to show
(even if it is still too slow on big project).

By default, the `build-optimizer` plugin (which does a little bit of extra work on your generated code, like removing unneeded decorators, adding hints for dead code removals, etc) will now be applied to your build
if you are using Angular 5 and building in AoT.

That means that your build command:

    ng build --prod --build-optimizer

can be simplified to:

    ng build --prod

once you'll have updated to the CLI 1.5 and Angular 5.

## ES2015 as a target

The CLI now supports ES2015 as the target of the build (and not only ES5).
If you are targeting only modern browsers, you can now choose to output ES2015 code
as the result of your build.
Just change the `target` of your `tsconfig.json` file and you're set!
(fun fact: it slims down the bundles generated when I tried it, but I can't say it will always be the case...).

## Auto loading of locale files for internationalization

Angular 5 introduced some breaking changes regarding internationalization:
Angular stopped relying on the Intl API (that should be provided by the browser,
but is not always, and polyfills can be buggy) and now requires you to load explicitly
the locale data you need. For example the `DatePipe` needs to know the day names in french if you want to localize your app in this language.
To do so, you need to have somewhere in your app:

    import { registerLocaleData } from '@angular/common';
    import localeFr from '@angular/common/locales/fr';

    registerLocaleData(localeFr);

The problem is that if you build your application in 5 different languages,
you need to do this for each language, and you don't want to include every locale in every build 🤔.

This is the cool feature introduced by the CLI 1.5: you don't have to do this yourself!
The CLI will automatically add these lines of code, with the correct locale data,
when you build your app (based on the locale you specified when you build):

    ng build --aot --locale=fr

When you are building or serving the app in JiT mode, the CLI will do the same trick:

    ng serve --locale=fr

But for your app to work without AoT, you'll have to set the `LOCALE_ID` manually
(whereas the CLI does it for you automatically in AoT mode).
As the AoT mode will become the default soon (scheduled for CLI 2.0),
this is not really bothering.

## Resource integrity

The CLI now adds `integrity` and `crossorigin` attributes to scripts and stylesheets,
that modern browsers use to check if the resource fetched has not been corrupted
(by a "man in the middle" type of attack).
You don't have to do anything, and your application is safer!

## TypeScript version mismatch

Angular CLI warns you if you are using a version of TypeScript
which is not the recommended one with your Angular version
(as it can lead to unnecessary headaches).
You can now deactivate the warning for your project (if you are sure about what you are doing of course 😅)
with `ng set warnings.typescriptMismatch=false` (it was only globally previously).

## appRoot configurable

The `appRoot` is now configurable in a CLI app,
the default being `app` as it is right now.
The main use of this feature is for people who want to have several app in the same `src` directory,
each with their own name.

## Schematics template

The new `schematics` tool used by the CLI under the hood to generate ... schematics (blueprints) of projects,
is very generic and allows to create your own schematics.
But how do you do that? To help with this question, the CLI team released a collection called `@schematics/schematics` containing a schematic for a schematic (that's a lot of schematic, I know).
This sample demonstrates a few common features and is a good starting point
if you want to try to build your own project templates.

    yarn global add @angular-devkit/schematics @schematics/schematics
    schematics @schematics/schematics:schematic --name my-custom-schematics

## Nx schematics

A new unofficial schematic has been released by nwrl.io.
As I was saying in my last blog post, it didn't took long for the community to start producing these!
It's called Nx and focuses on creating CLI projects containing several applications and components libraries in the same repository.
If your company needs to have several applications using the same set of common components and services,
you should check it out for inspiration: [nrwl/nx](https://github.com/nrwl/nx).
The schematic also uses [ngrx](https://github.com/ngrx) and can generate examples with unit tests included.

Check out our [ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](http://ninja-squad.com/training/angular) if you want to learn more!
