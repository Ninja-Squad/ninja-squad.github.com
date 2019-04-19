---
layout: post
title: What's new in Angular 8.0?
author: cexbrayat
tags: ["Angular 8", "Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4"]
description: "Angular 8.0 is out! Read about TODO"
---

Angular&nbsp;8.0.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#TODO">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>


## Ivy

TODO

## Queries timing

The `ViewChild` and `ContentChild` decorators now accept a new option called `static`.
Let me explain why with a very simple example using a `ViewChild`:

    <div *ngIf="true">
      <div #dynamicDiv>dynamic</div>
    </div>

Let's get that element in our component
and log it in the lifecycle hooks `ngOnInit` and `ngAfterViewInit`:

    @ViewChild('dynamicDiv') dynamicDiv: ElementRef<HTMLDivElement>;

    ngOnInit() {
      console.log('init dynamic', this.dynamicDiv); // undefined
    }

    ngAfterViewInit() {
      console.log('after view init dynamic', this.dynamicDiv); // div
    }

Makes sense as [AfterViewInit](https://angular.io/api/core/AfterViewInit) is called
when the template initialization is done.

But in fact, if the queried element is static (not wrapped in an `ngIf` or an `ngFor`),
then it is available in `ngOnInit` also:

    <h1 #staticDiv>static</h1>

gives:

    @ViewChild('staticDiv') staticDiv: ElementRef<HTMLDivElement>;

    ngOnInit() {
      console.log('init static', this.staticDiv); // div
    }

    ngAfterViewInit() {
      console.log('after view init static', this.staticDiv); // div
    }

I don't think this is documented, or recommended,
but that's how it currently works.

With Ivy though, the behavior changes to be more consistent:

    ngOnInit() {
      console.log('init static', this.staticDiv); // undefined (changed)
    }

    ngAfterViewInit() {
      console.log('after view init static', this.staticDiv); // div
    }

A new `static` flag has been introduced to not break existing applications,
so if you want to keep the old behavior even when you'll switch to Ivy,
you can write:

    @ViewChild('static', { static: true }) static: ElementRef<HTMLDivElement>;

and the behavior will be the same as currently
(the element is also accessible in `ngOnInit`).

Note that if you add `static: true` on a dynamic element (wrapped in a condition or a loop),
then it will not be accessible in `ngOnInit` nor in `ngAfterViewInit`!

`static: false` will be how Ivy behaves by default.

To not break existing applications and to ease the migration,
the Angular team wrote a schematic that automatically analyzes your application,
and adds the `static` flag.
It even offers two strategies:
- one based on your templates, which will make sure that your application works
(so it tends to mark queries as static even they aren't).
You are sure it works,
but it exposes you to problems if you wrap your static element in a condition or a loop later.
- one based on your usage of the query,
which is more error-prone (as it is harder for the schematic to figure it out),
but will not mark the queries as static if they don't need to be.
So most queries will have `static: false`, which will be the default in Ivy.
You will be prompted which strategy you want to use when updating.

When migrating our own applications,
I preferred using the usage strategy to avoid having `static: true` where it is not necessary.

This is what the migration looks like (with a failure in one component):

    ------ Static Query migration ------
    In preparation for Ivy, developers can now explicitly specify the
    timing of their queries. Read more about this here:
    https://github.com/angular/angular/pull/28810

    There are two available migration strategies that can be selected:
      • Template strategy  -  migration tool (short-term gains, rare corrections)
      • Usage strategy  -  best practices (long-term gains, manual corrections)
    For an easy migration, the template strategy is recommended. The usage
    strategy can be used for best practices and a code base that will be more
    flexible to changes going forward.

    Some queries cannot be migrated automatically. Please go through
    those manually and apply the appropriate timing:
    ⮑   home/home.component.ts@43:3: undefined

Note that this only concern `ViewChild` and `ContentChild`,
not `ViewChildren` and `ContentChildren`
(which will work the same way in Ivy and View Engine).

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
