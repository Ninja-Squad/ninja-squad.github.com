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
And if you use lazy-loading, you can fall in a bunch of traps or end up with the service bundled
in the "wrong" place.

It should not happen often in applications (if you write a service, you usually use it),
but third party modules sometimes offer services that you don't use,
and you end up with a big bundle of useless JavaScript.

So it will be especially useful for library developers,
but it is now the recommended way to register an injectable even for application developpers.
The new CLI will even scaffold a service with `providedIn: 'root'` by default now.

In the same spirit, you can now declare an `InjectionToken` and directly register it with `providedIn`
and give it a `factory`:

     export const baseUrl = new InjectionToken<string>('baseUrl', {
        providedIn: 'root',
        factory: () => 'http://localhost:8080/'
     });

Note that it also simplifies unit testing.
We used to register the service in the providers of the testing module to be able to test it.
Before:

    beforeEach(() => TestBed.configureTestingModule({
      providers: [UserService]
    }));

Now, if the `UserService` uses `providedIn: 'root'`:

    beforeEach(() => TestBed.configureTestingModule({}));

## RxJS 6

Angular&nbsp;6 now uses RxJS&nbsp;6 internally,
and requires you to update your application also.

And... RxJS 6 changed the way to import things!

In RxJS 5, you were probably writing:

    import { Observable } from 'rxjs/Observable';
    import 'rxjs/add/observable/of';
    import 'rxjs/add/operator/map';

    Observable.of(1, 2)
      .map(n => n * 2)
      .subscribe();

RxJS 5.5 introduced the pipeable operators:

    import { of } from 'rxjs/observable/of';
    import { map } from 'rxjs/operators';

    of(1, 2).pipe(
        map(n => n * 2)
      ).subscribe();

And RxJS 6.0 changed the imports:

    import { of } from 'rxjs';
    import { map } from 'rxjs/operators';

    of(1, 2).pipe(
        map(n => n * 2)
      ).subscribe();

So, one day, you'll have to change the imports across your application.
I say "one day" and not "right now" because RxJS released a library called `rxjs-compat`,
that allows you to bump RxJS to version 6.0 even if you use one of the "old" syntaxes.

The Angular team wrote a [complete document](https://docs.google.com/document/d/12nlLt71VLKb-z3YaSGzUfx6mJbc34nsMXtByPUN35cg/preview) to explain all this,
it's a must read when you'll start your Angular&nbsp;6.0 migration.

## i18n

The big one for i18n is the upcoming possibility to have "runtime i18n",
without having to build the application once per locale.
This is not yet available (there are just prototypes for now),
and it will need the Ivy renderer to work (continue reading to know what that is).
So it will be probably a few weeks/months more before we can use it.

While we hope for this much awaited feature,
a fix landed in i18n that may change how your application display amounts.
The `currency` pipe has indeed a change that makes sense:
it will not round every currency with 2 digits anymore,
but will round the currency to the most appropriate digit number
(which can be 3 like for the Arabic Dinar of Bahrain, or 0 like for the Chilean Pesos).

If you need to, you can retreive this value programmatically by using
the new i18n function `getNumberOfCurrencyDigits`.

Other formatting functions have also been exposed publicly,
like `formatDate`, `formatCurrency`, `formatPercent`, and `formatNumber`.

## Animations

The polyfill `web-animations-js` is not necessary anymore for animations in Angular&nbsp;6.0,
except if you are using the `AnimationBuilder`.
Your application may have won a few precious bytes!
In the case that the browser does not support the [element.animate API](https://developer.mozilla.org/en-US/docs/Web/API/Element/animate),
Angular&nbsp;6.0 will fallback to CSS keyframes.

## ElementRef<T>

When you want to grab a reference to an element in your template,
you can use `@ViewChild` or `@ViewChildren` or even inject `ElementRef` directly.
The inconvenient is that the said `ElementRef` will have its property `nativeElement` typed as `any`,
in Angular&nbsp;5.0 or older.

In Angular&nbsp;6.0, you can now type `ElementRef` more strictly if you want:

    @ViewChild('loginInput') loginInput: ElementRef<HTMLInputElement>;

    ngAfterViewInit() {
      // nativeElement is now an `HTMLInputElement`
      this.loginInput.nativeElement.focus();
    }

## Deprecations and breaking changes

Let's talk about what you should be aware before attempting a migration!

### preserveWhitespaces: false by default

In the "bad things that can happen when you upgrade" section,
note that `preserveWhitespaces` is now `false` by default.
This option was introduced in Angular&nbsp;4.4,
and if you want to know what to expect,
you should read [our blog post about that](/2017/09/18/what-is-new-angular-4.4/).
Spoiler: it may be completely fine or break your layouts.

### ngModel and reactive forms

It used to be possible to have `ngModel` and `formControl` on the same form fields,
but this is now deprecated and the support will be removed in Angular&nbsp;7.0.

It was a bit confusing and was probably not doing exactly what you were expecting
(`ngModel` was not the directive you know, but an input/output on the `formControl` directive doing slightly the same job, but not _exactly_ the same job).
We thought it was confusing too,
so we removed the chapter talking about that in our ebook [6 months ago](https://books.ninja-squad.com/angular/changelog).

So using code like:

    <input [(ngModel)]="user.name" [formControl]="nameCtrl">

will now yield a warning.

You can configure your app to emit the warning `always` (the default),
`once` or `never`:

    imports: [
      ReactiveFormsModule.withConfig({
        warnOnNgModelWithFormControl: 'never'
      });
    ]

Anyway, to prepare for ng 7, you should migrate your code to use
either a template-driven form or a reactive form.

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
But it will the default in a near future, so you can give it a spin to see if that works for your app,
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
and their attributes, and text node definitions. Each part of the DOM structure in the view definition array and is represented by its index.
- change detection functions, containing the code you would more or less write by hand. Here, it checks the result of the `getPonyImageUrl` method and if it changes, updates the value of the input of the image component. Same with the name of the pony: if it changes, it updates the text node displaying it.

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
that have already been published using the previous packaging format
if your project uses Ivy.
Don't worry, the compiler will produce Ivy-compatible version of the dependencies of your project,
even if they are not compiled with Ivy.
I'll spare you the gory details, but it should be transparent for us.

### New features

#### Runtime i18n

Note that this new renderer will now allow to have the much awaited possibility
of having "runtime i18n".
This is not completely ready,
but we saw a few commits that are good signs!

The cool thing is that you should not have to change your application a lot
if you are already using i18n.
But this time instead of building your application one time
for each locale you want to support,
you will be able to juste load a JSON containing the translations for each locale,
and Angular will take care of the rest!

#### Private properties in templates

The new compiler adds a new feature or potential change.

It is a direct result of the fact that the template function is inlined
in a static field of the component:
we can now have private properties of our components used in templates.
This was not possible until then,
and forced us to have all the fields and methods of the component used in the template to be public,
as they ended up in a different class (the `ngfactory`),
and accessing a private property from another class would have failed the TypeScript compilation.
This is no longer the case: as the template function is inside a static field,
it has access to the private properties of the component.

I saw a comment from the Angular team saying that it was not recommended to use private properties
in templates, even if it now possible, as it may not be the case in the future...
So you should probably continue to use public fields only in your templates!

This release doesn't bring a lot of new features,
but Ivy is definitely interesting for the future.
Give it a try and tell us how it goes for you!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](http://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
