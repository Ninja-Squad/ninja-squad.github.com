---
layout: post
title: What's new in Angular 2.1?
author: cexbrayat
tags: ["angular2"]
description: "Angular 2.1 is out. What new features are included?"
---

Angular is moving fast, and we already have a minor release: [2.1](https://github.com/angular/angular/blob/master/CHANGELOG.md#210-incremental-metamorphosis-2016-10-12)!

If you haven't heard, Angular is planning to have patch updates every week,
minor releases every month, and major releases every 6 months.

That means Angular 3 should be Q1 or Q2 of 2017!

We plan to blog a little about each new release,
to introduce you to the newest changes.
We'll ignore the tons of bug fixes, perf improvements and changes to ngUpgrade,
to only focus on the new features.

This blog post contains the changes from Angular 2.0.x releases
and Angular 2.1.0 various betas and RCs.

## Router, modules, lazy-loading and pre-loading

The router comes with a really amazing feature
allowing to lazy-load parts of your application.
Instead of shipping a big bundle containing your whole application when your user lands on your home page,
you can instead use this feature to only deliver the module he/she needs for this page,
and then fetch the other modules only when required.
Instead of paying the price of the load time once,
you pay a smaller price, several times. And your initial load is faster!

But we can now do slightly better, with the 2.1.0 release.
We can now define a strategy for pre-fetching the modules, even before the user needs them.
Angular comes with a built-in strategy `PreloadAllModules` that will preload all modules as soon as possible.
But you can also define your own strategy, to load only a few modules depending on your business logic
(if the user is not an Administrator, maybe you can safely ignore the `AdminModule` for example).

## Animations

Angular also comes with a great support for animations,
with a custom DSL to define them.
Angular 2.1.0 comes with two handy aliases `:enter` and `:leave`,
to define animations that should run when the component is created or deleted.

    @Component({
      animations: [
        trigger('myAnimation', [
          transition(':enter', [
            style({'opacity': 0}),
            animate('500ms', style({opacity: 1}))
          ])
        ])
      ]
    })
    export class AnimatedComponent {

With this animation, the component will slowly "fade in"
as you can see on that [plunker](http://plnkr.co/edit/3Y0ODbdFiCkh6XGrxFRA?p=preview).

That's all for this small release.
Check out our [ebook](https://books.ninja-squad.com) and [Pro Pack](https://angular2-exercises.ninja-squad.com/) if you want to learn more about Angular!
