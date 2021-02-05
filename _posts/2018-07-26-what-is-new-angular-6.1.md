---
layout: post
title: What's new in Angular 6.1?
author: cexbrayat
tags: ["Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4"]
description: "Angular 6.1 is out! Read about the new keyvalue pipe, the new features of the router and more!"
---

Angular&nbsp;6.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#610-2018-07-25">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

## keyvalue pipe

Angular&nbsp;6.1 introduced a new pipe!
It allows iterating over a Map or an object,
and displaying the keys/values in our templates.

Note that it orders the keys:

- first lexicographically if they are both strings
- then by their value if they are both numbers
- then by their boolean value if they are both booleans (`false` before `true`).

And if the keys have different types,
they will be cast to strings and then compared.

    {% raw %}
    @Component({
      selector: 'ns-ponies',
      template: `
        <ul>
          <!-- entry contains { key: number, value: PonyModel } -->
          <li *ngFor="let entry of ponies | keyvalue">
            {{ entry.key }} - {{ entry.value.name }}
          </li>
        </ul>`
    })
    export class PoniesComponent {
      ponies = new Map<number, PonyModel>();

      constructor() {
        this.ponies.set(103, { name: 'Rainbow Dash' });
        this.ponies.set(56, { name: 'Pinkie Pie' });
      }
    }
    {% endraw %}

If you have `null` or `undefined` keys,
they will be displayed at the end.

It's also possible to define your own comparator function:

    {% raw %}
    @Component({
      selector: 'ns-ponies',
      template: `
        <ul>
          <!-- entry contains { key: PonyModel, value: number } -->
          <li *ngFor="let entry of poniesWithScore | keyvalue:ponyComparator">
            {{ entry.key.name }} - {{ entry.value }}
          </li>
        </ul>`
    })
    export class PoniesComponent {

      poniesWithScore = new Map<PonyModel, number>();

      constructor() {
        this.poniesWithScore.set({ name: 'Rainbow Dash' }, 430);
        this.poniesWithScore.set({ name: 'Pinkie Pie' }, 125);
      }

      /*
       * Defines a custom comparator to order the elements by the name of the PonyModel (the key)
       */
      ponyComparator(a: KeyValue<PonyModel, number>, b: KeyValue<PonyModel, number>) {
        if (a.key.name === b.key.name) {
          return 0;
        }
        return a.key.name < b.key.name ? -1 : 1;
      }
    }
    {% endraw %}

## TypeScript 2.9 support

Angular&nbsp;6.0 was stuck with TS 2.7,
but Angular&nbsp;6.1 catches up and adds support for TS 2.8 and 2.9.

You can check out what these new versions bring on the Microsoft blog:

- [Announcing TS 2.8](https://blogs.msdn.microsoft.com/typescript/2018/03/27/announcing-typescript-2-8/)
- [Announcing TS 2.9](https://blogs.msdn.microsoft.com/typescript/2018/05/31/announcing-typescript-2-9/)


## Shadow DOM v1 support

As you may know, Angular offers an `encapsulation` option
that allows to scope CSS styles to their component,
and their component only.

Until 6.1, Angular had three available options for this encapsulation option:

- `Emulated`, which is the default one
- `Native`, which relies on Shadow DOM v0
- `None`, which means you don't want encapsulation

Angular&nbsp;6.1 introduces a new option: `ShadowDom`, which relies on Shadow DOM v1,
the latest version of the specification.
Theoretically, it should be replacing the `Native` option
(as the Shadow DOM v0 specification is now deprecated),
but it would be a breaking change,
so the team decided to introduce a brand new option.

If you're into it, you can check out [this awesome blog post](https://hayato.io/2016/shadowdomv1/) listing the differences
between Shadow DOM v0 and Shadow DOM v1.
You can see the current support from the major browsers [here](https://caniuse.com/#feat=shadowdomv1).
The support for Shadow DOM v1 will be better than for Shadow DOM v0 in the near future,
as more browser vendors feel this is the right way to go.

Angular abstracts all the nitty gritty things to know about that,
as you just have one option to switch to use Shadow DOM v1,
and that's pretty cool.

This new support also allows Angular Element to be used with the `slot` elements
for basic native content projection.

## Tree-shakeable services in core

You may remember that Angular&nbsp;6.0 introduced [tree-shakeable services](/2018/05/04/what-is-new-angular-6/),
with the possiblity to declare a service using `@Injectable({ providedIn: 'root' })`.
The core services of the framework are starting to move to this new declaration,
with the first two services: `Title` (which allows setting the title of the page)
and `Meta` (which allows setting the metadata of the page).

It means that if you are not using them in your application,
they will now not end up in your final bundle,
saving a few bytes of JavaScript to send to our users.

## Router scrolling position restoration

The router received some love in this release with the addition of a few features.
The first one is an option allowing to restore the scrolling position
when you navigate back to a component.

You simply have to add the option to your `RouterModule` configuration:

    imports: [
      RouterModule.forRoot(routes, {
        scrollPositionRestoration: 'enabled'
      })
    ]

Three differents values can be passed to this option:

- `disabled`, which does nothing (default).
- `top`, which sets the scroll position to [0,0].
- `enabled`, which sets the scroll position to the stored position.

The `enabled` option will be the default in the future.
With this option, the router stores the scroll position when navigating forward,
and restores it when navigating back.
When navigating forward, the scroll position will be set to [0, 0], or to the anchor if one is provided.

It also adds an `anchorScrolling` option,
to configure if the router should scroll to the element
when the url has a fragment.
It has two possible values:
- `disabled`, which does nothing (default).
- `enabled`, which scrolls to the element. This option will be the default in the future.

And there is also a `scrollOffset` option, if you want to add an offset to the scrolling.
It accepts a position, or a function returning a position.

The router now also emits a new event called `Scroll` that you can listen to.

On paper, this looks super handy: if you have a very long template in a component,
when a user navigates back to it, she will end up on her last scrolling position.

I say "on paper", because in reality this only works with static content!
If you have dynamic content displayed in the template
(let's say a very long list that you fetch from the server),
the router will attempt to scroll even before the content is inserted...
So it won't scroll to the correct position,
because this position will not exist when the router tries to scroll to it.

If you are in a case like this,
you'll have to write tedious code to trigger the scroll yourself in the component,
by using a new service offered by the `@angular/router` package,
called `ViewportScroller`.

You could think that if the data are loaded via a `resolver`,
the router would handle it correctly,
because the data are loaded before the component is displayed,
so it would make sense that the router would scroll to the right position in that case.

But sadly, currently, no...
We opened an issue right away with this feedback
(you can add a [thumb up](https://github.com/angular/angular/issues/24547) if you agree),
but it is currently not adressed in 6.1.0.

So if you have dynamic content, you'll have to handle the scroll yourself,
by writing tedious code looking like this, even if the data comes from a `resolver`:

    export class PendingRacesComponent {
      scrollPosition: [number, number];
      races: Array<RaceModel>;

      constructor(route: ActivatedRoute, private router: Router, private viewportScroller: ViewportScroller) {
        this.races = route.snapshot.data['races'];
        this.router.events.pipe(
          filter(e => e instanceof Scroll)
        ).subscribe(e => {
          if ((e as Scroll).position) {
            this.scrollPosition = (e as Scroll).position;
          } else {
            this.scrollPosition = [0, 0];
          }
        });
      }

      ngAfterViewInit() {
        this.viewportScroller.scrollToPosition(this.scrollPosition);
      }

    }

And you'll have to do the same in every component where you want the scroll position to be restored...

## Router &mdash; URI error handler

You may have noticed that if a user tries to access a badly formed URL in your Angular application,
the router will redirect to the root of the application.

Angular&nbsp;6.1 introduces a new function called `malformedUriErrorHandler`
that you can provide to redirect your user to a different page.

    imports: [
      RouterTestingModule.forRoot(routes, {
        malformedUriErrorHandler:
          // redirects the user to `/invalid-uri`
          (error: URIError, urlSerializer: UrlSerializer, url: string) => urlSerializer.parse('/invalid-uri')
      })
    ]

As you can see, the handler receives the badly formed URL and the error,
so you can even display a proper error to your users if you want.

## Router &mdash; URL update strategy

In the same vein, if the router navigates to a component,
and the navigation fails, the URL is currently not updated.

A new option `urlUpdateStrategy` has been introduced,
and can receive either: `deferred` or `eager`.
`deferred` is the default and only updates the URL if the navigation succeeds,
as it is the case currently.
`eager` will start by updating the URL and then navigate to the component,
so the URL will be updated even if the navigation fails.

## Angular CLI 6.1

The CLI has also been released in 6.1.0: check out [our other article](/2018/07/27/angular-cli-6.1/) about what's new!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
