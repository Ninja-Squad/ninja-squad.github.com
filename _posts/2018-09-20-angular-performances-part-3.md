---
layout: post
title: Angular Performances Part 3 - Profiling and runtime performances
author: cexbrayat
tags: ["Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4", "Angular CLI", "performances", "benchmarks"]
description: "Learn how to make your Angular application faster. In this third part, let's talk about how you can profile the runtime performances of your application and how to improve them."
---

This is the third part of this series (check the [first part](/2018/09/06/angular-performances-part-1) and the [second one](/2018/09/13/angular-performances-part-2) if you missed them), and this blog post is about how you can profile the runtime performances of your Angular application and how you can improve these runtime performances.
If you are the lucky owner of our ebook, you can already check the other parts if you download the [last ebook release](https://books.ninja-squad.com/claim?book=Angular).


Now that we have talked about first load and reload,
we can start talking about runtime performances.
But if you run into a performance issue,
before trying any of the following tips,
you should start by measuring and profiling the application.

Browsers nowadays offer nice developer tools,
especially Chrome, which allows to record your application,
and analyze its behavior with quite some details.
You can even simulate some conditions,
like using a slower processor,
or using a 3G network.
You can also dive into the call hierarchy,
and see how much time each function call is consuming.

## Profiling

But Angular also offers a precious tool:
`ng.profiler`.
It's not very well-known,
but it can be handy as it allows to measure
how long a change detection run in the current page took.

You can then try to apply one of the tips we'll see,
and measure again to see if there is any improvement.

In your `main.ts` file,
replace the application bootstrapping code with the following:

    platformBrowserDynamic().bootstrapModule(AppModule)
      .then(moduleRef => {
        const applicationRef = moduleRef.injector.get(ApplicationRef);
        const componentRef = applicationRef.components[0];
        // allows to run `ng.profiler.timeChangeDetection();`
        enableDebugTools(componentRef);
      })
      .catch(err => console.log(err));

Then go to the page you want to profile,
open your browser console,
and execute the following instruction:

    > ng.profiler.timeChangeDetection()
    ran 489 change detection cycles
    1.02 ms per check

You can see how many change detection cycles it ran
(it should be at least 5 cycles or during at least 500ms),
and the time per cycle.
This is a super useful metric,
as many of the tricks we are going to show you directly act
on the change detection system.
You'll be able to try them,
run the profiler again,
and compare the results.

You can also record the CPU profile during these checks
to analyze them with `ng.profiler.timeChangeDetection({ record: true })`.

The Angular team recommends to have a time per check below 3ms,
to leave enough time for the application logic,
the UI updates and browser's rendering pipeline
to fit within the 16 milliseconds frame (assuming a 60 FPS target frame rate).

Let's discover these tips!

## Runtime performances

Angular's magic relies on its change detection mechanism:
the framework automatically detects changes in the state of the application
and updates the DOM accordingly.
So, as a general rule of thumbs, you'll want to help Angular
and limit the change detection triggering and the amount of DOM to update/create/delete.

To be honest, most applications will be fine, even under heavy load.
But some of us will have to recode Excel in the browser for their enterprise,
or will have a component with a tree displaying 10,000 customers,
or another unreasonable thing to do in a browser.
These things are tricky, whatever framework you use.
They tend to update a lot of DOM, and have to check a lot of components.
A few of the following tricks can help.
And a few of these tricks are *really* mandatory, like the first one.

### enableProdMode

When you are in development mode (by default),
Angular will run the change detection twice every time there is a change.
This is a security to make sure you are not doing strange things,
like updating data without following the one-way data flow.
If you break the rules, Angular will warn you about it in development,
by throwing an exception that will force you to fix your code.
But if you are not careful, you will deploy the application in this mode,
and change detection will still run twice, slowing your application.

To go in production mode, you need to call a function provided by Angular called `enableProdMode`.
This method will disable the double check,
and also make the generated DOM "lighter"
(less attributes on the elements, attributes that are added to debug the application).

As usual the CLI got you covered,
and the call to `enableProdMode` is already present in the generated application,
wrapped in an environment check: if you build with the `production` environment,
your app will be in production mode.

### trackBy in ngFor

This is a simple tip that can really speed things up on `*ngFor`:
add a `trackBy`.
To understand why, let me explain how modern JS frameworks (at least all major ones) handle collections.
When you have a collection of 3 ponies and want to display them in a list,
you'll write something like:

{% raw %}
    <ul>
      <li *ngFor="let pony of ponies">{{ pony.name }}</li>
    </ul>
{% endraw %}

When you add a new pony,
Angular will add a DOM node in the proper position.
If you update the name of one of the ponies,
Angular will change just the text content of the right `li`.

How does it do that?
By keeping track of which DOM node references which object reference.
Angular will have an internal representation looking like:

    node li 1 -> pony #e435 // { id: 3, color: blue }
    node li 2 -> pony #8fa4 // { id: 4, color: red }

It works great, and if you change an object for another one,
Angular will destroy the node and build another one.

    node li 1 (recreated) -> pony #c1ea // { id: 1, color: green }
    node li 2 -> pony #8fa4 // { id: 4, color: red }

If the whole collection is updated with new objects,
the complete DOM list will be destroyed and recreated.
Which is fine, except when you just refresh a list with almost the same content:
in that case, Angular destroys the complete node list and recreates it,
even if there is no need to.
For example, when you fetch the same results from the server,
you will have the same content,
but different references as your collection will have been recreated.

The solution for this use-case is to help Angular track the objects,
not by their references, but by something that you know will identify the object,
typically an ID.

For this, we use `trackBy`, which expects a method:

{% raw %}
    <ul>
      <li *ngFor="let pony of ponies trackBy: ponyById">{{ pony.name }}</li>
    </ul>
{% endraw %}

with the method defined in the component:

    ponyById(index: number, pony: PonyModel) {
      return pony.id;
    }

As you can see, this method receives the current index and the current entity,
allowing you to be creative (or simply track by index, but that's not recommended).

With this `trackBy`, Angular will only recreate a DOM node if
the id of the pony changes.
On a very big list which doesn't change much,
it can save a ton of DOM deletions/creations.
Anyway, it's quite cheap to implement and doesn't have cons,
so don't hesitate to use it.
It's also a requirement if you want to use animations.
If a DOM element's style is supposed to be animated
(by transitioning smoothly from the previous value to the new one),
and the list of ponies is replaced by a new one when refreshed,
then `trackBy` is a must: without it,
the animation will never happen,
because the style of the element never changes.
Instead, it's the element itself which is being replaced by Angular.

We have more tips for you, but you'll have to wait until next week to read about them!

If you enjoyed this blog post, you may want to dig deeper with our [ebook](https://books.ninja-squad.com/angular),
and/or with a complete exercise that we added in our [online training](https://angular-exercises.ninja-squad.com/).
The exercise takes an application and walks you through what we would do to optimize it,
measuring the benefits of each steps, showing you how to avoid the common traps,
how to test the optimized application, etc. Check it out if you want to learn more!

See you soon for part 4!
