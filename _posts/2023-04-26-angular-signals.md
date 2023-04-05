---
layout: post
title: An introduction to Angular Signals
author: cexbrayat
tags: ["Angular 16", "Angular"]
description: "Angular 16 introduces the concept of signals. Let's dive in!"
---

The Angular team has been working on a different way to handle reactivity in applications for the past year.
The result of their work is a new concept in Angular called Signals.

Let's see what they are, how they work, how they interoperate with RxJS, and what they'll change for Angular developers.

## The reasons behind Signals

Signals are a concept used in many other frameworks, like SolidJS, Vue, Preact, and even the venerable KnockoutJS.
The idea is to offer a few primitives to define reactive state in applications
and to allow the framework to know which components are impacted by a change, rather than having to detect changes on the whole tree of components.

This will be a significant change to how Angular works, as it currently relies on zone.js to detect changes in the whole tree of components by default.
Instead, with signals, the framework will only dirty-check the components that are impacted by a change,
which of course makes the re-rendering process more efficient.

This opens the door to zoneless applications, i.e. applications where Angular applications don't need to include Zone.js (which makes them lighter), don't have to patch all the browser APIs (which makes them start faster)
and smarter in their change detection (to only check the components impacted by a change).

Signals are released in Angular v16, as a developer preview API, meaning there might be changes in the naming or behavior in the future.
But this preview is only a small part of the changes that will come with signals.
In the future, signal-based components with inputs and queries based on signals,
and different lifecycle hooks, will be added to Angular.
Other APIs like the router parameters and form control values and status, etc. should also be affected.

## Signals API

A signal is a function that holds a value that can change over time.
To create a signal, Angular offers a `signal()` function:

    import { signal } from '@angular/core';
    // define a signal
    const count = signal(0);

The type of `count` is `WritableSignal<number>`, which is a function that returns a number.    

When you want to get the value of a signal, you have to call the created signal:

    // get the value of the signal
    const value = count();

This can be done both in TypeScript code and in HTML templates:

{% raw %}
    <p>{{ count() }}</p>
{% endraw %}

You can also set the value of a signal:

    // set the value of the signal
    count.set(1);

Or update it:

    // update the value of the signal, based on the current value
    count.update((value) => value + 1);

There is also a `mutate` method that can be used to mutate the value of a signal:

    // mutate the value of the signal (handy for objects/arrays)
    const user = signal({ name: 'JB', favoriteFramework: 'Angular' });
    user.mutate((user) => user.name = 'Cédric');

You can also create a readonly signal, that can't be updated, with `asReadonly`:

    const readonlyCount = count.asReadonly();

Once you have defined signals, you can define computed values that derive from them:

    const double = computed(() => count() * 2);

Computed values are automatically computed when one of the signals they depend on changes.

    count.set(2);
    console.log(double()); // logs 4

Note that they are lazily computed and only re-computed
when one of the signals they depend on produces a new value.
They are not writable, so you can't use `.set()` or `.update()` or `.mutate()` on them
(their type is `Signal<T>`).

Under the hood, a signal has a set of subscribers, and when the value of the signal changes, it notifies all its subscribers.
Angular does that in a smart way, to avoid recomputing everything when a signal changes,
by using internal counters to know which signals have really changed since the last time a computed value was computed.

Finally, you can use the `effect` function to react to changes in your signals:

    // log the value of the count signal when it changes
    effect(() => console.log(count()));

An `effect` returns an object with a `destroy` method that can be used to stop the effect:

    const effectRef: EffectRef = effect(() => console.log(count()));
    // stop executing the effect
    effectRef.destroy();

This does look like a `BehaviorSubject`, but it has some subtle differences, the most important one being that unsubscribing is unnecessary thanks to the usage of 
[weak references](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakRef).

An `effect` or a `computed` value will re-evaluate when one of the signals they depend on changes,
without any action from the developer. This is usually what you want.

Note that while signals and computed values will be common in Angular applications,
effects will be used less often, as they are more advanced and low-level primitive.
If you need to react to a signal change,
for example, to fetch data from a server, you can use the RxJS interoperability layer
that we detail below.

If you want to exclude a signal from the dependencies of an effect or computed value,
you can use the `untracked` function:

    const multiplier = signal(2);
    // `total` will not re-evaluate when `multiplier` changes
    // it only re-evaluates when `count` changes
    const total = computed(() => count() * untracked(() => multiplier()));

You _can't_ write to a signal inside a computed value, as it would create an infinite loop:

    // this will throw an error NG0600
    const total = computed(() => { multiplier.set(2); return count() * multiplier() });

