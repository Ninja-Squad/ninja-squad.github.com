---
layout: post
title: The road to Angular 2 - What's in TypeScript? part 1
author: cexbrayat
tags: ["Angular 2", "TypeScript"]
description: "Angular 2 is not that far now. It has been designed to leverage a lot of new wonderful things in Web development, like TypeScript. Let's have a look!"
---

TypeScript has been around since 2012, and is a superset of JavaScript, adding a few things to ES5. The more important one is the type system, giving TypeScript its name. From version 1.5, released in 2015, the library is trying to be a superset of ES6, including all the shiny features we saw in the [last](/2015/10/06/es6-part-1/) [blog](/2015/10/13/es6-part-2/) [posts](/2015/11/03/types/), and a few new things as well, like decorators.
Writing TypeScript feels very much like writing JavaScript. By convention, TypeScript files are named with a `.ts` extension, and they will need to be compiled to standard JavaScript, usually at build time, using the TypeScript compiler. The generated code is very readable.

    npm install -g typescript
    tsc test.ts

But let's start with the beginning.

# Types as in TypeScript

The general syntax to add type info in TypeScript is pretty straightforward:

    let variable: type;

The types are easy to remember:

    let poneyNumber: number = 0;
    let poneyName: string = 'Rainbow Dash';

In these cases, the types are optional because the TS compiler can guess them (it's called "type inference") from the values.

The type can also be coming from your app, as with the following class `Pony`:

    let pony: Pony = new Pony();

TypeScript also support what some languages call "generics", for example for an array:

    let ponies: Array<Pony> = [new Pony()];

The array can only contain ponies, and the generic notation, using `<>` indicates this. You may be wondering what is the point of doing this. Adding types information will help the compiler catch possible mistakes:

    ponies.push('hello'); // error TS2345
    // Argument of type 'string' is not assignable to parameter of type 'Pony'.

So, if you need a variable to have multiple types, you're screwed? No, because TS has a special type, called `any`.

    let changing: any = 2;
    changing = true; // no problem

It's really useful when you don't know the type of a value, either because it's from a dynamic content or from a library you're using.

If your variable can only be of type `number` or `boolean`, you can use a union type:

    let changing: number|boolean = 2;
    changing = true; // no problem

# Enums

TypeScript also offers `enum`. For example, a race in our app can be either `ready`, `started` or `done`.

    let race: Race = new Race();
    race.status = RaceStatus.Ready;

The enum is in fact a numeric value, starting at 0. You can set the value you want though:

    enum Medal {Gold = 1, Silver, Bronze};

# Return types

You can also set the return type of a function:

    function startRace(race: Race): Race {
      race.status = RaceStatus.Started;
      return race;
    }

If the function returns nothing, you can show it using `void`:

    function startRace(race: Race): void {
      race.status = RaceStatus.Started;
    }

# Interfaces

That's a good first step. But as I said earlier, JavaScript is great for its dynamic nature. A function will work if it receives an object with the correct property:

    function addPointsToScore(player, points) {
      player.score += points;
    }

This function can be applied to any object with a `score` property. How do you translate this in TypeScript? It's easy, you define an interface, like the "shape" of the object.

    function addPointsToScore(player: { score: number; }, points: number): void {
      player.score += points;
    }

It means that the parameter must have a property called `score` of the type `number`. You can of course name these interfaces:

    interface HasScore {
      score: number;
    };
    function addPointsToScore(player: HasScore, points: number): void {
      player.score += points;
    }

# Optional arguments

Another treat of JavaScript is that arguments are optional. You can omit them, and they will become `undefined`. But if you define a function with typed parameter in TypeScript, the compiler will shout at you if you forget them:

    addPointsToScore(player); // error TS2346
    // Supplied parameters do not match any signature of call target.

To show that a parameter is optional in a function (or a property in an interface), you can add `?` after the parameter. Here, the `points` parameter could be optional:

    function addPointsToScore(player: HasScore, points?: number): void {
      points = points || 0;
      player.score += points;
    }

# Functions as property

You may also be interested in describing a parameter that must have a specific function instead of a property:

    function startRunning(pony) {
      pony.run(10);
    }

The interface definition will be:

    interface CanRun {
      run(meters: number): void;
    };

    function startRunning(pony: CanRun): void {
      pony.run(10);
    }

    let pony = {
      run: (meters) => logger.log(`pony runs ${meters}m`)
    };
    startRunning(pony);

That wraps up the first part on TypeScript. Next time, we'll speak about classes, decorators and working with other libraries. Stay tuned!
