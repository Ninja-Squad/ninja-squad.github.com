---
layout: post
title: The Angular linker (goodbye ngcc!)
author: cexbrayat
tags: ["Angular 11", "Angular"]
description: "Angular 11.1+ allows to ship partially compiled libraries to NPM. What does it mean?"
---

Angular&nbsp;11.1 introduced a new compilation mode.
It allows to partially compile a library before shipping it to NPM.
What does that mean?

## A tale of two compilers

If you have been following Angular history lessons,
you may have heard that Angular used to have a compiler called View Engine (VE).
Since Angular 9.0, the default compiler is now Ivy
(check out [our article](/2019/05/07/what-is-angular-ivy/)
explaining all that if you missed it)!

A new compiler sounds really breaking though.
What about all the Angular libraries published with VE code?

To provide a smooth transition to Ivy,
the Angular team wrote a "compatibility compiler", `ngcc`.
The first time you install a dependency,
`ngcc` has to run to transform the library to an Ivy version.

Let's take a small example.

## My tiny library

You can easily create a library using the Angular CLI.
Start by generating a new project with the option that disables the creation of an application:

    ng new tiny-lib --defaults --no-create-application

Then generate a library:

    ng generate library tiny-lib

The generated library contains a very simple component,
perfect for our use case:

    @Component({
      selector: 'lib-tiny-lib',
      template: `<p>tiny-lib works!</p>`,
    })
    export class TinyLibComponent {
    }

The build is already configured for us,
so you can easily ship it to NPM,
and use it in other projects.

The build configuration is defined in `tsconfig.lib.prod.json`:

    {
      "extends": "./tsconfig.lib.json",
      "compilerOptions": {
        "declarationMap": false
      },
      "angularCompilerOptions": {
        "enableIvy": false
      }
    }

The interesting part is the `enableIvy: false` configuration.
Even using Angular CLI v11.1,
the library is configured to be built with View Engine and not Ivy!

That might seem strange,
but this is the only way to make sure a project still using View Engine
can use our tiny library.

The resulting `dist` directory, after `ng build`,
contains several formats (UMD, ESM, FESM).
The `tiny-lib.js` file in the FESM format contains for example:

    class TinyLibComponent {}
    TinyLibComponent.decorators = [
      {
        type: Component,
        args: [
          {
            selector: "lib-tiny-lib",
            template: `<p>tiny-lib works!</p>`,
          },
        ],
      },
    ];

## ngcc

When we use this library in an Angular Ivy project,
`ngcc` needs to run to convert the library into an "Ivy" version.
Let's see what happens.

    ng new tiny-app --defaults
    yarn add ../tiny-lib/dist/tiny-lib

After updating the `AppComponent` to use `TinyLibComponent`,
running `ng serve` outputs:

    Compiling @angular/core : es2015 as esm2015
    Compiling @angular/common : es2015 as esm2015
    Compiling tiny-lib : es2015 as esm2015

This is `ngcc` compiling Angular packages and our library into an Ivy compatible format.
If you open `node_modules/tiny-lib`,
you'll spot a new `__ivy_ngcc__` directory, containing a modified version of the `tiny-lib.js` file:

    class TinyLibComponent {}
    TinyLibComponent.ɵfac = function TinyLibComponent_Factory(t) {
      return new (t || TinyLibComponent)();
    };
    TinyLibComponent.ɵcmp = ɵngcc0.ɵɵdefineComponent({
      type: TinyLibComponent,
      selectors: [["lib-tiny-lib"]],
      decls: 2,
      vars: 0,
      template: function TinyLibComponent_Template(rf, ctx) {
        if (rf & 1) {
          ɵngcc0.ɵɵelementStart(0, "p");
          ɵngcc0.ɵɵtext(1, "tiny-lib works!");
          ɵngcc0.ɵɵelementEnd();
        }
      },
      encapsulation: 2,
    });

As you can see, there is a new `ɵcmp` field on the component,
with the definition of the component.
Inside this definition, we can spot a `template` function,
with Ivy instructions to create the template (`elementStart`, `text`, etc.).

Thanks to `ngcc`, the library is usable in an Ivy project!

## ngcc downsides

But `ngcc` is a bit annoying as well, especially with Yarn.
Yarn has the (weird I agree) habit of blowing out the whole `node_modules` content
every time you run `yarn install`.
As `ngcc` stores the transformed version in `node_modules`,
you have to run it again *every time* you run `yarn install`.
It's hard to cache, so CI jobs generally need to re-run `ngcc` on every build.

So why don't we ship our library in Ivy format directly?
If so, we wouldn't need to run `ngcc`.
You can even try it, by switching `enableIvy` to `true`.

That sounds great, but it would prevent any changes to the Ivy instructions in the future.
For example, imagine that the Angular team comes with a clever/faster alternative to
replace the `text` instruction: they wouldn't be able to ship it,
as all the existing libraries would stop working!

So are we stuck with `ngcc` forever?
Luckily, no: that's where the Angular linker enters!

## Angular Linker and compilation mode

Starting with Angular v11.1,
it's possible to partially compile a library.
In our library, let's add the following option to  `tsconfig.lib.prod.json`:

    "enableIvy": "true",
    "compilationMode": "partial"

The `compilationMode` option can have two values:

- `full`, which generates a fully compiled code with Ivy (same result as `ngcc` above)
- `partial`, which generates code in a stable, but intermediate form suitable to be published to NPM

The resulting `ng build --prod` in our library gives us
the following `tiny-lib.js`:

    class TinyLibComponent {}
    TinyLibComponent.ɵcmp = ɵɵngDeclareComponent({
      version: "11.1.0",
      type: TinyLibComponent,
      selector: "lib-tiny-lib",
      ngImport: i0,
      template: `<p>tiny-lib works!</p>`,
      isInline: true,
    });

As you can see, this is not exactly the same result as `ngcc`.
We have `ngDeclareComponent` that looks like `defineComponent` above,
but the template has not been transformed to Ivy instructions.

This intermediate transformation can be shipped to NPM.
When used in an Ivy project, `ngcc` will not have to transform the library:
the Angular linker (a new piece of the compiler) has enough information to do its job!
The linker transforms a partially compiled file into a fully compiled one.

The cool thing is:

- the linker is fast, as it has all the required information to do its job 🚀
- it does not touch `node_modules` so we don't have the problem exposed above 😍
- it is transparent for application developers 🧐

When all the libraries have migrated to this format,
`ngcc` will be useless in our projects.
This will of course take quite some time:
the `partial` mode is brand new,
and at the time of writing,
it's still not recommended to use it.
But we can safely imagine that this will become the default in the future,
and that we'll be able to remove `ngcc` from our build pipelines!

Check out our [ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular) if you want to learn more about Angular!