This is the same in effect, but this can be overridden using `allowSignalWrites`:

    // this will not throw an error
    effect(
      () => {
        if (this.count() > 10) {
          this.count.set(0);
        }
      },
      { allowSignalWrites: true }
    );

All these features (and terminology) are fairly common in other frameworks,
so you won't be surprised if you used SolidJS or Vue 3 before.

One feature that I _think_ is fairly unique to Angular is the possibility to pass a `ValueEqualityFn` to the `signal` function.
To decide if a signal changed (and know if a computed or an effect need to run),
Angular uses `Object.is()` by default, but you can pass a custom function to compare the old and new values:

    const user = signal({ id: 1, name: 'Cédric' }, { equal: (previousUser, newUser) => previousUser.id === newUser.id });
    // upperCaseName will not re-evaluate when the user changes if the ID stays the same
    const uppercaseName = computed(() => user().name.toUpperCase());

## Signals, components, and change detection

As mentioned above, you can use signals and computed values in your templates:

{% raw %}
    <p>{{ count() }}</p>
{% endraw %}

If the counter value changes, Angular detects it and re-renders the component.

But what happens if the component is marked as `OnPush`? Until now, `OnPush` meant that Angular would only re-render the component if one of its inputs changed, if an `async` pipe was used in the template, or if the component used `ChangeDetectorRef#markForCheck()`.

The framework now handles another reason to re-render a component: when a signal changes.
Let's consider the following component (not using a signal, but a simple field that will be updated after 2 seconds):

    @Component({
      selector: 'app-user',
      standalone: true,
      templateUrl: './user.component.html',
      changeDetection: ChangeDetectionStrategy.OnPush
    })
    export class UserComponent {
      count = 0;

      constructor() {
        // set the counter to 1 after 2 seconds        
        setTimeout(() => this.count = 1, 2000);
      }
    }

