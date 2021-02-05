---
layout: post
title: What's new in Angular CLI 9.0?
author: cexbrayat
tags: ["Angular 9", "Angular 8", "Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4", "Angular CLI"]
description: "Angular CLI 9.0 is out! Read all about Ivy by default, the automatic migrations, the multiple configurations support and all the new options!"
---

[Angular CLI 9.0.0](https://github.com/angular/angular-cli/releases/tag/v9.0.0) is out!✨

If you want to upgrade to 9.0.0 without pain (or to any other version, by the way), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (8.3.8 for example), and the target version (9.0.0 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/8.3.8...9.0.0](https://github.com/cexbrayat/angular-cli-diff/compare/8.3.8...9.0.0).
It can be a great help along the official `ng update @angular/core @angular/cli` command.
You have no excuse for staying behind anymore!

Let's see what we've got in this release.

## Ivy by default

This is probably the most awaited feature in the Angular community:
[Ivy](/2019/05/07/what-is-angular-ivy/) is now production ready,
and the CLI flag `enableIvy` is now `true` by default!
You can still switch it back to `false` if you encounter an issue.

You'll notice that the first build/serve of your application is slightly longer:
this is because `ngcc` needs to compile your dependencies.
Once this is done, the dependencies are "Ivy compatible",
and the following builds don't need to run `ngcc` again
(except if you add a new dependency for example).
This should be mostly transparent,
as the Angular team did its best to support the most popular libraries.
If you encounter an issue with one of your dependencies though,
open an issue on the Angular repository,
and someone will take a look.

The build and serve commands now use the AoT compiler by default,
and you should have re-build times close to what we had in JiT mode previously.
In our applications, we even noticed that the tests were way faster,
which is super cool! 🚀


## Automatic migrations in v9

When running `ng update @angular/cli`, some schematics are going to update your code:

- `aot: true` is added to the default configuration in `angular.json`. The CLI team is now confident that always working in AoT mode is possible and fast enough with Ivy.
- `enableIvy: true` is removed (if present) from your TS config, and the `include` section is updated to only include the files needed.
- the `anyComponentStyle` budget, added in [CLI 8.2](/2019/08/01/angular-cli-8.2/), is automatically added to your project configuration with a `6kb` limit warning.
- (if you are developing a PWA) the `ngsw-config.json` file is updated to include `manifest.webmanifest` which is now necessary in modern Chrome versions.
- the styles and scripts option `lazy` in `angular.json` has been deprecated and replaced by a new `inject` property which has the opposite meaning (`lazy: true` = `inject: false` if you don't want to inject the style or script in your HTML page). The schematic automatically handles the migration.

If your project is a library and not an application, it is also automatically updated.
The migration:

- adds `enableIvy: false` to the TS config, to ensure compatibility with previous Angular versions.
- removes the now useless `tsickle` dependency and the `annotateForClosureCompiler` from the TS config.

## Multiple configurations support

The `ng build` command now allows to use several configurations!
Previously you had to use only one,
which was cumbersome because you had to duplicate every property in every configuration.

Now you can use:

    ng build --configuration=production,fr

The command then uses the `production` configuration, merged with the `fr` configuration.
The `fr` configuration can re-declares a property of the `production` configuration,
to overwrite it.

## Generate interceptors

The CLI offers a new generator to easily create interceptors!

    ng generate interceptor auth

This creates an `AuthInterceptor` class in `auth.interceptor.ts`.
But it does not register the interceptor for you.
You have to do it manually as you usually do with `{ provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor }`. Still nice to have though!


## Fun with flags

### ng new

The `enable-ivy` flag has been removed (as Ivy is now enabled by default).
A new `--strict` flag has been added. You can use it to generate a project with a stricter TypeScript configuration (with `noImplicitAny`, `noImplicitReturns`, `noImplicitThis`, `noFallthroughCasesInSwitch`,  and `strictNullChecks` enabled).

A new option named `package-manager` has also been added,
allowing to specify which package manager you want to use when creating the project.
The supported values are `npm`, `yarn`, `pnpm` and `cnpm`.
If you specify a value, then the value is stored in your `angular.json` file.

### ng generate component

You can now specify a `type` when generating a component:

    ng generate component --type container hello

This generates files with a `container` suffix (`hello.container.ts`, `hello.container.html`...),
and a component named `HelloContainer` instead of `HelloComponent`.

You can also now add a `displayBlock` flag if you want to generate a style containing `:host { display: block; }`.

Also note that the `styleext` and `spec` flags have been definitely removed,
so you must now use `style` and `skipTests` instead.

### ng generate guard

You can now specify that you want a `CanDeactivate` guard
in addition to the already supported `CanActivate`, `CanActivateChild`, and `CanLoad`.
I realized it was missing when working on an application for a customer,
so I added it 🤓.

### ng serve

The `serve` command now accepts a `--allowed-hosts` flag,
to specify the hosts allowed to access your application.

### ng build

The `build` command now has an `--experimental-rollup-pass` flag.
The name is explicit enough: this is an experiment!
The build leverages [Rollup](https://rollupjs.org) to, hopefully,
generate smaller bundles than a raw Webpack build.
This is highly experimental and does not work with various dependencies,
as they need to be packaged in a format that Rollup can work with.
You can give it a try and see by yourself on your project though.

### ng update

It is now possible to ask the CLI to create one commit per migration done
by using `ng update --create-commits`.


## i18n - internationalization support with @angular/localize

As Angular v9 brings a re-written support for i18n,
the CLI also includes some i18n-related changes.
In fact there is so much to tell, that the best is to check our
[dedicated article about internationalization](/2019/12/10/angular-localize/).

TL;DR: it's now much faster to generate the N localized versions of your application,
as the CLI first compiles it, and then just generates the localized versions
by replacing the messages by theirs translations in the compiled output.
It is even generated in parallel if possible!

As the options to give the serve and build commands changed,
the CLI offers an automatic migration from the old to the new options.

Note also a tiny but useful feature: when building an application with i18n,
the document locale is now set using the `lang` attribute on the `html` root element.
For example, if you build your application in French, then the `index.html` file contains `<html lang='fr'>`.
Until now, you could of course do it by hand, but it was cumbersome.
It's now handled automatically!

## ng add for library authors

You may know that the CLI supports a `ng add` command to add dependencies to your project:
- if the dependency has an "add" schematic, it runs it.
- if it does not, `ng add` simply adds the dependency to your `package.json`.

So, as a library author, you probably want to offer such a schematic,
to simplify the setup of your library.
The weird thing was that, if you wrote such a schematic,
you had to handle the addition to the `package.json` file yourself.
This has now been simplified with a `save` option,
that you can configure for `ng-add` in the `package.json` of the library.
`save` accepts:
- `false`, if you don't want to save it;
- `true` or `dependencies` if you want to save it as a dependency;
- `devDependencies` if you want to save it as a dev dependency.

Our own open-source libraries
[ngx-valdemort](https://ngx-valdemort.ninja-squad.com/) and
[ngx-speculoos](https://ngx-speculoos.ninja-squad.com/)
are now up-to-date with Angular v9
and offer a `ng-add` schematics.
You can easily give them a try with
`ng add ngx-valdemort` or `ng add ngx-speculoos` 🙌.

As you can see, this 9.0 release has some interesting new features!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
