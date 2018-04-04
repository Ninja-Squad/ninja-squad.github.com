---
layout: post
title: What's new in Angular 6?
author: cexbrayat
tags: ["Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4"]
description: "Angular 6 is out! Which new features are included?"
---

Angular&nbsp;6.0.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#TODO">
    <img class="img-rounded img-responsive" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

It has a really big novelty which is not really a feature: the new Ivy compiler.
As it is still experimental, I'll close this article with it.

First let's start with the other new features and breaking changes.

## Tree-shakeable providers

There is now a new, recommended, way to register a provider,
directly inside the `@Injectable()` decorator, using the new `providedIn` attribute.
It accepts `'root'` as a value or any module of your application.
When you use `'root'`, your injectable will be registered as a singleton in the application,
and you don't need to add it to the providers of the root module.
Similarly, if you use `providedIn: UsersModule`,
the injectable is registered as a provider of the `UsersModule` without adding it to the providers of the module.

    @Injectable({
      providedIn: 'root'
    })
    export class UserService {

    }

This new way has been introduced to have a better tree-shaking in the application.
Currently a service added to the `providers` of a module will end up in the final bundle,
even if it is not used in the application, which is a bit sad.
It should not happen often in applications (if you write a service, you usually use it),
but third party modules sometimes offer services that you don't use,
and you end up with a big bundle of useless JavaScript.

So it will be especially useful for library developers,
but it is now the recommended way to register an injectable even for application developpers.
The new CLI will even scaffold a service with `providedIn: 'root'` by default now.

In the same spirit, you can now declare an `InjectionToken` and directly register it with `providedIn`
and give it a `factory`:

     export const WEBSOCKET = new InjectionToken<WebSocket>('WebSocket', {
        providedIn: 'root',
        factory: () => WebSocket
     });

## RxJS 6

## i18n

format functions available

## Animations

web-animation only required for AnimationBuilder

## ElementRef<T>

When // TODO


## Deprecations and breaking changes

### preserveWhitespace by default

### deprecated: ngModel and reactive forms

## Project Ivy: the new (new) Angular compiler

Soooo.... This is the 4th major release of Angular (2, 4, 5, 6), and the 3rd rewrite of the compiler!

For those who don't know: Angular compiles your templates into equivalent TypeScript code.
This TypeScript code is then compiled along the TypeScript you wrote into JavaScript code,
and the result is shipped to your users.
And we are now on the 3rd version of this Angular compiler
(the first was in the original release Angular 2.0, and the second in [Angular 4.0](/2017/04/28/what-is-new-angular-4)).

This new version of the compiler does not change how you write your templates,
but comes with improvements in several fields:

- build time
- bundle size

// TODO insert some numbers

This is still very experimental,
and the new Ivy compiler is behind a flag that you have to explicitely set in the compiler options
if you want to give a try.

    enableIvy: true

Be warned that it is probably not very reliable,
so my advice would be: don't use it in production right now.
But it will the defualt in a near future, so you can give it a spin to see if that works for your app,
and what you gain.

Let's dive into what differs between the old renderer, and the Ivy renderer.
You can skip the following sections if you are not interested in the details.

### Code generated with the old renderer

Let's take a small example: a `PonyComponent` taking a `PonyModel` with a `name` and a `color` as input,
and displaying an image depending on the color, and displaying the name of the pony.

 It looks like:

    @Component({
      selector: 'ns-pony',
      template: `<div>
      <ns-image [src]="getPonyImageUrl()"></ns-image>
      <div>{{ ponyModel.name }}</div>
    </div>`
    })
    export class PonyComponent {
      @Input() ponyModel: PonyModel;

      getPonyImageUrl() {
        return `images/${this.ponyModel.color}.png`;
      }
    }

