---
layout: post
title: What's new in Angular CLI 9.1?
author: cexbrayat
tags: ["Angular 9", "Angular 8", "Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4", "Angular CLI"]
description: "Angular CLI 9.1 is out! Read all about the new Protractor options and TODO!"
---

[Angular CLI 9.1.0](https://github.com/angular/angular-cli/releases/tag/v9.1.0) is out!✨

If you want to upgrade to 9.1.0 without pain (or to any other version, by the way), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (8.3.8 for example), and the target version (9.1.0 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/8.3.8...9.1.0](https://github.com/cexbrayat/angular-cli-diff/compare/8.3.8...9.1.0).
It can be a great help along the official `ng update @angular/core @angular/cli` command.
You have no excuse for staying behind anymore!

Let's see what we've got in this release.

## Fun with flags

### ng e2e

The Protractor builder now accepts two flags `grep` and `invertGrep`
to only run the matching spec names.
Not the file name, the spec name,
meaning what you defined in the `describe()` and `it()` functions:

    describe('App', () => {
      it('should have a navbar', () => { });
      it('should say hello on home', () => { });
      it('should have a login button on home', () => { });
    });

For example if you only want to run the specs whose name matches 'home',
you can run `ng e2e --grep home`.

`invertGrep` can be used to run the specs that don't match the grep regex:
`ng e2e --grep home --invert-grep` runs all the specs except the ones containing "home".

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
