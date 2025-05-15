---
layout: post
title: Angular selectorless components
author: cexbrayat
tags: ["Angular 20", "Angular"]
description: "Angular 20.0 introduces a new way to use components and directives in templates without their selectors!"
---

Angular&nbsp;20.0.0 will soon be released and it contains a lot of new features
that we'll detail in an upcoming blog post.
Let's take a look at one of them today: selectorless components!

## Selectors

If you've been using Angular for a while, you know that components and directives
have selectors that are used to identify them in templates.

For example, a `User` component can be declared like this:

```ts
@Component({
  selector: 'app-user',
  template: '...',
})
export class User {
  readonly name = input.required<string>();
  readonly selected = output<void>();
}
```

And then used in a template, for example in `App`,  like this:

```ts
import { User } from './user/user';

@Component({
  selector: 'app-root',
  template: '<app-user [name]="name()" (selected)="selectUser()" />',
  imports: [User]
})
export class App {
```

## Selectorless components

With Angular&nbsp;20.0, you can now use components and directives without a selector!

The `User` component can be simplified like this:

```ts
@Component({
  template: '...',
})
export class User {
```

And the `App` component can use it like this:

```ts
import { User } from './user/user';
// ☝️ TS import is still necessary

import
@Component({
  template: '<User [name]="name()" (selected)="selectUser()" />',
  // but no Angular imports needed! 😲
})
export class App {
```

In the template, we can directly use the class name of the component
(`User`) instead of the selector (`app-user`).
On the typescript side, we now only rely on the TypeScript import
and no longer need to manually import the component in the `imports` array.

This is a nice way to use components in templates
and closer to what is done in other frameworks like React or Vue.

Note that it was already possible to _declare_ components without a selector,
for example for components only used by the router or dynamically created.

As we have no selector,
the generated HTML will not contain the selector tag as it used to do.
For now, the generated HTML uses `ng-component` as the tag name,
but this may change in the future:

```html
<ng-component>
  <!-- User template -->
</ng-component>
```

A nice addition to this feature is that the selectorless components
can be used with a tag name:

```html
<CustomButton:button>Hello</CustomButton:button>
<CustomTitle:svg:title>Hello</CustomTitle:svg:title>
```

Here `CustomButton` and `CustomTitle` are selectorless components
that are used with the `button` and `svg:title` tags.
In that case, the generated HTML will use the tag name
instead of `ng-component`:

```html
<button>
  <!-- CustomButton template -->
</button>
<svg:title>
  <!-- CustomTitle template -->
</svg:title>
```

Note that a few tags can't be used (`ng-container`, `ng-template`, `ng-content`, `link`, `style`, `script`).

This fixes the scenario where you wanted to generate semantic HTML
and where Angular would be in the way and created custom tags for each components.
For example, to generate a `ul` with `li` elements with Angular components,
using 2 components would lead to the following HTML:

```html
<app-custom-ul>
  <ul>
    <app-custom-li><li>...</li></app-custom-li>
  </ul>
</app-custom-ul>
```

As you can see, the generated HTML is not valid
as the `li` elements are not inside the `ul` element.
You had several options to fix this, for example to use a directive for the `li` elements
and delegate the rendering to the `CustomUl` component.

This can now be done with selectorless components:

```html
<CustomUl:ul>
  <CustomLi:li></CustomLi:li>
</CustomUl:ul>
```
And the generated HTML will be:

```html
<ul>
  <li>...</li>
</ul>
```

## Selectorless directives

You can also use directives without a selector.

Let's consider a `Highlight` directive that highlights an element.
We used to declare it like this:

```ts
@Directive({
  selector: '[appHighlight]'
})
export class Highlight {
```

And use it like this:

```ts
import { Highlight } from './highlight/highlight';

@Component({
  template: '<div appHighlight>Text</div>',
  imports: [Highlight]
})
export class App {
```

The `Highlight` directive can now be declared like this:

```ts
@Directive()
export class Highlight {
```

