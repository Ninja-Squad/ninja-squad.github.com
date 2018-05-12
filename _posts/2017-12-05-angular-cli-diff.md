---
layout: post
title: Easily upgrade your Angular CLI application with angular-cli-diff
author: cexbrayat
tags: ["Angular 5", "Angular CLI", "Angular", "Angular 2", "Angular 4"]
description: "We wrote a small open-source tool to help you upgrade your Angular CLI applications."
---

Tons of Angular projects are using the Angular CLI.
This tool is really great as it wraps all the Webpack complexity,
and helps you build, test and serve your application.
It can also generate components, services, pipes... with their associated tests.

A few maintainers are working full-time to evolve the CLI, fix bugs and introduce [awesome](/2017/08/10/angular-cli-1.3/) [new](/2017/09/14/angular-cli-1.4/) [features](/2017/11/03/angular-cli-1.5/).
As a developer relying on the CLI, you'll want to update the CLI version your project depends on
as often as possible.

Sadly, there is no automated way to do it.
You may think that bumping the package version in your `package.json` is enough, but... no...

There are also often configuration files to update,
and even if the committers do their best to guide us through the updates,
it can be hard to track exactly what you need to change between your current version
and the new shiny one.
And these new releases happen quite often
[as you can see](https://github.com/angular/angular-cli/releases)!

Some time ago, the CLI had an `init` command that was trying to help you in the upgrade,
but it was an "all or nothing" process: you just could overwrite the file or ignore it.
The command has been removed in later versions,
so you don't have a lot of help right now.

That's why we built a small script that generates a bare application with every CLI version.
The result is [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff),
a repository that allows you to see exactly what changed between your version and another one!

For example, you are currently using 1.0.3 and want to test the release 1.5.2?

Here you go: [https://github.com/cexbrayat/angular-cli-diff/compare/1.0.3...1.5.2](https://github.com/cexbrayat/angular-cli-diff/compare/1.0.3...1.5.2)

As you can see there are some differences that you might have missed (new dependencies, new polyfill, new unit test configuration, new types, new linter rules...).

You can, of course, compare any version you want.
They are listed in the [README of the repository](https://github.com/cexbrayat/angular-cli-diff) and new versions are added a few hours/days after the official release.

This problem is not really original, and similar repositories exist for tools like React Native with [rn-diff](https://github.com/ncuillery/rn-diff) (from a good friend of mine [Nicolas Cuillery](https://github.com/ncuillery)) which was definitely an inspiration!

It has been quite useful to us these last weeks to update our code samples and online training exercises,
we hope it will help you too.

Check out our [ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular) if you want to learn more!
