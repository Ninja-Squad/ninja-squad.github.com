---
layout: post
title: Angular Performances Part 5 - Pure pipes, attribute decorator and other tips
author: cexbrayat
tags: ["Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4", "Angular CLI", "performances", "benchmarks"]
description: "Learn how to make your Angular application faster. In this last part, let's talk about how you improve the runtime performances with pure pipes, the attribute decorator and other tips."
---

This is the last part of this series (check the [first part](/2018/09/06/angular-performances-part-1/), the [second one](/2018/09/13/angular-performances-part-2/), the [third one](/2018/09/20/angular-performances-part-3/) and the [fourth one](/2018/09/27/angular-performances-part-4/) if you missed them), and this blog post is about how you can improve the runtime performances of your Angular application with pure pipes, the attribute decorator and other tips.
If you are the lucky owner of our ebook, you can already check the other parts if you download the [last ebook release](https://books.ninja-squad.com/claim?book=Angular).


Now that we have talked about first load, reload, profiling and change detection strategies
we can continue our exploration of the tips for better runtime performances.

## Pure pipes

As you know, you can build your own pipes to format and display your data.
For example, to display the full name of a user,
you can either write a method in your component:

{% raw %}
    @Component({
      selector: 'ns-menu',
      template: `
          <p>{{ userName() }}</p>
          <p>...</p>
          <p>{{ userName() }}</p>
      `
    })
    export class MenuComponent {

      user: UserModel = {
        id: 1001,
        firstName: 'Jane',
        lastName: 'Doe',
        title: 'Miss',
      };

      userName() {
        return `${this.user.title}. ${this.user.firstName} ${this.user.lastName}`;
      }
    }
{% endraw %}

or write a custom pipe to encapsulate this logic:

{% raw %}
    @Component({
      selector: 'ns-menu',
      template: `
          <p>{{ user | displayName }}</p>
          <p>...</p>
          <p>{{ user | displayName }}</p>
      `
    })
    export class MenuComponent {

      user: UserModel = {
        id: 1001,
        firstName: 'Jane',
        lastName: 'Doe',
        title: 'Miss',
      };
    }
{% endraw %}

with `DisplayNamePipe` looking like:

{% raw %}
    @Pipe({
      name: 'displayName'
    })
    export class DisplayNamePipe implements PipeTransform {

      transform(user: UserModel): string {
        return `${user.title} ${user.firstName} ${user.lastName}`;
      }

    }
{% endraw %}

This takes a little bit more work,
but writing a pipe allows to reuse it in other components.

What you may not know is that using a pipe is also more performant.
By default, a pipe is "pure".
In computer science, we call "pure" a function that has no side effect,
and whose result only depends on its entries.
A pure pipe is pretty much the same:
the result of its `transform` method only depends on arguments.
Knowing that, Angular applies a nice optimization:
the `tranform` method is only called if the reference of the value it transforms changes
or if one of the other arguments changes
(yes, a bit like the `OnPush` strategy for components).

It means that whereas a method of a component is called on every change detection,
a pure pipe will only be executed when needed,
and only once in a template if it is used with the same input value and arguments (as in my example).

By default, a custom pipe is pure, so that's great!
But sometimes it's not a right fit.

In my example, if we mutate the user to set its `firstName` to a different value,
the pipe never refreshes...
It's pretty much the same issue that we had with the `OnPush` strategy:
the reference of the value doesn't change,
so the pipe does not run again.

Here you have two solutions:

- carefully use the pipe with immutable objects
(do not mutate the user, create a new user with the new `firstName`);
- mark the pipe as "impure", and Angular will run it every time.
You lose a tiny bit in performance, but you are sure that the displayed value is refreshed.

To mark a pipe as impure, just add `pure: false` in its decorator:

    @Pipe({
      name: 'displayName',
      pure: false
    })
    export class DisplayNameImpurePipe implements PipeTransform {

      transform(user: UserModel): string {
        return `${user.title} ${user.firstName} ${user.lastName}`;
      }

    }

To sum up:

- a pure pipe is not called as often as a method in a component
- but it doesn't run again if the input value is mutated, so use carefully.

## Split your template wisely

Based on what we learned, here is a trick that doesn't use a specific Angular API,
but can be easily understood.

Let's say you have a component displaying a huge list of results,
and an input allowing to update this list.
As you don't want to update the list on every key pressed,
you are debouncing what the user types, and then update the list.
Something like:

{% raw %}
    @Component({
      selector: 'ns-results',
      template: `
        <input [formControl]="search">
        <h1>{{ resultsTitle() }}</h1>
        <div *ngFor="let result of results">{{ result }}</div>
      `
    })
    export class ResultsComponent implements OnInit {

      search = new FormControl('');
      results: Array<string> = [];

      constructor(private searchService: SearchService) {
      }

      ngOnInit() {
        this.search.valueChanges
          .pipe(
            debounceTime(500),
            switchMap(query => this.searchService.updateResults(query))
          )
          .subscribe(results => this.results = results);
      }

      resultsTitle() {
        return `${this.results.length} results`;
      }
    }
{% endraw %}

You may think that the change detection is not very often called,
as you update the list only when the user has stopped typing.
But in fact the change detection is called on every event in the template
(so here on every key pressed).
You can check it out by adding a simple `console.log` in `resultTitle`,
and see it called in the developer console on every key pressed.

To avoid detecting change on the list elements even if not needed
(as the results will not change on every new value, but only after some time),
the idea is to split your view into two parts,
and to introduce a sub-component to display the results.
This component can be switched to `OnPush`
and the change detection will only update it when really needed,
and not on every key press.

    @Component({
      selector: 'ns-results',
      template: `
        <input [formControl]="search">
        <ns-results-list [results]="results"></ns-results-list>
      `
    })
    export class ResultsComponent implements OnInit {

      search = new FormControl('');
      results: Array<string> = [];

      constructor(private searchService: SearchService) {
      }

      ngOnInit() {
        this.search.valueChanges
          .pipe(
            debounceTime(500),
            switchMap(query => this.searchService.updateResults(query))
          )
          .subscribe(results => this.results = results);
      }
    }

With the sub-component looking like:

{% raw %}
    @Component({
      selector: 'ns-results-list',
      template: `
        <h1>{{ resultsTitle() }}</h1>
        <div *ngFor="let result of results">{{ result }}</div>
      `,
      changeDetection: ChangeDetectionStrategy.OnPush
    })
    export class ResultsListComponent {

      @Input() results: Array<string> = [];

      resultsTitle() {
        return `${this.results.length} results`;
      }
    }
{% endraw %}

This is a simple pattern to use,
often referred to as the smart/dumb component pattern:
a smart component deals with data loading, event handling, etc.,
and simply passes the data to display as input to a second, dumb component.
The only responsibility of the dumb component is to display the data,
and to emit events to its parent smart component using outputs.
This dumb component is the one with the large template,
containing many expressions.
But since its state only changes when its smart parent passes a new input,
it can use OnPush and thus saves a lot of expression evaluations.

## Attribute decorator

When using an `@Input()` in a component,
Angular assumes that the value passed as input can change,
and does what it takes to detect the change and pass the new value to the component.
Sometimes, it's not really necessary,
as you may want to only pass a value once to initialize the component
and never change it.
In this very specific case, you can use the `@Attribute()` decorator
instead of the `@Input()` one.

Let's consider a button component,
to which you want to pass a type to set its aspect
(something like `primary`, `success`, `warning`, `danger`...).

Using an input, it would look like:

{% raw %}
    import { Component, Input } from '@angular/core';

    @Component({
      selector: 'ns-button',
      template: `
        <button type="button" class="btn btn-{{ btnType }}">
          <ng-content></ng-content>
        </button>`
    })
    export class ButtonComponent {

      @Input() btnType;
    }
{% endraw %}


that you can use with:


    <ns-button btnType="primary">Hello!</ns-button>
    <ns-button btnType="success">Success</ns-button>

Since the input is a simple string that never changes,
you can switch to use an attribute:

{% raw %}
    import { Attribute, Component } from '@angular/core';

    @Component({
      selector: 'ns-button',
      template: `
        <button type="button" class="btn btn-{{ btnType }}">
          <ng-content></ng-content>
        </button>`
    })
    export class ButtonComponent {

      constructor(@Attribute('btnType') public btnType: string) {}
    }
{% endraw %}

This produces a "bind-once" like effect,
avoiding Angular to do unnecessary work.
But keep in mind this only works with non-dynamic, string inputs.

## Conclusion

This series of blog posts hopefully taught you some techniques which can help solve performance problems.
But remember the golden rules of performance optimization:

* don't
* don't... yet
* profile before optimizing.

As a famous computer scientist said:

> Premature optimization is the root of all evil. - Donald Knuth

So strive to make the code as simple and correct and readable as possible,
and only start thinking about profiling, then optimizing,
if you have a proven performance problem.

If you enjoyed this blog post, you may want to dig deeper with our [ebook](https://books.ninja-squad.com/angular),
and/or with a complete exercise that we added in our [online training](https://angular-exercises.ninja-squad.com/).
The exercise takes an application and walks you through what we would do to optimize it,
measuring the benefits of each steps, showing you how to avoid the common traps,
how to test the optimized application, etc. Check it out if you want to learn more!
