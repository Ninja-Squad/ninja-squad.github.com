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

TODO

## TypeScript 3.4

Angular&nbsp;8.0 now supports TypeScript 3.4,
and even requires it, so you'll need to upgrade.

You can checkout out what [TypeScript 3.3](https://devblogs.microsoft.com/typescript/announcing-typescript-3-3/) and [TypeScript 3.4](https://devblogs.microsoft.com/typescript/announcing-typescript-3-4/) brings on the Microsoft blog.

## Ivy

Ivy is obviously a huge part of this release,
and it took most of effort from the team these last month.
There is so much to say about Ivy that I wrote a
[dedicated article about it](/2019/05/07/what-is-angular-ivy/).

TL;DR: Ivy is the new compiler/runtime of Angular. It will enable very cool features in the future,
but it is currently focused on not breaking existing applications.

Angular&nbsp;8.0 is the first release to officially offer a switch to opt-in into Ivy.
There are no real gains to do so,
but you can give it a try to see if nothing breaks in your application.
Because, at some point, probably in v9, Ivy will be the default.
So the Angular team hopes the community will give a try to Ivy,
and that we'll catch all the remaining issues before v9.

We tried it on several of our apps and already caught a few regressions,
so we would strongly advised to not use it blindly in production 😄.

If you feel adventurous, you can add `"enableIvy": true` in your `angularCompilerOptions`,
and restart your application: it now uses Ivy!

## Forms

### markAllAsTouched

The `AbstractControl` class now offers a new method `markAllAsTouched`
in addition to the existing `markAsDirty`, `markAsTouched`, `markAsPending`, etc.
`AbstractControl` is the parent class of `FormGroup`, `FormControl`, `FormArray`,
so the method is available on all reactive forms entites.

Like `markAsTouched`, this new method marks a control as `touched`
but also all its descendants.

### FormArray.clear

The `FormArray` class now also offers a `clear` method,
to quickly remove all the controls it contains.
You previously had to loop over the controls to remove them one by one.

## Router

### Lazy-loading with `import()` syntax

## Service worker

Previously, it was not possible to have multiple apps (using
`@angular/service-worker`) on different subpaths of the same domain,
because each Service Worker would overwrite the caches of the others...
This is now fixed!

## Notable and breaking changes

A few things have changed and require some work from your part.
Some of the changes are driven by Ivy,
and are there to prepare our applications.
But the cool news is that the Angular team already wrote schematics
to make our life easier.

Simply run `ng update @angular/core` and the update schematics will run
and update your code.
What do these schematics do? Let's find out!

### Queries timing

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

### Template variable reassignment

Currently with View Engine, doing something like:

{% raw %}
    <button
      *ngFor="let option of options"
      (click)="option = 'newButtonText'">{{ option }}</button>
{% endraw %}

works.

In Ivy, that won't be the case anymore:
it will not be possible to reassign a value to a template variable (here `option`).
To prepare the sitch to Ivy, a schematic analyzes your templates
when you upgrade to Angular&nbsp;8.0
and warn you if that's the case.

You then have to manually fix it:

{% raw %}
    <button
      *ngFor="let option of options; index as index"
      (click)="options[index] = 'newButtonText'">{{ option }}</button>
{% endraw %}

### Deprecated HTTP package removed

`@angular/http` has been removed from 8.0,
after being [replaced by `@angular/common/http` in 4.3](/2017/07/17/http-client-module/)
and [officially deprecated in 5.0](/2017/11/02/what-is-new-angular-5/),
18 months ago.
You have probably already migrate to `@angular/common/http`,
but if you didn't, now you have to.


All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
