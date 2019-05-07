---
layout: post
title: What is Angular Ivy?
author: cexbrayat
tags: ["Angular", "Angular 8"]
description: "Angular 8 is all about Ivy. But what _is_ Ivy?"
---

If you have been following the development of Angular lately,
you probably encountered the word "Ivy".

Behind this codename hides a huge work for the Angular team,
and a stepping stone for the future of the framework.
But it can be hard to figure out what _is_ Ivy.
Let's find out 🤓.


## Your JS framework is a compiler

Your JS framework is a compiler.
It's true for most JS frameworks out there,
but it's especially true for Angular.
Let me rewind a little to make sure we are on the same page.

In Angular, when your write a component,
you write the component in TypeScript and its template in HTML,
augmented by Angular template syntax (`ngIf`, `ngFor`, etc.).

The thing a lot of developers don't really know is that
this HTML will never touch the browser.
It will be compiled by Angular into JavaScript instructions,
to create the appropriate DOM when the component appears on the page,
and to update the component when its state changes.
That's why a big part of Angular is its compiler:
it takes all your HTML and generates the necessary JS code.
This compiler (and the runtime) has been completely rewritten over the last year,
and this is what Ivy is about.
This is not the first rewrite:
Ivy stands for 'IV', 4 in roman numbers.
The last rewrite was done in Angular 4.0,
and maybe you did not even noticed it 😊.
But this is by far the deepest rewrite of the internals since the initial release of Angular:
the Angular team is literally changing the engine (previously called View Engine) while driving.


## The goals of Ivy

Ivy is a very important stepping stone in the Angular history.
It changes how the framework internally works,
without changing how we write Angular applications.

