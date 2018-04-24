---
layout: post
title: Angular Elements
author: cexbrayat
tags: ["Angular 2", "Angular", "Angular 4", "Angular 5", "Angular 6", "Angular CLI"]
description: "Angular Elements is a new package in Angular 6, allowing to use components as Custom Elements!"
---

Sometimes you don't want a full Angular app. Sometimes you just want to build a widget.
Or maybe you have several teams, some using React, Vue and others Angular.
Right now it's not really easy to share just one Angular component,
into an app that is not an Angular app.

But some people fight for a better Web and think that a new standard can save us all: Web Components.
Web components are actually 4 different specifications:
- HTML templates (the `template` tag)
- Shadow DOM (view encapsulation)
- HTML Imports (more or less a dead specification)
- and the one we are interested in: Custom Elements

Note that it is already possible to use a Web Component in an Angular app,
and it works seamlessly.
But we had no way of exposing our Angular Components as standard Custom Elements,
to use them outside of an Angular app.

Custom Elements give us the ability to declare an element,
which is not a standard HTML element, but a... custom one.
Like `admin-user`, or `responsive-image`, or `funky-carousel`.

I deep dived into the [official specification](https://w3c.github.io/webcomponents/spec/custom/)
to learn a bit more about the details of Custom Elements.
You can of course build your own Custom Elements with vanilla JavaScript
but there is a bit of "plumbing" to do (you have to write an ES6 class with a constructor that follows some rules,
then observe the attributes that can change, then implement the correct lifecycle methods defined in the specification).

That is why Angular&nbsp;6 introduces `@angular/elements`!
Angular Elements are classic components packaged as Custom Elements.

When you package an Angular Component as an Angular Element,
you can then use it like a standard Custom Element.
It will bootstrap itself, and create an NgElement (custom element) that hosts the component.
It also builds a bridge between the standard DOM APIs and the underlying Angular Component,
by doing the plumbing between the component's inputs and the custom element properties,
between its outputs and the custom element events,
and between its attributes.

To use it, build a component as usual:

    {% raw %}
    @Component({
      selector: 'ns-pony',
      template: `<p (click)="onClick()">{{ ponyName }}</p>`
    })
    export class PonyComponent {
      @Input() ponyName;
      @Output() selected = new EventEmitter<boolean>();

      onClick() {
        this.selected.emit(true);
      }
    }
    {% endraw %}

Add it to a module (here `PonyModule`) and then you can register it in another (non Angular) application
to use it as a Custom Element:

    import { createCustomElement } from '@angular/elements';
    import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';

    import { PonyComponent, PonyModule } from './pony.module';

    platformBrowserDynamic().bootstrapModule(PonyModule)
      .then(({ injector }) => {
        // get the ES6 class
        const PonyElement = createCustomElement(PonyComponent, { injector });
        // use it to register the custom element
        customElements.define('ns-pony', PonyElement);
      });

Once that's done, you can use the element `ns-pony` as if it is a standard element:

    <ns-pony pony-name="Rainbow Dash"></ns-pony>

Note that the attribute is in kebab-case, whereas the property is in camelCase.

The element can be updated with your favorite framework supporting Custom Elements (like VueJS, Preact but not (yet) React, see [Custom Elements Everywhere](https://custom-elements-everywhere.com/)).
Or you can of course use Vanilla JS:

    const ponyComponent = document.querySelector('ns-pony');

    // update the pony's name
    setTimeout(() => ponyComponent.ponyName = 'Pinkie Pie', 3000);

    // listen to the custom event
    ponyComponent.addEventListener('selected', event => console.log('selected!', event));

You can even create new components and insert them, they will be automatically upgraded to custom elements (and the inner PonyComponent will be instantiated)!

    const PonyComponent = customElements.get('ns-pony');
    const otherPony = new PonyComponent();
    otherPony.ponyName = 'Applejack';
    document.body.appendChild(otherPony);

The API is still very young (it was in Angular Labs for the past 6 months),
so I would not recommend using it in production yet.
But this time will come!

Check out our [ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](http://ninja-squad.com/training/angular) if you want to learn more!
