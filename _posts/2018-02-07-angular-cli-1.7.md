---
layout: post
title: What's new in Angular CLI 1.7?
author: cexbrayat
tags: ["Angular 2", "Angular", "Angular 4", "Angular 5", "Angular CLI"]
description: "Angular CLI 1.7 is out! Which new features are included?"
---

[Angular CLI 1.7.0](https://github.com/angular/angular-cli/releases/tag/v1.7.0) is out with some nice new features!

If you want to upgrade to 1.7.0 without pain (or to any other version, BTW), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (1.2.1 for example), and the target version (1.7.0 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/1.2.1...1.7.0](https://github.com/cexbrayat/angular-cli-diff/compare/1.2.1...1.7.0). You have no excuse for staying behind anymore!

Let's see what new features we have!

## Angular Compiler options

The Angular Compiler options are now supported!

That means if you try to use for example the `fullTemplateTypeCheck` option
introduced in Angular&nbsp;5.0 (see our [blog post](/2017/11/02/what-is-new-angular-5/)),
you can now just update the `tsconfig.json` file of your CLI project,
and when you will run `ng serve` or `ng build` the option will be picked up!

## TypeScript 2.5 and 2.6 support

As Angular{nbsp}5.1 supports TypeScript{nbsp}2.5
(see our [blog post](/2017/12/07/what-is-new-angular-5.1/))
and Angular{nbsp}5.2 now supports TypeScript{nbsp}2.6
(see our other [blog post](/2017/12/07/what-is-new-angular-5.1/)) ,
the CLI will no longer complain if you use this TS version.


Check out our [ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](http://ninja-squad.com/training/angular) if you want to learn more!