If the parallel makes some sense to you, it's very similar to React and the "Fiber rewrite".
React Fiber was a complete rewrite of React internals,
and notably offered a more incremental rendering.
The rewrite lasted over a year, and opened the door to new features
(for example the famous [Hooks](https://reactjs.org/docs/hooks-intro.html)
that were released in React 16.8 and that rely on Fiber).

Angular achieves the same with this effort:
Ivy is a complete rewrite of the compiler (and runtime) in order to:

- 🚀reach better build times (with a more incremental compilation)
- 🔥reach better build sizes (with a generated code more compatible with tree-shaking)
- 🔓unlock new potential features (metaprogramming or higher order components, lazy loading of component instead of modules, a new change detection system not based on zone.js...)


## No effort from your part

The important point is that we don't have to change how we write our applications.
Ivy aims to be compatible with the existing applications:
it will just be a switch to turn on for most projects.

But it can happen that Ivy does not have the exact same behavior for some edge cases.
To avoid breaking applications when we switch to Ivy,
the Angular team wrote migration scripts (update schematics) to analyze your code
and prepare it for Ivy if necessary.
So when you'll update to Angular 8,
the schematics will run and tweak a few things in your code to be "Ivy-ready"
when the time comes.
The plan is to enable Ivy by default in the future,
probably in V9.


## Differences in generated code

Let's dive into the gritty details 🤓.

For a component `PonyComponent` with a template like:

{% raw %}
    <figure>
      <img [src]="getPonyImageUrl()">
      <figcaption>{{ ponyModel.name }}</figcaption>
    </figure>
{% endraw %}

View Engine, the pre-Ivy engine, generated code looking like:

    function View_PonyComponent() {
      return viewDef([
        elementDef(2, 'figure'),
        elementDef(0, 'img', ['src']),
        elementDef(1, 'figcaption'),
        textDef()
      ], (checkBinding, view) => {
        var component = view.component;
        const currVal_0 = component.getPonyImageUrl();
        checkBinding(view, 1, currVal_0);
        const currVal_1 = component.ponyModel.name;
        checkBinding(view, 4, currVal_1);
      });
    }

This is what was called a *ng_factory*,
a function defining a view definition with two parts:

- a static description of the DOM to generate
- a function called when the state of the component changed

Ivy generates a different code for the same component.
First it does not generate a *ng_factory* anymore:
it inlines the generated code in a static field.
A `@Directive` decorator becomes a field called `ngDirectiveDef`.
An `@Injectable` decorator becomes a field called `ngInjectableDef`.
A `@Component` decorator becomes a field called `ngComponentDef`.

So our component becomes:

    class PonyComponent {
      static ngComponentDef = defineComponent({
        type: PonyComponent,
        selectors: [['ns-pony']],
        factory: () => new PonyComponent(),
        // number of elements, templates, content, bound texts to allocate...
        consts: 4,
        vars: 2,
        template: (renderFlags: RenderFlags, component: PonyComponent) => {
          if (renderFlags & RenderFlags.Create) {
            elementStart(0, 'figure');
            element(1, 'img');
            elementStart(2, 'figcaption');
            text(3);
            elementEnd();
            elementEnd();
          }
          if (renderFlags & RenderFlags.Update) {
            select(1)
            property('src', component.getPonyImageUrl());
            select(3)
            textBinding(3, interpolation1('', component.ponyModel.name, ''));
          }
        }
      });
    }

Note that the code generated in the `template` part has roughly the same shape
than a `ng_factory` (a creation and update part)
but uses different instructions.

But the biggest difference is probably the new *locality principle*.
This could make a big difference when developing an Angular application,
and cut rebuild times.
But it also allows to ship pre-compiled code to NPM directly!


## Easier to publish

If you wanted to publish an Angular library on NPM,
you had to compile your TypeScript code to JavaScript,
and then run the Angular compiler to generate the `metadata.json` files.

Then, when someone was building an application with your library,
`ng build` was building the `ng_factory.js` files for your components
and for the components coming from librairies.
It means that if an application used 3 libraries with 10 components each,
and the application itself had 50 components,
`ng build` was compiling 80 components.

With Ivy, as you may have understood,
there are no `ng_factory.js` or `metadata.json` files anymore.
It means that, as a library author,
you can directly ship to NPM the compiled JS code,
with the result of the Ivy compilation
(with the static fields generated for each component, directive, service...).

Then when someone builds an application with your "Ivy-ready" library,
they won't pay the cost of compiling the components of your library!
This should speed up the rebuild times in the development cycle,
when we have `ng serve` running and we wait to check a modification we did.


## (Re)build times

So when a library is already compiled,
then we don't have to recompile it every time. Great.

But it also turns out that previously, when you were working on your application,
Angular had to recompile everything inside your module to know what had changed,
because the generated code of a component could be using internal details of another component.

Now each component references the directives and components it uses only by their public APIs.
So if you modify an internal detail of a component or a directive,
only the actual components that use it will be recompiled!
It could lead to huge benefits in rebuild times for applications with dozens of components and directives,
as you will go from recompiling all of them to recompile just the needed ones.

Let's take an example with our `PonyComponent` that declares its input like this:

    @Input('pony') ponyModel: PonyModel;

It's a common technique to have a property (`this.ponyModel`)
exposed as an input with a different name (`pony`).
So when a component uses `PonyComponent` in its template, it looks like:

    <ns-pony [pony]="myPony"></ns-pony>

And the generated code in Ivy looks like:

    // ...
      if (renderFlags & RenderFlags.Update) {
        select(0);
        // updates the public `pony` property
        property('pony', component.myPony);
      }
    },
    directives: [PonyComponent]

