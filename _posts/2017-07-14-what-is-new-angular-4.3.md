---
layout: post
title: What's new in Angular 4.3?
author: cexbrayat
tags: ["Angular 2", "Angular", "Angular 4"]
description: "Angular 4.3 is out! Which new features are included?"
---

Angular 4.3.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#430-TODO">
    <img class="img-rounded img-responsive" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This is a fairly big release, with a new `HttpClientModule`,
a complete rewrite of the `HttpModule`💅!
This should be the last minor release before Angular 5, when we can expect some other exciting stuff!

# HttpClientModule

The biggest feature of this release is without a doubt the new `HttpClientModule`. This module is a complete rewrite of the current `HttpModule` that had some defaults, like the obligation to extract the JSON from the response for every request, no mechanism to handle requests and responses in a generic fashion, and a quite awful testing API.

The new `HttpClientModule` is a really cool alternative:
it solves all these issues, and we migrated our applications fairly easily.
And it was mostly code deletions💖.

We made a little video to show you the difference,
and a complete article to help you to migrate your applications.

It showcases the brand new `HttpClient` service, how to write unit tests,
and how to use the new interceptors!

<div class="video-wrapper">
    <iframe width="560" height="315" frameborder="0" allowfullscreen
    src="https://www.youtube.com/embed/jIgUrfXmrLM"></iframe>
</div>

Check out [the article we wrote that explains](/2017/07/14/http-client-module/) in deep how to use this new module!

# Router

A few events have been added to the router, if you need to know when a resolver or a guard are run:

- `ResolveStart`, `ResolveEnd`
- `GuardsCheckStart`, `GuardsCheckEnd`

# Forms

The two new validators `min` and `max` released with 4.2 have been temporarily rolled back as they were breaking changes :(. They'll return in a major release, maybe 5.0.0.

# Style

You may know that the `/deep/` "shadow-piercing" combinator can be used to force a style down to child components. This selector had an alias `>>>` and now has another one called `::ng-deep`.

Be warn though: the `/deep/` combinator has been [deprecated from the Shadow DOM spec](https://www.chromestatus.com/features/6750456638341120) and is being removed from all major browsers. So the support will probably also be dropped by Angular in the future. Until then, it is recommended to use `::ng-deep`, and to only use it with emulated view encapsulation.

# Compiler

This is not really a new feature, but I think it is interesting to understand how things work under the hood.

TypeScript 2.3 recently introduced the concept of [transformers](https://github.com/Microsoft/TypeScript/pull/13940) in the compiler API.
That means some teams can write custom transformations/plugins that are applied to the code compiled by `tsc`. This is not really something that we will write you and me, but Angular has its own compiler called `ngc` that wraps `tsc`.

Until now, the process for `ngc` was to compile your templates to generate TypeScript files, and then call `tsc` to compile your TypeScript code and the TypeScript files generated to JavaScript. If that sounds strange, you can check out our ebook where we explain all this.

With the introduction of transformers, `tsc` works slightly differently:
it starts by parsing the files, does the type-checking, applies any plugin you want, and then generates JavaScript.

Based on this, `ngc` is now becoming a plugin called in the TypeScript compilation pipeline, rather than a wrapper of the TypeScript compiler.

As Angular developers, we can expect to have very precise type-checking in our templates, referring to the exact line of the problem in HTML source file!

# Summary

That's all for this release: the next important one will be 5.0!

In the meantime, all our materials ([ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](http://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
