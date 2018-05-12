---
layout: post
title: What's new in Angular CLI 1.3?
author: cexbrayat
tags: ["Angular 2", "Angular", "Angular 4", "Angular CLI"]
description: "Angular CLI 1.3 is out! Which new features are included?"
---

[Angular CLI 1.3.0](https://github.com/angular/angular-cli/releases/tag/v1.3.0) is out with some nice new features!

It now officially supports ES2017 and TypeScript 2.4 and is ready for Angular 5 (which should be out shortly).

You can check out what files you need to update using [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff),
for example if you are currently using 1.2.1:
[angular-cli-diff/compare/1.2.1…1.3.0](https://github.com/cexbrayat/angular-cli-diff/compare/1.2.1...1.3.0)

Let's see what new features we have!

## Bundle sizes

The Angular team is putting a ton of work to generate the smallest bundles possible.
Angular CLI uses Webpack 3 and now leverages its [scope hoisting feature](https://medium.com/webpack/webpack-3-official-release-15fd2dd8f07b)
which resulted in some nice gains, but there is still room for improvements.

The Angular team is working on a better tree-shaking with a new project [`@angular/devkit`](https://github.com/angular/devkit), that the CLI now uses.
It's a bit experimental, so it's behind a new flag called `--build-optimizer`.
It does some manipulations on your compiled code, like folding the static properties inside the class,
scrubbing the Angular specific decorators and metadata (that are unneeded when you have compiled in AoT mode), adding a `/*@__PURE__*/` comment on classes, etc.
All these actions aim for the same goal: helping Webpack and Uglify to do a better tree-shaking
and a better dead code elimination.

And all that gives us smaller bundles \o/
I tested it on a medium-size application:

Size without `--build-optimizer`: 871K (211K gzip)

With `--build-optimizer`: 778K (192K gzip)

That's a small but nice win.
But for others it resulted in massive gains!
So it can be interested for you, especially if you are using Angular Material
(check the comments of [this issue](https://github.com/angular/material2/issues/4137)).

You can read more about how this feature works [here](https://github.com/angular/devkit/tree/master/packages/angular_devkit/build_optimizer).
Be warned that it is experimental though, and can break your app, so be careful...

## Named chunks

While we are talking about building the application,
a new flag, called `--named-chunks`, will generate nicely named chunks.
Until now, if you had lazy-loaded modules in your application,
the bundles looked like that:

    main.bundle.js
    0.chunk.js
    1.chunk.js

With this new flag, the CLI names it with the names of the Angular modules:

    main.bundle.js
    users.module.chunk.js
    admin.module.chunk.js

This is the default in development mode so you don't even have to add the flag to your command,
but it's not the default in production mode.

## Server side rendering

The SSR is getting better and better,
and the CLI now has a piece of documentation to guide you,
check it out: [universal rendering](https://github.com/angular/angular-cli/wiki/stories-universal-rendering).
It's honestly still very early days, and won't work with most apps (no lazy-loading support for example).

## Proxy configuration

It's possible to define a proxy configuration since some time now,
and it's quite useful as you can for example forward all the requests to an API
to a local server running on your machine (really useful when you are developing the backend too).

    {
      "/api": {
        "target": "http://localhost:9000",
        "secure": false
      }
    }

But you had to manually give it to the `serve` command every time,
like `ng serve --proxy-config proxy.conf.json`,
which was a bit painful.

You can now specify a `proxyConfig` in your `.angular-cli.json` file,
and `ng serve` will pick it up automatically.

Check out our [ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular) if you want to learn more!