The renderer introduced in Angular&nbsp;4 generated a class for each template,
called a `ngfactory`. It would contain (simplified code):

    export function View_PonyComponent_0() {
      return viewDef(0, [
        elementDef(0, 0, null, null, 4, "div"),
        elementDef(1, 0, null, null, 1, "ns-image", View_ImageComponent_0),
        directiveDef(2, 49152, null, 0, i2.ImageComponent, { src: [0, "src"] }),
        elementDef(3, 0, null, null, 1, "div"),
        elementDef(4, null, ["", ""])
      ], function (check, view) {
        var component = view.component;
        var currVal_0 = component.getPonyImageUrl();
        check(view, 2, 0, currVal_0);
      }, function (check, view) {
        var component = view.component;
        var currVal_1 = component.ponyModel.name;
        check(view, 4, 0, currVal_1);
      });
    }

This is hard to read, but the main things generated are:

- the structure of the DOM to create, containing element definitions (`figure`, `img`, `figcaption`)
abd their attributes, and text node definitions. Each part of the DOM structure is the view definition array and is represented by its index.
- change detection functions, containing the code you would more or less write by hand. Here, it checks the result of the `getPonyImageUrl` method and if it changes, updates the value of the input of the image component. Same with the pony's name: if it changes, it updates the text node displaying it.

### Code generated with Ivy

With Angular&nbsp;6 and the `enableIvy` flag set to `true`,
the same example doesn't generate a separate `ngfactory` but inlines all the informations directly in a static field of the component itself (simplified code):

    export class PonyComponent {

        static ngComponentDef = defineComponent({
          type: PonyComponent,
          selector: [[["ns-pony"], null]],
          factory: () => new PonyComponent(),
          template: (component, creationMode) {
            if (creationMode) {
                element(0, "figure");
                element(1, ImageComponent);
                element(2, "div");
                text(3);
            }
            property(1, "src", component.getPonyImageUrl());
            text(3, interpolate("", component.ponyModel.name, ""));
          },
          inputs: { ponyModel: "ponyModel" }
        });

        // ... rest of the class

    }

Everything is now contained in this static field.
The `template` attribute contains the equivalent of the `ngfactory` we used to have,
but with a slightly different structure.
The `template` function will be run on every change like before,
but has 2 modes:
- a creation mode when the component is first created and which contains the static DOM nodes to create
- the rest of the function executed on every change (update the image source if necessary and the text node).

### What does that change?

All decorators are now inlined directly into their classes
(it's the same for `@Injectable`, `@Pipe`, `@Directive`)
and can be generated with only the knowledge of the current decorator
(except for `@Component`, that still need `@NgModule` to know what components, directives or pipes to use in its template).

The generated code is slightly smaller, but more importantly some dependencies are broken,
allowing for a faster recompilation when you change one part of the application.
It also plays much nicer with modern bundlers like Webpack.
Angular used to produce heavy code. That's not necessarily a problem,
but an Hello World application was way too heavy.
With Ivy-generated code, the tree-shaking process is much more efficient,
resulting in smaller bundles \o/.

### Compatibility with existing librairies

You might be wondering what will happen with libraries
that have already been published using the previous packaging formation
if your project uses Ivy.
Don't worry, the compiler will produce Ivy-compatible version of the dependencies of your project,
even if they are not compiled with Ivy.
I'll spare you the gory details, but it should be transparent for us.

### New features

#### runtime i18n

#### private properties in templates

Take this with a grain of salt, as I have not seen official declarations about this,
but based on what I understand now, I think the new compiler adds a new feature or potential change.

It is a direct result of the fact that the template function is inlined
in a static field of the component:
we can now have private property of our components used in templates.
This is not currently the case,
and forces us to have all the fields and methods of the component used in the template to be public,
as they end up in a different class (the `ngfactory`), and that would fail the TypeScript compilation
to access a private property from another class.
This is no longer the case: as the template function is inside a static field,
it has access to the private properties of the component.

I don't know if the Angular team will recommend using public properties now even if it's not needed,
or if we will be encouraged to leverage this new possibility
to only leave public the fields that really need to be (like inputs and outputs).



All our materials ([ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](http://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
