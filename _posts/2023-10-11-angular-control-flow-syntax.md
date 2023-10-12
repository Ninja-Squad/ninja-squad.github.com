---
layout: post
title: Angular templates got better - the Control Flow syntax
author: cexbrayat
tags: ["Angular 17", "Angular"]
description: "Angular 17 introduces a brand new template syntax to replace *ngIf/*ngFor/*ngSwitch. Let's dive in!"
---

Angular v17 introduces a new "developer preview" feature called "control flow syntax".
This feature allows you to use a new template syntax to write control flow statements, like if/else, for, and switch,
instead of using the built-in structural directives (`*ngIf`, `*ngFor`, and `*ngSwitch`).

To understand why this was introduced, let's see how structural directives work in Angular.

## Structural directives under the hood

Structural directives are directives that change the structure of the DOM by adding, removing, or manipulating elements.
They are easy to recognize in Angular because they begin with an asterisk `*`.

But how do they _really_ work?

Let's take a simple template with `ngIf` and `ngFor` directives as an example:

{% raw %}
    <h1>Ninja Squad</h1>
    <ul *ngIf="condition">
      <li *ngFor="let user of users">{{ user.name }}</li>
    </ul>
{% endraw %}

If you read the chapter of our ebook about the Angular compiler,
you know that the framework generates JavaScript code from this template.
And maybe you imagine that `*ngIf` gets converted to a JavaScript `if`
and `*ngFor` to a `for` loop like:

    createElement('h1');
    if (condition) {
      createElement('ul');
      for (user of users) {
        createElement('li');
      }
    }

But Angular does not work exactly like that:
the framework decomposes the component's template into "views".
A view is a fragment of the template that has static HTML content.
It can have dynamic attributes and texts, but the HTML elements are stable.

So our example generates in fact three views,
corresponding to three parts of the template:

Main view:
{% raw %}
    <h1>Ninja Squad</h1>
    <!-- special comment -->
{% endraw %}

NgIf view:
{% raw %}
    <ul>
      <!-- special comment -->
    </ul>
{% endraw %}

NgFor view:
{% raw %}
    <li>{{ user.name }}</li>
{% endraw %}

This is because the `*` syntax is in fact syntactic sugar
to apply an attribute directive on an `ng-template` element.
So our example is the same as:

{% raw %}
    <h1>Ninja Squad</h1>
    <ng-template [ngIf]="condition">
    <ul>
      <ng-template ngFor [ngForOf]="users" let-user>
        <li>{{ user.name }}</li>
      </ng-template>
    </ul>
    </ng-template>
{% endraw %}

Here `ngIf` and `ngFor` are plain directives.
Each `ng-template` then generates a "view".
Each view has a static structure that never changes.
But these views need to be dynamically inserted at some point.
And that's where the `<!-- special comment -->` comes into play.

Angular has the concept of `ViewContainer`.
A `ViewContainer` is like a box where you can insert/remove child views.
To mark the location of these containers,
Angular uses a special HTML comment in the created DOM.

That's what `ngIf` actually does under the hood:
it creates a `ViewContainer`, and then, when the condition given as input changes,
it inserts or removes the child view at the location of the special comment.

This view concept is quite interesting as it will allow Angular
to only update views that consume a signal in the future,
and not the whole template of a component!
Check out out our [blog post about the Signal API](/2023/04/26/angular-signals/) for more details.

## Custom structural directives

You can create your own structural directives if you want to.
Let's say you want to write a `*customNgIf` directive.
You can create a directive that takes a condition as an input and
injects a `ViewContainerRef` (the service that allows to create the view)
and a `TemplateRef` (the `ng-template` on which the directive is applied).

    import { Directive, DoCheck, EmbeddedViewRef, Input, TemplateRef, ViewContainerRef } from '@angular/core';

    @Directive({
      selector: '[customNgIf]',
      standalone: true
    })
    export class CustomNgIfDirective implements DoCheck {
      /**
      * The condition to check
      */
      @Input({ required: true, alias: 'customNgIf' }) condition!: boolean;

      /**
      * The view created by the directive
      */
      conditionalView: EmbeddedViewRef<any> | null = null;

      constructor(
        /**
        * The container where the view will be inserted
        */
        private vcr: ViewContainerRef,
        /**
        * The template to render
        */
        private tpl: TemplateRef<any>
      ) {}

      /**
      * This method is called every time the change detection runs
      */
      ngDoCheck() {
        // if the condition is true and the view is not created yet
        if (this.condition && !this.conditionalView) {
          // create the view and insert it in the container
          this.conditionalView = this.vcr.createEmbeddedView(this.tpl);
        } else if (!this.condition && this.conditionalView) {
          // if the condition is false and the view is created
          // destroy the view
          this.conditionalView.destroy();
          this.conditionalView = null;
        }
      }
}

