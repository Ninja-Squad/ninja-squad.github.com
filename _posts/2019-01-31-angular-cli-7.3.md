---
layout: post
title: What's new in Angular CLI 7.3?
author: cexbrayat
tags: ["Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4", "Angular CLI"]
description: "Angular CLI 7.3 is out! Read all about the conditional ES5 browser polyfill loading, new TS config and schematics available!"
---

[Angular CLI 7.3.0](https://github.com/angular/angular-cli/releases/tag/v7.3.0) is out!
For once, there is no Angular release at the same time.
The next version for the framework should be 8.0.0 in a few months.

If you want to upgrade to 7.3.0 without pain (or to any other version, by the way), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (6.2.1 for example), and the target version (7.3.0 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/6.2.1...7.3.0](https://github.com/cexbrayat/angular-cli-diff/compare/6.2.1...7.3.0).
It can be a great help along the official `ng update @angular/core @angular/cli` command.
You have no excuse for staying behind anymore!

Let's see what we've got in this release!

## Conditional ES5 browser polyfill loading

If you target older browsers, you used to need to uncomment a few things in the `polyfills.ts` file.
For example, if you want to target IE 9, 10 and 11, a few polyfills from `core-js` are needed.
These polyfills allow to use modern JS features (that Angular needs) even in older browsers,
and were commented in the dedicated `polyfills.ts` file,
where you could remove the comments if you wanted to include them.

But since Angular CLI 7.3, you don't have to do this anymore:
it's done for you automatically!
The CLI generates a bundle containing all the polyfills needed
for older browsers called `es2015-polyfills.***.js`
and adds it in the `index.html`.

As adding these polyfills makes the application heavier,
you might be wondering if this a good idea.
But there a twist: the CLI adds the script in `index.html` with a `nomodule` attribute.
This attribute indicates to modern browsers (that supports ECMAScript modules)
to ignore this script,
so it's not even fetched on modern browsers!
If you ever tried Vue CLI, this is very close to the ["modern" build mode](https://cli.vuejs.org/guide/browser-compatibility.html#modern-mode).

This new behavior is controlled via the `es5BrowserSupport` option in `angular.json`.
It saves roughly 56Kb (19Kb compressed) on modern browsers, so that's totally worth it.
You can activate it by adding the option in your configuration,
and update your `polyfills.ts` file (check [angular-cli-diff/compare/7.2.0...7.3.0](https://github.com/cexbrayat/angular-cli-diff/compare/7.2.0...7.3.0) to see how).

## Guard schematics for all interfaces

In previous version of the CLI, when using the schematic to generate a new router guard,
you ended up with a `CanActivateGuard` (which is probably the most used one, but not the only one).

In CLI 7.3, when you run the same schematic, you now have a multi-select choice looking like:

    ng g guard logged-in
    ? Which interfaces would you like to implement? (Press <space> to select, <a> to toggle all, <i> to invert selection)
    ❯◯ CanActivate
    ◯ CanActivateChild
    ◯ CanLoad

You can choose one or more interfaces to implement, and of course the result will be a guard implementing these interfaces.
Note that this multi-select question in interactive mode is also a new feature of the CLI.
The cool thing is that you can also directly specify the interfaces you want:

    ng g guard logged-in --implements CanActivate

## TSLint extends tslint:recommended

This is a feature I really like because [I added it](https://github.com/angular/angular-cli/pull/13213) 😉.

The default TSLint configuration now extends `tslint:recommended`,
the [recommended set of rules of the TSLint team](https://github.com/palantir/tslint/blob/master/src/configs/recommended.ts).

While updating the TSLint configuration in the CLI,
we also activated a few more rules.
You can see the difference [here](https://github.com/cexbrayat/angular-cli-diff/compare/7.2.0...7.3.0#diff-f513d6ba3af873e02f74c1bf74ef9bd2).

Try it in your projects, you may catch a few hidden bugs (or at least make your code prettier)!

Note that the CLI now also officially supports
the TSLint configuration file to be written in YAML (the default generated one is in JSON).

## Catch errors in your e2e tests

A slight change has been applied to the default e2e test generated:

    afterEach(async () => {
      // Assert that there are no errors emitted from the browser
      const logs = await browser.manage().logs().get(logging.Type.BROWSER);
      expect(logs).not.toContain(jasmine.objectContaining({
        level: logging.Level.SEVERE
      } as logging.Entry));
    });

This `afterEach` function will run after each one of your tests (obviously) and will report eventual runtime errors.
This can be really useful to catch hidden errors in your e2e tests.

That's all for this release, I hope you enjoyed reading this blog post.
Stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