As the component is `OnPush`, using a `setTimeout` will trigger a change detection, but the component will not be re-rendered (as it won't be marked as "dirty").

But if we use a signal instead:

    @Component({
      selector: 'app-user',
      standalone: true,
      templateUrl: './user.component.html',
      changeDetection: ChangeDetectionStrategy.OnPush
    })
    export class UserComponent {
      count = signal(0);

      constructor() {
        // set the counter to 1 after 2 seconds        
        setTimeout(() => this.count.set(1), 2000);
      }
    }

Then the component will be re-rendered after 2 seconds, as Angular detects the signal change and refresh the template.

Under the hood, if a view reads a signal value, then Angular marks the template of the component as a consumer of the signal.
Then, when the signal value changes, it marks the component and all its ancestors as "dirty".

For us developers, it means that we can use signals in our components as soon as Angular v16 is released,
and we don't need to worry about change detection, even if the components are using OnPush.

## Sharing a signal between components

In the previous example, the signal was defined in the component itself.
But what if we want to share a signal between multiple components?

In the Vue ecosystem, you frequently encounter the pattern of "composables":
functions that return an object containing signals, computed values, and functions to manipulate them.
If a signal needs to be shared, it is defined outside of the function and returned by the function:

    const count = signal(0);
    export function useCount() {
      return {
        count,
        increment: () => count.set(count() + 1)
      };
    }

In Angular, we can do the same and we can also use services instead of functions (and it's probably what we'll do).
We can define a `CountService` as the following:

    @Injectable({ providedIn: 'root' })
    export class CountService {
      count = signal(0);
    }

Then, in our components, we can inject the service and use the signal:

    @Component({
      selector: 'app-user',
      standalone: true,
      templateUrl: './user.component.html',
      changeDetection: ChangeDetectionStrategy.OnPush
    })
    export class UserComponent {
      count = inject(CountService).count;
    }

The service could also define computed values, effects, methods to manipulate the signals, etc.

    @Injectable({ providedIn: 'root' })
    export class CountService {
      count = signal(0);
      double = computed(() => this.count() * 2);

      constructor() {
        effect(() => console.log(this.count()));
      }

      increment() {
        this.count.update(value => value + 1);
      }
    }

## Memory leaks

Signal consumers and producers are linked together using weak references,
which means that if all the consumers of a signal cease to exist,
then the signal will be garbage collected as well.
In other terms: no need to worry about "unsubscribing" from a signal to prevent memory leaks,
as we have to do with RxJS observables \o/.

You can also use an `effect` in your component (even if that's probably going to be very rare) to watch a value and react to its changes,
for example, the `count` defined in a service like the above.

Note that you don't have to manually stop an effect when the component is destroyed, as Angular will do it for you to prevent memory leaks.
Under the hood, an effect uses a `DestroyRef`, a new feature introduced in Angular v16, to automatically be cleaned up when the component or service is destroyed.

You can change this behavior though, by creating an effect with a specific option:

    this.logEffect = effect(() => console.log(count()), { manualCleanup: true });

In this case, you will have to manually stop the effect when the component is destroyed:

    ngOnDestroy() {
      this.logEffect.destroy();
    }

Effects can also receive a cleanup function, that is run when the effect runs again.
This can be handy when you need to stop a previous action before starting a new one.
In the example below, we start an interval that runs every `count` milliseconds,
and we want to stop it and start a new one when the count changes:

    this.intervalEffect = effect(
      (onCleanup) => {
        const intervalId = setInterval(() => console.log(`count in intervalEffect ${this.count()}`), this.count());
        return onCleanup(() => clearInterval(intervalId))
      }
    )

Note that effects run during change detection, so they're not a good place to set signal values.
That's why you get an error from Angular if you try to do so:

    // ERROR: Cannot set a signal value during change detection

Effects will probably be used very rarely, but they can be handy in some cases:
- logging / tracing;
- synchronising state to the DOM or to a storage, etc.

## Signals and RxJS interoperability

RxJS is here to stay, even if its usage might be more limited in the future.
Angular is not going to remove RxJS, and it's not going to force us to use signals instead of observables.
In fact, RxJS is probably a better way to react to signal changes than using effects.

We can use signals and observables together, and we can convert one into the other. Two functions to do that are available in the brand new `@angular/core/rxjs-interop` package.

To convert a signal to an observable, we can use the `toObservable` function:

    const count$ = toObservable(count);

Note that the created observable will not receive all the value changes of the signal,
as this is done using an effect under the hood, and effects are only run during change detection:

    const count = signal(0);
    const count$ = toObservable(count);
    count$.subscribe(value => console.log(value));
    count.set(1);
    count.set(2);
    // logs only 2, not 0 and 1, as this is the value when the under-the-hood effect runs

To convert an observable to a signal, we can use the `toSignal` method:

    const count = toSignal(count$);

The signal will contain the last value emitted by the observable,
or will throw an error if the observable emits an error.
Note that the subscription created by `toSignal()` is automatically unsubscribed
when the component that declared it is destroyed.
As observables can be asynchronous, you can pass an initial value to the function:

    const count = toSignal(count$, { initialValue: 0 });

If you do not provide an initial value, the value is `undefined` if it is read before the observable emits a value.
You can also use the option `requireSync` to make the signal throw an error if it is read before the observable emits a value:

    const count = toSignal(count$, { requireSync: true });


## Signal-based components

In the future (v17? v18?),
we'll be able to build a component entirely based on signals, even for its inputs and queries.
The framework would be notified when an expression has changed thanks to the signals, and would thus only need to dirty-checks the components affected by the change, without having to check for changes on unrelated components, without the need for zone.js. It will even be able to re-render only the part of the template that has changed,
instead of checking the whole template of a component as it currently does.
But there is a long way ahead, as several things need to be rethought in the framework to make this work
(inputs, outputs, queries, lifecycle methods, etc).

An RFC is out with the details of the proposal, and you can follow the progress on the [Angular repository](https://github.com/angular/angular/discussions/49685).

Currently, the RFC proposes to use `signals: true` to mark a component as "Signal-based":

{% raw %}
    @Component({
      signals: true,
      selector: 'temperature-calc',
      template: `
        <p>C: {{ celsius() }}</p>
        <p>F: {{ fahrenheit() }}</p>
      `,
    })
    export class SimpleCounter {
      celsius = signal(25);

      // The computed only re-evaluates if celsius() changes.
      fahrenheit = computed(() => this.celsius() * 1.8 + 32);
    }
{% endraw %}

Inputs, outputs, and queries would be defined via functions instead of decorators in these components,
and would return a signal:

    firstName = input<string>(); // Signal<string|undefined>

Nothing has been implemented for this part yet, so you can't try this in v16.
But you can already try to use signals in existing components, as we mentioned above
(but keep in mind they are not production ready)

It's anyway quite interesting how frameworks inspire each other,
with Angular taking inspiration from Vue and SolidJS for the reactivity part,
whereas other frameworks are increasingly adopting the template compilation approach of Angular,
with no Virtual DOM needed at runtime.

The future of Angular is exciting!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