This works great!
And as you can see, it lets developers like us create powerful structural directives if we want to:
the built-in directives offered by Angular are not special in any way.

But this approach has some drawbacks:
for example, it is a bit clunky to have an `else` alternative with `*ngIf`:


{% raw %}
    <div *ngIf="condition; else elseBlock">If</div>
    <ng-template #elseBlock><div>Else</div></ng-template>
{% endraw %}

`elseBlock` is another input of the `NgIf` directive,
of type `TemplateRef`, that the directive will display if the condition is falsy.
But this is not very intuitive to use, so we often see this instead:

{% raw %}
    <div *ngIf="condition">If</div>
    <div *ngIf="!condition">Else</div>
{% endraw %}

The structural directives are also not perfect type-checking-wise.
Even if Angular does some magic (with some special fields called `ngTemplateGuard` in the directives to help the type-checker),
some cases are too tricky to handle.
For example, the "else" alternative of `*ngIf` is not type-checked:

{% raw %}
    <div *ngIf="!user; else userNotNullBlock">No user</div>
    <ng-template #userNotNullBlock>
      <div>
        <!-- should compile as user is not null here -->
        <!-- but it doesn't -->
        {{ user.name }}
      </div>
    </ng-template>
{% endraw %}

`NgSwitch` is even worse, as it consists of 3 separate directives
`NgSwitch`, `NgSwitchCase`, and `NgSwitchDefault`.
The compiler has no idea if the `NgSwitchCase` is used in the right context.

{% raw %}
    <!-- user.type can be `'user' | 'anonymous'` -->
    <ng-container [ngSwitch]="user.type">
      <div *ngSwitchCase="'user'">User</div>
      <!-- compiles even if user.type can't be 'admin' -->
      <div *ngSwitchCase="'admin'">Admin</div>
      <div *ngSwitchDefault>Unknown</div>
    </ng-container>
{% endraw %}

It's also worth noting that the `*` syntax is not very intuitive for beginners.
And structural directives depend on the `ngDoCheck` lifecycle hook,
which is tied to `zone.js`.
In a future world where our components use the new Signal API
and don't need `zone.js` anymore,
structural directives would still force us to drag `zone.js` in our bundle.

So, to sum up, structural directives are powerful but have some drawbacks.
Fixing these drawbacks would require a lot of work in the compiler and the framework.

That's why the Angular team decided to introduce a new syntax to write control flow statements in templates!

## Control flow syntax

The control flow syntax is a new syntax introduced in Angular v17
to write control flow statements in templates.

The syntax is very similar to some other templating syntaxes you may have met in the past,
and even to JavaScript itself.
There have been some debates and polling in the community about the various alternatives,
and the `@-syntax` proposal won.

With the control flow syntax, our previous template with `*ngIf` and `*ngFor` can be rewritten as:

{% raw %}
    <h1>Ninja Squad</h1>
    @if (condition) {
      <ul>
        @for (user of users; track user.id) {
          <li>{{ user.name }}</li>
        }
      </ul>
    }
{% endraw %}

This syntax is interpreted by the Angular compiler and creates the same views as the previous template,
but without the overhead of creating the structural directives,
so it is also a tiny bit more performant
(as it uses brand new compiled instructions under the hood in the generated code).
As this is not directives, the type-checking is also much better.

And, cherry on the cake, the syntax is more powerful than the structural directives!

The drawback is that this syntax uses `@`, `{` and `}` characters with a special meaning,
so you can't use these characters in your templates anymore,
and have to use equivalent HTML entities instead (`\&#64;` for `@`, `\&#123;` for `{`, and `\&#125;` for `}`).

## If statement

As we saw above, a limitation of `NgIf` is that it is a bit clunky to have an `else` alternative.
And we can't have an `else if` alternative at all.

That's no longer a problem with the control flow syntax:

{% raw %}
    @if (condition) {
      <div>condition is true</div>
    } @else if (otherCondition) {
      <div>otherCondition is true</div>
    } @else {
      <div>condition and otherCondition are false</div>
    }
{% endraw %}

You can still store the result of the condition in a variable if you want to,
which is really handy when used with an `async` pipe for example:

{% raw %}
    @if (user$ | async; as user) {
      <div>User is {{ user.name }}</div>
    } @else if (isAdmin$ | async) {
      <div>User is admin</div>
    } @else {
      <div>No user</div>
    }
{% endraw %}

## For statement

With the control flow syntax, a for loop needs to specify a `track` property,
which is the equivalent of the `trackBy` function of `*ngFor`.
Note that this is now mandatory, whereas it was optional with `*ngFor`.
This is for performance reasons, as the Angular team found that very often,
developers were not using `trackBy` when they should have.

{% raw %}
    <ul>
      @for (user of users; track user.id) {
        <li>{{ user.name }}</li>
      }
    </ul>
{% endraw %}

As you can see, this is a bit easier to use than the `trackBy` function of `*ngFor`
which requires to write a function.
Here we can directly specify the property of the item that is unique,
and the compiler will generate the function for us.
If you don't have a unique property, you can still use a function or just use the loop variable itself
(which is equivalent to what `*ngFor` currently does when no `trackBy` is specified).

One of the very useful additions to the control flow syntax is the handling of empty collections.
Previously you had to use an `*ngIf` to display a message
if the collection was `null` or empty and then use `*ngFor` to iterate over the collection.

With the control flow syntax, you can do it with an `@empty` clause:

{% raw %}
    <ul>
      @for (user of users; track user.id) {
        <li>{{ user.name }}</li>
      } @empty {
        <li>No users</li>
      }
    </ul>
{% endraw %}

We can still access the variables we used to have with `*ngFor`:

- `$index` to get the index of the current item
- `$first` to know if the current item is the first one
- `$last` to know if the current item is the last one
- `$even` to know if the current item is at an even index
- `$odd` to know if the current item is at an odd index
- `$count` to get the length of the collection

Unlike with `*ngFor`, you don't have to alias these variables to use them,
but you still can if you need to, for example when using nested loops.

{% raw %}
    <ul>
      @for (user of users; track user.id; let isOdd = $odd) {
        <li [class.grey]="isOdd">{{ $index }} - {{ user.name }}</li>
      }
    </ul>
{% endraw %}

It is also worth noting that the control flow `@for` uses
a new algorithm under the hood to update the DOM when the collection changes.
It should be quite a bit faster than the algorithm used by `*ngFor`,
as it does not allocate intermediate maps in most cases.
Combined with the required `track` property,
`for` loops should be way faster in Angular applications by default.

## Switch statement

This is probably where the new type-checking shines the most,
as using an impossible value in a case will now throw a compilation error!

{% raw %}
    @switch (user.type) {
      @case ('user') {
        <div>User</div>
      } @case ('anonymous') {
        <div>Anonymous</div>
      } @default {
        <div>Other</div>
      }
    }
{% endraw %}

Note that the switch statement does not support fall-through,
so you can't have several cases grouped together.
It also does not check if all cases are covered,
so you won't get a compilation error if you forget a case.
(but I hope it will, add a 👍 on [this issue](https://github.com/angular/angular/issues/52107) if you want this as well!).

It's also noteworthy that the `@switch` statement uses strict equality (`===`) to compare values,
whereas `*ngSwitch` used to use loose equality (`==`).
Angular v17 introduced a breaking change, and `*ngSwitch` now uses strict equality too,
with a warning in the console during development if you use loose equality:

    NG02001: As of Angular v17 the NgSwitch directive 
    uses strict equality comparison === instead of == to match different cases. 
    Previously the case value "1" matched switch expression value "'1'", 
    but this is no longer the case with the stricter equality check.
    Your comparison results return different results using === vs. ==
    and you should adjust your ngSwitch expression and / or values
    to conform with the strict equality requirements.


## The future of templating 🚀

The control flow syntax is a new "developer preview" feature introduced in Angular v17,
and will probably be the recommended way to write templates in the future
(the plan is to make it stable in v18 once it has been battle-tested).

It doesn't mean that structural directives will be deprecated,
but the Angular team will likely focus on the control flow syntax in the future
and push them forward as the recommended solution.

We will even have an automated migration to convert structural directives
to control flow statements in existing applications.
The migration is available in Angular v17 as a developer preview.
If you want to give it a try, run:

    ng g @angular/core:control-flow

This automatically migrates all your templates to the new syntax!
Even though the new control flow is experimental,
v17 comes with a mandatory migration needed to support this new control flow syntax,
which consists in converting the `@`, `{` and `}` characters used in your templates to their HTML entities.
This migration is run automatically when you update the app with `ng update`.

The future of Angular is exciting!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
