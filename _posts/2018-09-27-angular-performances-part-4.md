---
layout: post
title: Angular Performances Part 4 - Change detection strategies
author: cexbrayat
tags: ["Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4", "Angular CLI", "performances", "benchmarks"]
description: "Learn how to make your Angular application faster. In this fourth part, let's talk about how you improve the runtime performances with change detection strategies."
---

This is the fourth part of this series (check the [first part](/2018/09/06/angular-performances-part-1), the [second one](/2018/09/13/angular-performances-part-2) and the [third one](/2018/09/20/angular-performances-part-3) if you missed them), and this blog post is about how you can improve the runtime performances of your Angular application with change detection strategies.
If you are the lucky owner of our ebook, you can already check the other parts if you download the [last ebook release](https://books.ninja-squad.com/claim?book=Angular).


Now that we have talked about first load, reload and profiling
we can continue our exploration of the tips for better runtime performances.

## Change detection strategies

When we explained how Angular detects the changes in your application,
we showed the tree of components and said that Angular starts by checking the root component,
then its children, then its grand-children, until all components are checked.
Then all the necessary DOM updates are applied in one batch.

But you may be wondering if it is a very good idea to check *every* component on *every* change.
And you're right, that's often not really necessary.

Angular offers another change detection strategy:
it's called `OnPush` and it can be defined on any component.

With this strategy, the template of the component will only be checked in 2 cases:

- one of the inputs of the component changed (to be more accurate, when the *reference* of one of the inputs changes);
- an event handler of the component was triggered.

This can be very convenient when the template of
a component only depends on its inputs,
and can give a serious boost to your application
if you display a lot of components on screen!
But once again, be very cautious before applying this optimization:
if the preconditions end up not being respected,
you will lose your hairs wondering why the component (or any of its descendants)
isn't always repainting itself after a change.

Let's take a small example to demonstrate.

Imagine that we have 3 components.
A very simple `ImageComponent`:

{% raw %}
    @Component({
      selector: 'ns-img',
      template: `
          <p>{{ check() }}</p>
          <img [src]="src">
      `
    })
    export class ImageComponent {
      @Input() src: string;

      check() {
          console.log('image component view checked');
      }
    }
{% endraw %}

used in a `PonyComponent`:

{% raw %}
    @Component({
      selector: 'ns-pony',
      template: `
        <p>{{ check() }}</p>
        <ns-img [src]="getPonyImageUrl()"></ns-img>
      `
    })
    export class PonyComponent {
      @Input() ponyModel: PonyModel;

      check() {
        console.log('pony component view checked');
      }

      getPonyImageUrl() {
        return `images/pony-${this.ponyModel.color}-running.gif`;
      }
    }
{% endraw %}

used itself in a `RaceComponent`:

{% raw %}
    @Component({
      selector: 'ns-race',
      template: `
        <h2>Race</h2>
        <p>{{ check() }}</p>
        <div *ngFor="let pony of ponies">
          <ns-pony [ponyModel]="pony"></ns-pony>
        </div>
        <button (click)="changeColor()">Change color</button>
      `
    })
    export class RaceComponent {

      ponies: Array<PonyModel> = [{ id: 1, color: 'green' }, { id: 2, color: 'orange' }];
      colors: Array<string> = ['green', 'orange', 'blue'];

      check() {
        console.log('race component view checked');
      }

      changeColor() {
        this.ponies[0].color = this.randomColor();
      }

    }
{% endraw %}

The `RaceComponent` displays two ponies,
and the user can change the color of the first one by clicking
on the `Change color` button.

With the current default change detection strategy,
every time that we have a change in the application,
all 3 components are checked.

We added a `check()` method in each component,
called in each template:
it allows us to track if the component is checked or not.
And indeed in our example,
we can see in our console:

    pony component view checked
    image component view checked
    pony component view checked
    image component view checked
    race component view checked

(we can see that twice actually,
because we are in development mode,
see the section about `enableProdMode` above).

### OnPush

But in this case, it's a waste of time:
we know that if the pony doesn't change,
the template of the `PonyComponent` doesn't need to be checked.
Same thing for the `ImageComponent`: if the `src` input is the same,
there is no need to recompute the image URL.
So let's switch these components to `OnPush`,
by adding a `changeDetection` attribute in their `@Component` decorator:

{% raw %}
    @Component({
      selector: 'ns-img',
      template: `
        <p>{{ check() }}</p>
        <img [src]="src">
      `,
      changeDetection: ChangeDetectionStrategy.OnPush
    })
    export class ImageComponent {
      @Input() src: string;

      check() {
        console.log('image component view checked');
      }
    }
{% endraw %}

Same thing in `PonyComponent`:

{% raw %}
    @Component({
      selector: 'ns-pony',
      template: `
        <p>{{ check() }}</p>
        <ns-img [src]="getPonyImageUrl()"></ns-img>
      `,
      changeDetection: ChangeDetectionStrategy.OnPush
    })
    export class PonyComponent {
      @Input() ponyModel: PonyModel;

      check() {
        console.log('pony component view checked');
      }

      getPonyImageUrl() {
        return `images/pony-${this.ponyModel.color}-running.gif`;
      }
    }
{% endraw %}

When we click to change the color,
we will only see in the console:


    race component view checked

Which is awesome,
because it means that we don't check the components
that we don't need to check \o/.

### OnPush and the mutability trap

But... there is a slight problem:
the pony's color doesn't change any more!

I picked this example on purpose:
even if `OnPush` is really powerful,
it can be tricky
and optimizing existing components
is not only about adding a few `OnPush` here and there.

Why doesn't it work in our case?

Take a closer look to our `RaceComponent`,
and its `changeColor` method:

    changeColor() {
      this.ponies[0].color = this.randomColor();
    }

This method *mutates* the pony in the `ponies` collection,
and this pony is the input of our `PonyComponent`.
Now that we shifted our component to be `OnPush`,
Angular will only run the change detection
if the *reference* of the `pony` input changes.
And when you mutate an object,
it's still the same object,
so the reference doesn't change,
and Angular thinks there is no need to run the change detection...

So, is this change detection strategy completely useless?
Not really, but it does require you to be more careful.

The simple way to fix our issue is to not mutate our pony in `changeColor`,
but to create a new object:

    changeColor() {
      const pony = this.ponies[0];
      // create a new pony with the old attributes and the new color
      this.ponies[0] = { ...pony, color: this.randomColor() };
    }

Once you've done that,
the application is faster *and* correct.
If the user clicks on the button,
the `changeColor` method creates a new pony object
with the old attributes and the new color.
As this is a new object,
Angular will run the change detection in the `PonyComponent` (an input changed),
and then the `src` input of the `ImageComponent` will also change,
and the image will display the correct color.
And, of course, if another event triggers the change detection in `RaceComponent`,
the children component will not be checked (if their inputs did not change).

As you can see, you can quickly fall into a trap when migrating a component
to an `OnPush` strategy, so be careful (unit tests are your friend).

One way to avoid this would be to use a library
that enforces immutability.
[Immutable.js](https://facebook.github.io/immutable-js/) (by Facebook) is such a library.
I've never used it professionally,
so I can't say if it's a good fit in an Angular application or not,
but you do see it mentioned often on the internets.

There is a last topic we need to talk about: observables.

### OnPush, Observables and the async pipe

Let's say we now have only one component,
our well-known `PonyComponent`.
It subscribes to an observable from a `ColorService`
that returns a new color every second.
We obviously expect the image displayed to change every second.
The developer of this component thought that an `OnPush`
change detection strategy couldn't hurt.
What do you think?

    @Component({
      selector: 'ns-pony',
      template: `
          <p>New color every 1s</p>
          <img [src]="'pony-' + color + '.gif'">
      `,
      changeDetection: ChangeDetectionStrategy.OnPush
    })
    export class PonyComponent implements OnInit, OnDestroy {
      color = 'green';
      subscription: Subscription;

      constructor(private colorService: ColorService) {
      }

      ngOnInit() {
        this.subscription = this.colorService.get()
          .subscribe(color => this.color = color);
      }

      ngOnDestroy(): void {
        this.subscription.unsubscribe();
      }
    }

Sadly, this doesn't work.
With the `OnPush` strategy,
Angular only refreshes the template if one of the inputs changed
(here, there is no input),
or if an event was triggered (there is none either).
So the `color` field is updated every second,
but the template is never refreshed...

This can be fixed by using the pipe called `async`.

The `async` pipe can be used to subscribe to a Promise or an Observable.
Let's use it in our `PonyComponent`:

    @Component({
      selector: 'ns-observable-on-push-with-async',
      template: `<img *ngIf="color | async as c"
                      [src]="'pony-' + c + '.gif'">`,
      changeDetection: ChangeDetectionStrategy.OnPush
    })
    export class PonyComponent {
      color: Observable<string>;

      constructor(colorService: ColorService) {
        this.color = colorService.get();
      }
    }

Now our component is working!
The `async` pipe will trigger the change detection when a new value is received.
And you can see that we store the result of `async` to use it with `as`.
It also frees us to subscribe to the observable in the component,
and to remember to unsubscribe when the component is destroyed:
`async` does it for us.

Note that `async` can lead to several HTTP requests if used several times in a template,
and that you can use the "smart/dumb" component pattern
to make it easier to use OnPush.

## ChangeDetectorRef

There are a few last tricks regarding change detection
that I want to show you.
They are for more advanced use cases but, you never know,
it can be handy one day.

Let's take an hypothetical use case:
you have an observable that emits data very very frequently.
In my example, it's a clock that emits every 10 milliseconds:

{% raw %}
    @Component({
      selector: 'ns-clock',
      template: `
          <h2>Clock</h2>
          <p>{{ getTime() }}</p>
          <button (click)="start()">Start</button>
      `
    })
    export class ClockComponent implements OnDestroy {

      time = 0;
      timeSubscription: Subscription;

      start() {
        this.timeSubscription = interval(10).pipe(
          take(1001), // 0, 1, ..., 1000
          map(time => time * 10)
        ).subscribe(time => this.time = time);
      }

      getTime() {
        return this.time;
      }

      ngOnDestroy() {
        this.timeSubscription.unsubscribe();
      }

    }
{% endraw %}

The component uses the `Default` change detection strategy,
so every time the observable emits a new value,
the change detection is triggered,
the template is refreshed
and the clock value displayed is updated.

But, do we really need a hundred updates per second?
Our eyes can't see that fast,
and it's putting pressure on our browser for nothing.
And remember that not only this component will be checked a hundred times per second,
but the whole application too!

Maybe in that case it would be enough to refresh the time displayed
every second for example.
To do so, you can completely opt out from the automatic change detection in your component,
and handle things yourself,
by injecting in your component a `ChangeDetectorRef`.
This class offers a few methods:

- `detach()`
- `detectChanges()`
- `markForCheck()`
- `reattach()`

The first two work together:
you can indicate to Angular to not care about the component with `detach`
and then manually call `detectChanges` when you want the change detection to run:

{% raw %}
    @Component({
      selector: 'ns-clock',
      template: `
        <h2>Clock</h2>
        <p>{{ getTime() }}</p>
        <button (click)="start()">Start</button>
      `
    })
    export class ClockComponent implements OnDestroy {
      time: number;
      timeSubscription: Subscription;

      constructor(private ref: ChangeDetectorRef) {
        this.ref.detach();
      }

      start() {
        this.timeSubscription = interval(10).pipe(
          take(1001), // 0, 1, ..., 1000
          map(time => time * 10)
        ).subscribe(time => {
          this.time = time;
          // manually trigger the change detection every second
          if (this.time % 1000 === 0) {
            this.ref.detectChanges();
          }
        });
      }

      getTime() {
        return this.time;
      }

      ngOnDestroy() {
        this.timeSubscription.unsubscribe();
      }

    }
{% endraw %}

As you can see, we slightly changed the component
to inject `ChangeDetectorRef`,
detach the component from the change detection,
and then manually run `detectChanges()` to trigger it
when we need it (every second in our case).
The `time` field is still updated a hundred times per second,
but now the clock displayed to our users is only updated every second!

Note that this only triggers a change detection on that component (and its children)
every time we run `detectChanges()`.

But there is a way to go one step further,
and completely handle it manually,
by updating the DOM yourself
(and not triggering a complete change detection):

    @Component({
      selector: 'ns-clock',
      template: `
          <h2>Clock</h2>
          <p #clock></p>
          <button (click)="start()">Start</button>
      `
    })
    export class ClockComponent implements OnDestroy {
      time: number;
      timeSubscription: Subscription;
      @ViewChild('clock') clock: ElementRef<HTMLParagraphElement>;

      constructor(private ref: ChangeDetectorRef) {
        this.ref.detach();
      }

      start() {
        this.timeSubscription = interval(10).pipe(
          take(1001), // 0, 1, ..., 1000
          map(time => time * 10)
        ).subscribe(time => {
          this.time = time;
          if (this.time % 1000 === 0) {
            this.clock.nativeElement.textContent = `${time}`;
          }
        });
      }

      ngOnDestroy() {
        this.timeSubscription.unsubscribe();
      }

    }

Here we grab a reference to the element we need to update,
and then we update the DOM manually when needed,
without triggering a change detection.

Another way to do this is possible:
you can completely run the code outside of Zone.js,
the library that triggers the change detection.
To do so, you can inject `NgZone`,
and then use its `runOutsideAngular` method to execute code
outside of its scope:

    constructor(private zone: NgZone) {
    }

    start() {
      this.zone.runOutsideAngular(() => {
        this.timeSubscription = interval(10).pipe(
          take(1001), // 0, 1, ..., 1000
          map(time => time * 10),
        ).subscribe(time => {
          this.time = time;
          if (this.time % 1000 === 0) {
            this.clock.nativeElement.textContent = `${time}`;
          }
        });
      });
    }

This produces the same results,
but here the rest of the component would still be checked automatically by Angular.
`runOutsideAngular` is more suited to use cases
where you want only specific portions of code to run out of the watch of Zone.js/Angular.

As I was saying, this example is a bit advanced,
but `ChangeDetectorRef` can be handy for some use cases.
Imagine that the example changing the color of a pony every second doesn't use an observable,
but a simple `setInterval`.

    @Component({
      selector: 'ns-pony',
      template: `<img [src]="getPonyImageUrl()">`,
      changeDetection: ChangeDetectionStrategy.OnPush
    })
    export class PonyComponent implements OnInit, OnDestroy {

      @Input() ponyModel: PonyModel;
      private intervalId: number;

      ngOnInit() {
        this.intervalId = window.setInterval(() => {
          this.ponyModel.color = this.randomColor();
        }, 1000);
      }

      ngOnDestroy(): void {
        window.clearInterval(this.intervalId);
      }

No visual update...
And in that case, we can't use the `async` pipe as we did with an observable...

But we can use the `markForCheck` method of `ChangeDetectorRef`
to manually trigger the change detection in an `OnPush` component:

    @Component({
      selector: 'ns-pony',
      template: `<img [src]="getPonyImageUrl()">`,
      changeDetection: ChangeDetectionStrategy.OnPush
    })
    export class PonyComponent implements OnInit, OnDestroy {

      @Input() ponyModel: PonyModel;
      private intervalId: number;

      constructor(private ref: ChangeDetectorRef) {
      }

      ngOnInit() {
        this.intervalId = window.setInterval(() => {
          this.ponyModel.color = this.randomColor();
          this.ref.markForCheck();
        }, 1000);
      }

      ngOnDestroy(): void {
        window.clearInterval(this.intervalId);
      }

And it works again!

If you enjoyed this blog post, you may want to dig deeper with our [ebook](https://books.ninja-squad.com/angular),
and/or with a complete exercise that we added in our [online training](https://angular-exercises.ninja-squad.com/).
The exercise takes an application and walks you through what we would do to optimize it,
measuring the benefits of each steps, showing you how to avoid the common traps,
how to test the optimized application, etc. Check it out if you want to learn more!

See you soon for part 5!