But with View Engine, it looked like:

    // ...
    elementDef(0, 'ns-pony'),
    // updates the private `ponyModel` field
    directiveDef('PonyComponent', { ponyModel: [0, 'ponyModel'] }
    // ...

It may not look like much a difference,
but View Engine only references the private field,
and not its public name.

This is the locality principle.
To compile an `AppComponent` that uses `PonyComponent` in its template,
Ivy doesn't need to know anything about the pony component.
The output of the Ivy compiler for `Appcomponent`
depends exclusively on the code of `AppComponent`.

That was not true in ViewEngine,
where the code generated for the `AppComponent`
also depended on the code of the `PonyComponent`
(in this example, on the name of the field `ponyModel` backing the input `pony`).

That seems like an implementation detail,
but it has consequences on the rebuild time:
if you have 200 components in your app and you're changing the code of 3 of those components,
the Ivy compiler only has to recompile those 3 components.
It doesn't need to recompile all of the unmodified components,
because their generated code is guaranteed
to not depend on the code of the modified components anymore.

A little trivia of Angular history:
modules were introduced fairly lately in Angular development,
just a few months before the stable release.
Previously, during the 2.0 beta phase,
you had to reference manually each component and directive used
in a component directly in its decorator.
Modules were introduced to avoid that, but the downside was that it became the smallest unit of compilation:
changing one element of the module lead to recompile all the elements of the module.
You can see how the code generated in Ivy takes us back to what was originally designed by the Angular team,
with a `directives` property generated in the `ngComponentDef` field.
I also heard the team talking about changing/removing modules one day in various conferences,
so we'll see.


## Bundle sizes

The new instruction set has been designed to achieve the goals mentioned above.
More accurately, it has been designed to be completely tree-shakeable.
That means if you don't use a particuliar feature of Angular,
the instructions corresponding to that feature won't be in your final bundle.
More than that the Ivy runtime won't have the code to run this instruction,
whereas View Engine was not tree-shakeable and always contained everything.

That's why the team expects big improvements on the size of small applications,
and especially on a Hello World application (which previously produced a big bundle for Hello World),
or for an [Angular Element](/2018/05/29/angular-elements/).

For the medium to large applications,
the situation should not change much with the first release of Ivy.
The bundles should be roughly the same sizes (or even slightly bigger) as they are with View Engine.
The Angular team will have time to focus on that once they are sure that there is no regression with Ivy,
and we can hope for smaller bundles in every case in the future.


## Runtime performances

Ivy has no particular focus on performances, at least not in the first release.
It has been designed to be very efficient memory-wise, some mechanics have been improved,
and it's still designed to avoid mega-morphic calls,
but overall you should not see big improvements or losses.
If you spot some performance loss, the team will probably be very happy to hear about it.

Ivy opens a few possibilities for the future though.
It should now be possible to run an application without zone.js,
and to semi-manually handle change detection (a bit like you would with React).
These APIs already exist but are experimental, not documented,
and will probably change in the near future.


## Better template type checking

The Angular compiler has an option which is often overlooked in my opinion: `fullTemplateTypeCheck`.
When enabled, the compiler tries to analyze the templates more deeply.
I showed some examples of what it's capable of,
when it was introduced in [Angular 5](/2017/11/02/what-is-new-angular-5/).
This option is now more powerful in Ivy,
and will probably be even more powerful in the future.

For example, one of the features already available in Ivy
is the type-checking of component and directive inputs.
Imagine an `ImageComponent` with an input called `size`, of type `number`.
If another component uses `ImageComponent` and tries to pass a boolean value into the `size` property,
you'll see the error: `Type 'boolean' is not assignable to type 'number'.`.

This is a just an example of what Ivy will be capable of,
and these features are very interesting for large applications.


## Backward compatibility

I explained that the Ivy compiler takes the decorators in your TypeScript code,
and then generates a static field in the class.
But the current libraries shipped on NPM don't have their decorator anymore,
they usually ship the JavaScript code resulting from the compilation.
And Ivy needs these static fields to properly work,
so are we stuck until every library we use ship the new version?

Hopefully no, we aren't 😅.
The Angular team built a "compatibility compiler", `ngcc`.
This compiler has one critical task:
it takes the `node_modules` of your application,
looks for Angular libraries,
reads their `metadata.json` files and JS code,
and outputs the same JS code, but with the static fields Ivy needs!

This is a truly impressive piece of engineering,
mostly hidden from our eyes,
as it is directly embedded in the CLI.
So the first time you'll run `ng serve` or `ng build`,
you'll notice the task takes longer than usual,
as `ngcc` is doing its magic behind the scenes.
But don't be afraid: it has to be done only once,
and then it won't run again
(except when you add another Angular library to your application of course).


## Future possibilities

Angular 8.0 is really the first step for Ivy.
When it will be stable enough,
it will become the default.
And then the team can start working on adding other features more easily.
Like the [i18n service](https://github.com/angular/angular/issues/11405),
probably one of the most awaited features.
Or the possibility to have [metaprogramming or higher order components](https://blog.nrwl.io/metaprogramming-higher-order-components-and-mixins-with-angular-ivy-75748fcbc310).
Or to lazy-load a single component instead of a module.
Or to have JiT components and AoT components work with each other.
Or to manually craft a template, by hand-writing the generated instructions
to squeeze the best performances.
And probably tons of other ideas the team has,
and have not talked about yet.

I hope this clarified a bit what Ivy is about,
and that you'll give it a try in the next months!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
