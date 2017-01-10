---
layout: post
title: What's new in Angular 2.2?
author: cexbrayat
tags: ["Angular 2", "Angular"]
description: "Angular 2.2 is out. What new features are included?"
---

Angular is moving fast, and we already have a minor release: [2.2](https://github.com/angular/angular/blob/master/CHANGELOG.md#220-upgrade-firebooster-2016-11-14)!
This contains the changes from Angular 2.1.x releases and Angular 2.2.0 various betas and RCs.

## Upgrade

The most significant work has been done on the Ahead of Time compilation, and especially on the ngUpgrade support.
That means you'll be able to optimize your application going under migration.
The router has received some love for those who want to migrate their ng1 apps to ng2:
it's now possible to use the Angular Router with the ngUpgrade!

## Forms

One of the new features of this release is a modest contribution from me :)
When you were using a template-driven form,
the syntax was a bit painful to access some methods like `hasError` or `getError`:

    <label>Username</label>
    <input name="username" ngModel required #username="ngModel">
    <div *ngIf="username.control.hasError('required')">Username is required</div>

Now with Angular 2.2+ we can directly access these methods on the local variable,
without the need of accessing the `control` property:

    <label>Username</label>
    <input name="username" ngModel required #username="ngModel">
    <div *ngIf="username.hasError('required')">Username is required</div>

Another feature introduced adds a `ng-pending` class on fields under pending async validations. In Angular, you can add validators on every field or group of fields. Such validators can be synchronous or asynchronous
(for example asking the server if the chosen username is available).
When an asynchronous validation is pending (the HTTP request is not completed yet for example), the `ng-pending` class is added to the field.
You can use it to add some style or a spinner for example.

## Router

The Router Module offers a very handy directive called `RouterLinkActive`,
allowing us to add a specific class if a link is active.
This directive is now exported, and can be used in our templates via a local variable:

    <a routerLink="/races/1" routerLinkActive #route="routerLinkActive">
     Race 1 {{ route.isActive ? '(here)' : ''}}
    </a>

That's all for this small release.
Check out our [ebook](https://books.ninja-squad.com) and [Pro Pack](https://angular-exercises.ninja-squad.com/) if you want to learn more about Angular!
