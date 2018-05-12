---
layout: post
title: What's new in Angular CLI 1.4?
author: cexbrayat
tags: ["Angular 2", "Angular", "Angular 4", "Angular CLI"]
description: "Angular CLI 1.4 is out! Which new features are included?"
---

[Angular CLI 1.4.0](https://github.com/angular/angular-cli/releases/tag/v1.4.0) is out with some nice new features!

If you want to upgrade to 1.4.0 without pain (or to any other version, BTW), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (1.2.1 for example), and the target version (1.4.0 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/1.2.1…1.4.0](https://github.com/cexbrayat/angular-cli-diff/compare/1.2.1...1.4.0). You have no excuse for staying behind anymore!

Let's see what new features we have!

## Schematics

The Google team has created [schematics](https://github.com/angular/devkit/tree/master/packages/angular_devkit/schematics),
a Yeoman-like generator.
Angular CLI will now use this new tool to generate the application skeleton
and the components, services, pipes...
All the blueprints are now bundled in [`schematics/@angular`](https://github.com/angular/devkit/tree/master/packages/schematics/angular)
and have been removed from the CLI itself.

Really interesting as it opens the possibility to have other blueprints than the official ones!
This is a feature that other frameworks also have (like [Vue CLI](https://github.com/vuejs/vue-cli#official-templates) or [Ember CLI](https://ember-cli.com/extending/)).

We can expect to see new "schematics" for Angular CLI really soon,
for example some oriented for server-side rendering apps, or mobile apps, or progressive apps, or native apps, etc.

The CLI now has an option to specify the blueprint you want to use when you generate a project:

    ng new --collection my-custom-schematics project-name

You can of course define your own schematics, but we did not give it a try yet.

## Serve path

A new option for `ng serve` is available to specify a path where you want the application to be served in dev:

    ng serve --serve-path hello

will serve the application at `http://localhost:4200/hello`.
This is a simple way to configure it, even if you could do the same with the `--base-href` and `--deploy-url` flags.

## Missing translation strategy

If you are using the i18n support of Angular,
you can specify directly from the CLI the strategy you want to adopt when a translation is missing:

    ng build --aot --locale fr --i18n-file src/i18n/messages.fr.xlf --missing-translation error

The `--missing-translation` error flag is available for the `serve` and `build` commands,
and accepts the values `error`, `warning` or `ignore`.

## Scripts sourcemaps and minifications

The scripts that were added via the `scripts` array in `.angular-cli.json` were not minified and had no sourcemaps. This is now resolved.

Check out our [ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular) if you want to learn more!
