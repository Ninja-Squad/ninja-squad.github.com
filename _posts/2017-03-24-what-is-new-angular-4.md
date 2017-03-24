---
layout: post
title: What's new in Angular 4?
author: cexbrayat
tags: ["Angular 2", "Angular", "Angular 4"]
description: "Angular 4 is out! Which new features are included?"
---


🎉 Here we are, Angular 4.0.0 is out, right on schedule ! 🎉

<p style="text-align: center;">
  <a href="https://books.ninja-squad.com/angular" title="Become a ninja with Angular">
    <img class="img-rounded img-responsive" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

Technically there are some breaking changes,
explaining that's why the major version number has changed.
And, if you missed it, there is no Angular 3:
the router package was in version 3.x,
so instead of bumping everything to 3.0 and the router to 4.0,
the team chose to bump everything to 4.0.

The breaking changes are quite limited though,
we updated several of our apps in a few minutes:
nothing too scary.

TypeScript 2.1+ is now required (it was 1.8+ before),
and some interfaces have changed or are deprecated
(rarely used in most applications, like `OpaqueToken` or `SimpleChange`).

TypeScript [2.1](https://blogs.msdn.microsoft.com/typescript/2016/12/07/announcing-typescript-2-1/) and [2.2](https://blogs.msdn.microsoft.com/typescript/2017/02/22/announcing-typescript-2-2/) have brought really nice features you should check out. Angular 4 now supports them (and you will soon be able to activate the new `strictNullChecks` TypeScript option for example).

So what does this new Angular version bring?
Let's dive in!

# Ahead of Time compilation - View Engine

This is probably the biggest change,
even if, as a developer, you will not see the difference.

As you may know, in AoT mode, Angular compiles your templates during the build, and generates JavaScript code (by opposition to the Just in Time mode, where this compilation is done at runtime, when the application starts).

AoT has several advantages: it errors if one of your templates is incorrect at build time instead of having to wait at runtime, and the application starts faster (as the code generation is already done). You also don't have to ship the Angular compiler to your users, so, in theory, the package size should be smaller.
In theory, because the downside is that the generated JS is generally bigger than the uncompiled HTML templates. So, in the vast majority of applications, the package is in fact bigger with AoT.

The team worked quite hard to implement a new View Engine,
that produces less code when you use the Ahead of Time compilation.
The results are quite impressive on large apps,
while still conserving the same performances.

To give you a few numbers, on two medium apps we have,
the bundle sizes went:

- from 499Kb to 187Kb (68Kb to 34Kb after gzip)
- from 192Kb to 82Kb (27Kb to 16Kb after gzip)

That's quite a big difference!

Interesting to note that in the [design doc](https://docs.google.com/document/d/195L4WaDSoI_kkW094LlShH6gT3B7K1GZpSBnnLkQR-g/preview), the Angular team compares the performance (the execution time of course but also the pressure on the memory) with the baseline implementation (best vanilla JS they could write) Angular 2.x and InfernoJS (a really fast React-like implementation).

# Universal

A ton of work has also been done on the Universal project
which allows you to do server-side rendering.
The project was mainly maintained by the community until now,
but, starting with this release, it's now an official Angular project.

# Animations

Animations now have their own package `@angular/platform-browser/animations` (one of the things you may have to change when you update).
This means the bundle you ship to your users will not include useless code if you don't use animations in your app.

# Templates

## template is now ng-template

The `template` tag is now deprecated: you should use the `ng-template` tag instead. It still works though.
It was a bit confusing as `template` is a real HTML tag that Web Component can use.
Now Angular has its own template tag: `ng-template`.
You will have a warning if you use the deprecated `template` somewhere when you update to Angular 4, so it will be easy to spot them.

## ngIf with else

It's now also possible to use an `else` syntax in your templates:

    <div *ngIf="races.length > 0; else empty"><h2>Races</h2></div>
    <ng-template #empty><h2>No races.</h2></ng-template>

## as

Another addition to the template syntax is the `as` keyword,
to simplify the `let` syntax.
It allows to store a result in a variable of the template,
to use it in the element.

It can be useful to store a sliced collection for example:

    <div *ngFor="let pony of ponies | slice:0:2 as total; index as = i">
      {{i+1}}/{{total.length}}: {{pony.name}}
    </div>

Or even more useful, to subscribe only once to a pipe with `async`. If `race` is an observable, instead of the bad and ugly:

    <div>
      <h2>{{ (race | async)?.name }}</h2>
      <small>{{ (race | async)?.date }}</small>
    </div>

you can now use the good:

    <div *ngIf="race | async as raceModel">
      <h2>{{ raceModel.name }}</h2>
      <small>{{ raceModel.date }}</small>
    </div>

# Pipes

## Titlecase

Angular 4 introduced a new `titlecase` pipe.
It changes the first letter of each word into uppercase:

    <p>{{ 'ninja squad' | titlecase }}</p>
    <!-- will display 'Ninja Squad' -->

# Http

Adding search parameters to an HTTP request has been simplified:

    http.get(`${baseUrl}/api/races`, { params: { sort: 'ascending' } });

Previously, you had to do:

    const params= new URLSearchParams();
    params.append('sort', 'ascending');
    http.get(`${baseUrl}/api/races`, { search: params });

# Test

Overriding a template in a test has also been simplified:

    TestBed.overrideTemplate(RaceComponent, '<h2>{{race.name}}</h2>');

Previously, you had to do:

    TestBed.overrideComponent(RaceComponent, {
      set: { template: '<h2>{{race.name}}</h2>' }
    });

# Service

## Meta

A new service has been introduced to easily get or update meta tags:

    @Component({
      selector: 'ponyracer-app',
      template: `<h1>PonyRacer</h1>`
    })
    export class PonyRacerAppComponent {

      constructor(meta: Meta) {
        meta.addTag({ name: 'author', content: 'Ninja Squad' });
      }

    }

# Forms

## Validators

One new validator joins the existing `required`, `minLength`, `maxLength` and `pattern`.
`email` helps you validate that the input is a valid email (good luck finding the correct regular expression by yourself).

## Compare select options

A new directive has been added to help you compare options from a select: `compareWith`.

    <select [compareWith]="byId" [(ngModel)]="selectedPony">
       <option *ngFor="let pony of race.ponies" [ngValue]="pony">{{pony.name}}</option>
    </select>

    byId(p1: PonyModel, p2: PonyModel) {
       return p1.id === p2.id;
    }

# Router

## ParamMap

A new interface has been introduced to represent the parameters
of a URL: `ParamMap`.
Instead of using `params` or `queryParams`,
you should now use `paramMap` or `queryParamMap`,
because they offer the choice between `get()` to get a value,
or `getAll()` to get all values (as query parameters can have multiple values for example).

    const id = this.route.snapshot.paramMap.get('ponyId');
    this.ponyService.get(id).subscribe(pony => this.pony = pony);

or as an Observable:

    this.route.paramMap
      .map((params: ParamMap) => params.get('ponyId'))
      .switchMap(id => this.ponyService.get(id))
      .subscribe(pony => this.pony = pony);

## CanDeactivate

The `CanDeactivate` interface now has an extra (optional) parameter,
containing the next state (where you are going to navigate).
You can now implement clever logic when your user navigates away
from the current component,
depending on where he/she is going.

# I18n

The internationalization is slowly improving with tiny things.
For example, `ngPlural` is now simpler:

    <div [ngPlural]="value">
      <ng-template *ngPluralCase="0">there is nothing</ng-template>
      <ng-template *ngPluralCase="1">there is one</ng-template>
    </div>

compared to what we had to write:

    <div [ngPlural]="value">
      <ng-template *ngPluralCase="'=0'">there is nothing</ng-template>
      <ng-template *ngPluralCase="'=1'">there is one</ng-template>
    </div>

We added a complete chapter on internationalization in our ebook,
with several use cases and best practices described if you want to learn more about i18n!

# Summary

This release brings some nice features and a really welcome improvement of the generated code size,
for the price of very few breaking changes that should not impact you a lot. The migration has been quite smooth for us.

All our materials ([ebook](https://books.ninja-squad.com), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](http://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to lean more!