And used like this:

```ts
import { Highlight } from './highlight/highlight';

@Component({
  template: '<div @Highlight>Text</div>'
})
export class App {
```

A directive can also have inputs and outputs, just like a component.
For example, the `Highlight` directive can have an input to set the color:

```ts
@Directive()
export class Highlight {
  readonly color = input.required<string>();
}
```

When using a selectorless directive, you'll need to wrap its inputs and outputs in parentheses:

```html
<div @Highlight([color]="color()")>Text</div>
```

This is different from what we used to do (`<div appHighlight [color]="color()">Text</div>`),
but more explicit and easier to read.

This is especially useful when using multiple directives on the same element.
As existing directives and components can be used as selectorless,
let's use the `CdkDrag` directive from Angular Material as an example:

```html
<div @Highlight([color]="color()") @CdkDrag(cdkDragLockAxis="y")>Text</div>
```

This is much clearer than what we used to do, where we never really knew
what was a directive and what was an input or output:

```ts
<div appHighlight [color]="color()" cdkDrag cdkDragLockAxis="y">Text</div>
<!-- hard to say what is a directive, an input, or both -->
```

It is also possible to combine selectorless components and directives:

```html
<User [name]="name()" (selected)="selectUser()" @CdkDrag(cdkDragLockAxis="y") />
```

The `@` and parentheses makes it easy to identify the directives in the template.
Note that there is no special order between components input/outputs and directives,
I could have written:

```html
<User @CdkDrag(cdkDragLockAxis="y") [name]="name()" (selected)="selectUser()" />
```

## Selector pipes

It is also possible to use selectorless pipes.
Pipes don't have a selector, but a name, and you can now remove it and call the pipe directly by its class name.

```ts
@Pipe()
export class FromNowPipe {
```

And use it like this:

```ts
import { FromNowPipe } from './from-now-pipe';

@Component({
  template: '<p>{{ date | FromNow }}</p>'
})
export class App {
```


## Common errors

Selectorless components can only be standalone components.
If you try to use this syntax in a non-standalone component, you'll get an error like this:

```
NG2010: Cannot use selectorless with a component that is not standalone
```

If you try to use a component that is not imported in the TypeScript imports,
or imported using a type import, you'll get an error like this:

```
NG2024: Cannot find name "User". Selectorless references are only supported to classes or non-type import statements.
```

Or if you try to use a selectorless component as a directive or vice versa,
or if you try to reference a non-standalone component or directive,
you'll get an error like this:

```
NG2025: Incorrect reference type. Type must be a standalone @Directive.
```

As mentioned above, selectorless components and directives don't have an `imports` field in their decorator.
If you try to use a selectorless component or directive with an `imports` field,
you'll get an error like this:

```
NG2026: Cannot use the "imports" field in a selectorless component
```

## Enable selectorless components

Selectorless components and directives are not enabled by default in Angular&nbsp;20.0.
To enable them, you need to add the following option in your `tsconfig.json`:

```json
{
  "angularCompilerOptions": {
    "enableSelectorless": true
  }
}
```

This is of course highly experimental and may change in the future.


## Future and migration

Now that it is possible to experiment with selectorless components and directives,
we can expect an RFC in the near future to discuss the API and the migration path.
Once the RFC is approved, the Angular team will slowly stabilize the API.

Even if there is no automatic migration yet,
the Angular team will probably be able to provide one in the future.


## Summary

This is an exciting new feature that makes Angular templates more readable and easier to use.
This fits the trend of making Angular more explicit and less magic:
it used to be possible to define a directive that matched a selector `button`, load it in a module,
and then, voilà, all the buttons in the application would be affected by this directive.
Which was great  for some use cases, but could also lead to unexpected behaviors
and hard-to-debug issues.
With standalone and selectorless components and directives,
you have to explicitly use them in your templates,
which makes it easier to understand what is going on in your application.
At the price of less magic, of course.

Give it a try when Angular&nbsp;20.0 is released!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
