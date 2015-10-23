---
layout: post
title: What we learnt at Angular Connect
author: cexbrayat
tags: ["Angular 2"]
description: "Angular Connect took place the 20-21 October in London, and we learnt a few things on AngularJS 1.x and Angular 2"
---

Last week took place the [AngularConnect](http://angularconnect.com/) conference in London,
one of the few events where you can hear the Angular core team talking about AngularJS 1.x and,
of course, Angular 2. Let's have a look at what we learned during these days packed with awesome talks!

# Beta or not beta ?

First, we don't have a date for the beta release.
There are still a few important features missing and bugs to crush before that,
and also lots of documentation to write.
But the beta is not that far, probably a matter of a few months, if I had to make a bet.
I've been upgrading our ebook to the latest alpha releases, and I love the way the project evolves:
it's usually a matter of deleting code (yay!) and renaming things (that's more painful for me, as you can imagine).
The concepts are now solid and well established. The performance is very good according to the benchmarks, but, well, you know, benchmarks...
It has been announced that IE9 will be supported, I'm sure that it will please some of you.

# Angular CLI

The `angular-cli` project has been officially announced: a small tool allowing to create a project skeleton,
with a build system and dependencies already configured. The project is based on `ember-cli`, a tool that a lot of Ember developers really like.
It's still very early, but you can create a project and launch it:

    npm install -g angular-cli
    ng new cli-test && cd cli-test
    ng serve

You can also generate new components or services and package the app.
Right now, only TypeScript is supported, but I guess every language will be soon.
It's worth mentioning that the build tool is Broccoli, the same used by `ember-cli`.
The same addon system is planned, so in the end we will have a complete
eco-system allowing to test, package, report and deploy easily with our favorite tools.
I think it's a great idea, because we will have a shared convention for project architecture and best practices.

# Batarangle

Talking about eco-system, [Batarangle](https://github.com/rangle/batarangle), a chrome extension for inspecting Angular 2 apps, was demoed.
On a todo app of course (it doesn't work yet with my Angular 2 apps).
I think we will see other great tools like this one, as the architecture of Angular 2 allows being notified
on every change and thus storing and replaying actions (a la [Elm Time Travel Debugger](http://debug.elm-lang.org/)).
We could also have detailed stats on performance to find the bottlenecks in our apps.

# Modules

Each of the main modules (Http, Router, Animation, Tests...) has its talk.
As I follow closely the Angular 2 repository, I think it's worth saying that
the router module has great concepts but is still buggy, and that the tests API is not very friendly yet.
But testing in Angular 2 will be pretty awesome when it's done: I've got 300+ unit tests for the ebook,
so I can fairly say that you'll enjoy it.
I've not played with the animation module but it looks really amazing, with complete programmatic control,
orchestration, sequencing and time-traveling.

# Rendering targets

A few talks were dedicated to building Angular 2 apps that don't necessarily live in the browser.
The rendering/compiler architecture allows other targets like server-side
rendering and native mobile development with [NativeScript](https://www.nativescript.org/),
or running your app in a Web Worker.
The mobile developers were spoiled with the announcement of [Ionic 2 (alpha)](http://ionic.io/2).

# AngularJS 1.x and the migration path

AngularJS 1.x is not abandoned, with the 1.5 release in sight, and will be supported for some time.
The new features are mainly oriented to ease the upgrade to Angular 2.
The migration path is getting clearer with the `ngUpgrade` module, which will allow to build ng1 apps with ng2 components,
and vice-versa. This is also very fresh, but I intend to experiment with this and let you know how it goes.
`ngForward`, a [community-driven project](https://github.com/ngUpgraders/ng-forward),
is also under development to let us develop AngularJS 1.x apps with Angular 2 syntax.

TypeScript and RxJS were also hot topics in the conference: that's great because there are the next episodes on [`The Road to Angular 2`](/tags.html#Angular 2-ref)!
