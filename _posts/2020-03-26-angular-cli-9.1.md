---
layout: post
title: What's new in Angular CLI 9.1?
author: cexbrayat
tags: ["Angular 9", "Angular", "Angular CLI"]
description: "Angular CLI 9.1 is out! Read all about TSLint support and the new Protractor options!"
---

[Angular CLI 9.1.0](https://github.com/angular/angular-cli/releases/tag/v9.1.0) is out!✨

If you want to upgrade to 9.1.0 without pain (or to any other version, by the way), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (8.3.8 for example), and the target version (9.1.0 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/8.3.8...9.1.0](https://github.com/cexbrayat/angular-cli-diff/compare/8.3.8...9.1.0).
It can be a great help along the official `ng update @angular/core @angular/cli` command.
You have no excuse for staying behind anymore!

Let's see what we've got in this release.

## TSLint 6.1

As Angular 9.1 now supports TypeScript 3.8,
the CLI does support it as well.
The CLI also supports TSLint 6.1
(which supports the new TypeScript syntaxes introduced in version 3.8).
This is a bit weird,
as TSLint is officially deprecated since version 6.0,
in favor of [typescript-eslint](https://github.com/typescript-eslint/typescript-eslint).

The CLI team plans to migrate to `typescript-eslint`
as soon as possible, but, in the meantime,
it still supports TSLint, and its new release 6.1.

Note that TSLint 6.0
introduced a [lot of](https://github.com/palantir/tslint/pull/4871)
[changes](https://github.com/palantir/tslint/pull/4312)
in the `tslint:recommended` config,
that the CLI extends.

To avoid these breaking changes in our applications,
the default `tslint.json` configuration has been updated,
and the CLI 9.1 ships with a migration you can run to update your configuration.
The migration will be run automatically in version 10,
but until then, you can run it manually if you want with:

    ng update @angular/cli --migrate-only tslint-version-6

## Fun with flags 🤓

### ng e2e

The Protractor builder now accepts two flags `grep` and `invertGrep`
to only run the matching spec names.
Not the file name, the spec name,
i.e. what you specified in the `describe()` and `it()` functions:

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
