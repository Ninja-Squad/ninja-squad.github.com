---
layout: post
title: What's new in Angular CLI 8.3?
author: cexbrayat
tags: ["Angular 8", "Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4", "Angular CLI"]
description: "Angular CLI 8.3 is out! Read all about the new deploy command, the faster builds and new home design!"
---

[Angular CLI 8.3.0](https://github.com/angular/angular-cli/releases/tag/v8.3.0) is out!✨

If you want to upgrade to 8.3.0 without pain (or to any other version, by the way), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (7.2.1 for example), and the target version (8.3.0 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/7.2.1...8.3.0](https://github.com/cexbrayat/angular-cli-diff/compare/7.2.1...8.3.0).
It can be a great help along the official `ng update @angular/core @angular/cli` command.
You have no excuse for staying behind anymore!

Let's see what we've got in this release.

## Deploy command

Th CLI has gained a new `deploy` command!
In fact it's a simple alias to `ng run MY_PROJECT:deploy`,
and does really nothing out of the box.
If you try it in your project, you'll see the following message:

    Cannot find "deploy" target for the specified project.
    You should add a package that implements deployment capabilities for your
    favorite platform.
    For example:
      ng add @angular/fire
      ng add @azure/ng-deploy
      ng add @zeit/ng-deploy
    Find more packages on npm https://www.npmjs.com/search?q=ng%20deploy

As you can see, you need to add a builder to your project,
depending on the platform you are targeting.
For example if you want to deploy to https://zeit.co/now,
you can run `ng add @zeit/ng-deploy` which will automatically configure your project
by adding the necessary configuration to your `angular.json` file and also create a `now.json` file.
You can then simply run `ng deploy` when you want to build and deploy your application 🚀.

[npm](https://www.npmjs.com/search?q=ng%20deploy) lists a lot of different builders,
for example to [deploy on Github](https://www.npmjs.com/package/ngx-gh).
The builder builds your application
and then pushes the result on the `gh-pages` branch of your repository.

## Faster production builds

You have probably noticed that since the [differential loading feature](/2019/05/29/angular-cli-8.0/)
was introduced in Angular CLI&nbsp;8.0
the production build now runs twice
(once for the modern browsers, targeting ES2015, and once for the legacy browser, targeting ES5).
The feature itself is really cool, but `ng build --prod` was effectively taking twice the time.
Angular CLI&nbsp;8.3 changes how the command runs:
- the ES2015 version is built first
- than the resulting bundles are directly downleved to ES5, instead of rebuilt from scratch

The larger your application is, the biggest gain you'll see.
I tried it in one of our projects:

- with CLI 8.2: `ng build --prod` ran in 31,7s for ES2015 and 28,8s for ES5, for a total of 138s.
- with CLI 8.3: `ng build --prod` ran in 32,0s for ES2015 and 🔥~10s🔥 to downlevel to ES5, for a total of 🔥98s🔥.

As this is brand new, if you experience an issue, you can still fall back to the previous behavior with `NG_BUILD_DIFFERENTIAL_FULL=true ng build --prod` for the moment.

## Home page redesign

The home page of a newly generated project has completely changed,
and it looks much nicer.
It also includes helpful links to begin,
and features some common commands.

Look at that 😍:

<p style="text-align: center;">
  <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/2019-08-22/cli-home.png" alt="Angular CLI new home page" />
</p>

As you can see, this 8.3 release has some interesting new features!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
