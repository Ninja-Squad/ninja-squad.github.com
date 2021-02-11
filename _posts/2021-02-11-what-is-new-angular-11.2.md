---
layout: post
title: What's new in Angular 11.2?
author: cexbrayat
tags: ["Angular 11", "Angular"]
description: "Angular 11.2 is out!"
---

Angular&nbsp;11.2.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#1120-2021-02-10">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

Only three weeks went by since v11.1, so this is a very small release.

## QueryList has a new option

You may know that, when using a `@ContentChildren` or a `@ViewChildren` decorator
on a field, you can subscribe to the changes of this list.
The weird thing is that you get a notification when the list is recomputed,
even if it is the same list in some cases!

      <div *ngIf="show">
        <div *ngIf="false"> <!-- never displayed -->
          <ns-pony *ngFor="let pony of raceModel.ponies"></ns-pony>
        </div>
      </div>
      <ns-pony *ngFor="let pony of raceModel.ponies"></ns-pony>

If you have a template like this one above,
and a component with a query to find all the `PonyComponent`s:

    @ViewChildren(PonyComponent) ponies: QueryList<PonyComponent>;

    ngAfterViewInit(): void {
      this.ponies.changes.subscribe(newList => console.log(newList.length));
    }

Then the log trace will be displayed if the first `*ngIf` condition changes,
even if the the result of the query list is the same.

To avoid that, a new `emitDistinctChangesOnly` option has been added to
the `@ViewChildren` and `@ContentChildren` decorators.

    @ViewChildren(PonyComponent, { emitDistinctChangesOnly: true }) ponies: QueryList<PonyComponent>;

With this option, the subscription will not fire if the list is recomputed
and hasn't changed.
You can add it to your queries as the default is `false` for now,
but it will be `true` in the future (maybe in v12).

## Compiler performances

Some projects saw a regression in their compilation times,
maybe related to the new CLI pipeline.
A workaround is to use `NG_BUILD_IVY_LEGACY=1 ng serve`,
and the team is currently working on this issue (tracked [here](https://github.com/angular/angular/issues/40635)).

A plan has been established to improve the compilation times
(tracked [here](https://github.com/angular/angular/issues/40728)).
One feature landed in this release:
if you change the template of a component,
the rebuild (`ng serve`) should be faster,
as the compiler is now smart enough to only check the template you changed.
Indeed, you can't break another part of the application when you just change the template of a component: you can just break this component.

We'll hopefully see faster compilation times in the future releases.

You can check what's new in the CLI for this v11.2 release in [our other blog post](/2021/02/11/angular-cli-11.2/).
The next one will be v12.0, and it should include some new features,
stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!