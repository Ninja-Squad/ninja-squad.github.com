---
layout: post
title: The road to Angular 2 - What's in TypeScript? part 2
author: cexbrayat
tags: ["Angular 2", "TypeScript"]
description: "Angular 2 is not that far now. It has been designed to leverage a lot of new wonderful things in Web development, like TypeScript. Let's have a look!"
---

This is the second part in [our discovery of TypeScript](/2015/11/12/typescript-part-1/).
As we saw, TypeScript is a superset of ES6, so it implements classes,
and adds a few bonuses on the way.

# Classes

A class can implement an interface. For us, the `Pony` class should be able to run, so we can do:

    class Pony implements CanRun {
      run(meters) {
        logger.log(`pony runs ${meters}m`);
      }
    }


The compiler will force us to implement a `run` method in the class. If we implement it badly, by expecting a `string` instead of a `number` for example, the compiler will yell:


    class IllegalPony implements CanRun {
      run(meters: string) {
        console.log(`pony runs ${meters}m`);
      }
    }
    // error TS2420: Class 'IllegalPony' incorrectly implements interface 'CanRun'.
    // Types of property 'run' are incompatible.

You can also implement several interfaces if you want:

    class HungryPony implements CanRun, CanEat {
      run(meters) {
        logger.log(`pony runs ${meters}m`);
      }
      eat() {
        logger.log(`pony eats`);
      }
    }

And an interface can extend one or several others:

    interface Animal extends CanRun, CanEat {}

    class Pony implements Animal {
      // ...
    }

When you're defining a class in TypeScript, you can have properties and methods in your class. You may realize that properties in classes are not a standard ES6 feature, it is only possible in TypeScript.

    class SpeedyPony {
      speed: number = 10;
      run() {
        logger.log(`pony runs at ${this.speed}m/s`);
      }
    }

Everything is public by default. But you can use the `private` keyword to hide a property or a method. If you add `private` or `public` to a constructor parameter, it is a shortcut to create and initialize a private or public member:

    class NamedPony {
      constructor(public name: string,
                  private speed: number) {}

      run() {
        logger.log(`pony runs at ${this.speed}m/s`);
      }
    }

    let pony = new NamedPony('Rainbow Dash', 10);
    // defines a public property name with 'Rainbow Dash'
    // and a private one speed with 10    

These shortcuts are really useful and we'll rely on them a lot in Angular 2!

# Working with other libraries

When working with external libraries written in JS, you may think we are doomed because we don't know what types of parameter the function in that library will expect. That's one of the cool things with the TypeScript community: its members have defined interfaces for the types and functions exposed by the popular JavaScript libraries!

The files containing these interfaces have a special `.d.ts` extension. They contain a list of the library's public functions. A good place to look for these files is [DefinitelyTyped](https://github.com/borisyankov/DefinitelyTyped). For example, if you want to use TS in your AngularJS 1.x apps, you can download the proper file from the repo:

    tsd query angular --action install --save

and then include the file at the top of your code, and enjoy the compilation checks:

    /// <reference path="angular.d.ts" />
    angular.module(10, []); // the module name should be a string
    // so when I compile, I get:
    // Argument of type 'number' is not assignable to parameter of type 'string'.

`/// <reference path="angular.d.ts" />` is a special comment recognized by TS, telling the compiler to look for the interface `angular.d.ts`.
Now, if you misuse an AngularJS method, the compiler will complain, and you can fix it on the spot, without having to manually run your app!

Even cooler, since TypeScript 1.6, the compiler will auto-discover the interfaces
if they are packaged in your `node_modules` directory in the dependency.
More and more projects adopt this approach, and Angular 2 is doing the same.
So you don't even have to worry about including the interfaces in your Angular 2 project:
the TS compiler will figure it out by itself if you are using NPM to manage your dependencies!

# Decorators

This is a fairly new feature, added only in TypeScript 1.5, to help supporting Angular.
Indeed, as we will shortly see, Angular 2 components can be described using decorators.
You may have not heard about decorators, as not every language has them.
A decorator is a way to do some meta-programming.
There are fairly similar to annotations
which are mainly used in Java, #C and Python, and maybe other languages I don't know.
Depending on the language, you add an annotation to a method, an attribute, or a class.
Generally, annotations are not really used by the language itself, but mainly by frameworks and libraries.

Decorators are really powerful: they can modify their target, and for example to add metadata.
Until now, it was not something possible in JavaScript.
But the language is evolving and there is now an official proposal for `decorators`,
that may be standardized one day in the future (possibly in ES7/ES2016).
Note that the TypeScript implementation goes slightly further than the proposed standard.

In Angular 2, we will use the decorators provided by the framework.
Their role is fairly basic: they add some metadata to our classes to say for example "this class is a component",
"this is an optional dependency", "this is a custom property", etc...
It's not required to use them, as you can add the metadata manually (if you want to stick to ES5 for example),
but the code will be definitely more elegant using decorators, as provided by TypeScript.

In TypeScript, decorators start with an `@`, and can be applied to a class, a class property, a function or a function parameter.
Not on a constructor though, but it can be applied to the constructor's parameters.

To have a better grasp on this, let's try to build a simple decorator,
`@log()`, that will log something every time a method is called.

It will be use like this:

    class RaceService {

      @log()
      getRace(raceId) {
        // call API
      }
    }

To define it, we have to write a method returning a function like this:

    let log = function () {
      return (target: any, name: string, descriptor: any) => {
        logger.log(`call to ${name}`);
        return descriptor;
      };
    };

Depending on what you want to apply your decorator, the function will not have exactly the same arguments.
Here we have a method decorator, that takes 3 parameters:

- `target`: the method targeted by our decorator
- `name`: the name of the targeted method
- `descriptor`: a descriptor of the targeted method, like is the method enumerable, writable, etc...

Here we simply log the method name, but you could do pretty much whatever you want:
interfere with the parameters, the result, calling another function, etc...

As a user, let's look at what a decorator in Angular 2 looks like:

    @Component({selector: 'home'})
    class Home {

      constructor(@Optional() hello: HelloService) {
        logger.log(hello);
      }

    }

The `@Component` decorator is added to the class `Home`.
When Angular 2 will load our app, it will find the class `Home`,
and will understand that it is a component, based on the metadata the decorator will add.
Cool, huh? As you can see, a decorator can also receive parameters, here a configuration object.

I just wanted to introduce the raw concept of decorators,
we'll look into every decorator available in Angular all along [our book](https://books.ninja-squad.com/angular2).

I have to point out that you can use decorators with Babel as a transpiler instead of TypeScript.
There is even a plugin to support all the Angular 2 decorators: [angular2-annotations](https://www.npmjs.com/package/babel-plugin-angular2-annotations).
Babel also supports class properties, but not the type system offered by TypeScript.
You can use Babel, and write "ES6+" code, but you will not be able to use the types, and they are very useful for the dependency injection for example.
It's completely possible, but you'll have to add more decorators to replace the types.

So my advice would be to give TypeScript a try!
It's not very intrusive, as you can use it just where it's useful and forget about it for the rest.
If you really don't like it, it will not be very difficult to switch to ES6 with Babel or Traceur,
or even ES5, if you are slightly crazy (but honestly, an Angular 2 app in ES5 has pretty ugly code).

Stay tune for the next episode of 'The road to Angular 2'!
