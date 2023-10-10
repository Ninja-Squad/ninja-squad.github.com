---
layout: post
title: What's new in Angular 17?
author: cexbrayat
tags: ["Angular 17", "Angular", "Angular CLI"]
description: "Angular v17 is out!"
---

Angular&nbsp;v17 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/17.0.0">
    <img class="rounded img-fluid" style="max-width: 60%" src="/assets/images/angular_gradient.png" alt="Angular logo" />
  </a>
</p>

For French-speaking people, I talked about the release on the [Angular Devs France YouTube channel](https://www.youtube.com/live/YBty95aSP6c?si=E_n8L59HC5P1NUxe).

This is a major release packed with features: let's dive in!

## angular.dev

The Angular team has been cranking it communication-wise lately,
with a [live event](https://www.youtube.com/watch?v=Wq6GpTZ7AX0)
to unveil the new features of Angular v17,
and a new website called [angular.dev](https://angular.dev),
which will be the future official website.
It features the same documentation but with a new interactive tutorial,
and a playground to try Angular without installing anything
(as Vue or Svelte do as well).

Angular also has a new logo that you can see at the top of this post!

## Control flow syntax

Even if it is only a "developer preview" feature, this is a big one!
Angular templates are evolving to use a new syntax for control flow structures.

We wrote a dedicated blog post about this feature: 

👉 [Angular Control Flow Syntax](/2023/10/11/angular-control-flow-syntax/)

An experimental migration allows you to give it a try in your project.
The syntax should become stable in v18, and be the recommended way to write templates at that point.

## Deferrable views

Another big feature is the introduction of deferrable views using `@defer` in templates.

We wrote a dedicated blog post about this feature:

👉 [Angular Deferrable Views](/2023/11/02/angular-defer/)

This is a "developer preview" feature as well and should become stable in v18.
It's probably going to be less impactful than the control flow syntax,
but it's still interesting to have a way to easily lazy-load parts of a template.

## Signals are now stable!

The Signals API is now marked as stable 🎉.
Except `effect()`, and the RxJS interoperability functions `toSignal` and `toObservable`
which might change and are still marked as "developer preview".

The API has not changed much since our [blog post about Signals](/2023/04/26/angular-signals/), 
but some notable things happened.

### mutate has been dropped

`mutate()` has been dropped from the API.
You were previously able to write something like:

    users.mutate(usersArray => usersArray.push(newUser));

And you'll now have to write:

    users.update(usersArray => [...usersArray, newUser]);

The `mutate()` method was introducing some issues with other libraries,
and was not worth the trouble as it can be replaced by `update()` quite easily.

## template diagnostic

A new compiler diagnostic is available to help you spot missing signal invocations in your templates.

Let's say you have a `count` signal used in a template, but forgot the `()`:

{% raw %}
    <div>{{ count }}</div>
{% endraw %}

throws with:

    NG8109: count is a function and should be invoked: count()

### flushEffects

A new method is available (as a developer preview) 
on the `TestBed` class to trigger pending effects: `flushEffects`

    TestBed.flushEffects();

This is because effect timing has changed a bit:
they are no longer triggered by change detection but scheduled via the microtask queue
(like `setTimeout()` or `Promise.resolve()`).
So while you could previously trigger them by calling `detectChanges()` on the fixture,
you now have to call `TestBed.flushEffects()`.

### afterRender and afterNextRender phases

The `afterRender` and `afterNextRender` functions introduced in Angular v16.2
can now specify a `phase` option.
Angular uses this phase to schedule callbacks to improve performance.
There are 4 possible values, and they run in the following order:

- `EarlyRead` (when you need to read the DOM before writing to the DOM)
- `Write` (needed if you want to write to the DOM, for example, to initialize a chart using a third-party library)
- `MixedReadWrite` (default, but should be avoided if possible to use a more specific phase)
- `Read` (recommended if you only need to read the DOM)

I _think_ we should be able to use `Read` and `Write` in most cases.
`EarlyRead` and `MixedReadWrite` degrade performances, so they should be avoided if possible.

    export class ChartComponent {
      @ViewChild('canvas') canvas!: ElementRef<HTMLCanvasElement>;

      constructor() {
        afterNextRender(() => {
          const ctx = this.canvas.nativeElement;
          new Chart(ctx, { type: 'line', data: { ... } });
        }, { phase: AfterRenderPhase.Write });
      }
    }

### Performances

The internal algorithm changed to use a ref-counting mechanism instead of a mechanism based on bi-directional weak references. It should be more performant than it was in many cases.

It's also worth noting that the change detection algorithm has been improved to be more efficient when using Signals.
Previously, when reading a signal in a template, Angular was marking the component
and all its ancestors as dirty when the signal was updated
(as it currently does with when `OnPush` components are marked for check).
It's now a bit smarter and only marks the component as dirty when the signal is updated and not all its ancestors.
It will still check the whole application tree,
but the algorithm will be faster because some components will be skipped.

We don't have a way to write pure signal-based components yet, with no need for ZoneJS,
but it should be coming eventually!

## styleUrls as a string

The `styleUrls` and `styles` properties of the `@Component` decorator can now be a string instead of an array of strings.
A new property called `styleUrl` has also been introduced.

You can now write:

    @Component({
      selector: 'app-root',
      templateUrl: './app.component.html',
      styleUrl: './app.component.css',
    })
    export class AppComponent {}

## View Transitions router support 

The View Transitions API is a fairly new browser API
that allows you to animate the transition between two views.
It is only supported in recent versions of Chrome, Edge, and Opera (see 
[caniuse.com stats](https://caniuse.com/mdn-api_document_startviewtransition))
but not in Firefox yet.
It works by taking a screenshot of the current view and animating it to the new view.

I'm not very familiar with this API,
but there is a great article about it on
[developer.chrome.com](https://developer.chrome.com/docs/web-platform/view-transitions/)
and cool demos on [this site](https://http203-playlist.netlify.app/) (open it with a browser that supports this API of course).

Angular v17 adds support for this API in the router.
This is an experimental feature, and you'll have to enable it by using `withTransitionViews()`:

    bootstrapApplication(AppComponent, { 
      providers: [{ provideRouter(routes, withTransitionViews()) }] 
    });

By default, you get a nice fade-in/fade-out transition between views when navigating from one route to another.
You can customize the animation using CSS, animate the whole view or skip part of it,
or indicate which DOM elements are in fact the same entities in the old and new views:
the browser will then do its best to animate between the states.

It is possible to skip the initial transition by using the `skipInitialTransition` option:

    bootstrapApplication(AppComponent, { 
      providers: [{ provideRouter(routes, withTransitionViews({ skipInitialTransition: true })) }] 
    });

More advanced scenarios require to add/remove CSS classes to the views,
so the router also lets you run an arbitrary function when the transition is done
if you use the `onViewTransitionCreated` option to define a callback.

## Http

The fetch backend (introduced in [Angular v16.1](/2023/06/14/what-is-new-angular-16.1))
has been promoted to stable.

When using SSR, it is now possible to customize the transfer cache, using `withHttpTransferCacheOptions(options)`.
The options can be:

- `filter`: a function to filter the requests that should be cached
- `includeHeaders`: the list of headers to include (none by default)
- `includePostRequests`: whether or not to cache POST requests (by default only GET and HEAD requests are cached)

For example:

    bootstrapApplication(AppComponent, { 
      providers: [provideHttpClient({
        withHttpTransferCacheOptions({ includePostRequests: true })
      })
    });

## Devtools

The devtools received some love as well,
and they now allow you to inspect the dependency injection tree.

## Animations

No new feature for this part of Angular,
but it is now possible to lazy-load the animations package.
In a standalone application, you can use `provideAnimationsAsync()` instead of
using `provideAnimations()` and the necessary code for animations will be loaded asynchronously.

The application should work the same,
but you should see an extra chunk appear when building the application.
That's a few kilobytes of JavaScript that you don't have to load upfront 🚀.

You can disable animations by providing `'noop'` as the value of `provideAnimationsAsync()`:

    bootstrapApplication(AppComponent, { 
      providers: [provideAnimationsAsync('noop')] 
    });

## Performances

In dev mode, you'll now get a warning if you load an oversized image
or if an image is the "Largest Contentful Paint element" in the page and is lazy-loaded 
(which is a bad idea, see [the explanations here](https://angular.io/errors/NG0913#lazy-loaded-lcp-element)).

For example:

    An image with src image.png has intrinsic file dimensions much larger than its 
    rendered size. This can negatively impact application loading performance. 
    For more information about addressing or disabling this warning, see  
    https://angular.io/errors/NG0913

You can configure this behavior via dependency injection,
for example, if you want to turn off these warnings:

    {
      provide: IMAGE_CONFIG, useValue:
      {
        disableImageSizeWarning: false,
        disableImageLazyLoadWarning: false
      }
    }

## TypeScript 5.2 and Node.js v18

It's worth noting that Angular now requires TypeScript 5.2 and Node.js v18.
Support for older versions has been dropped.

## Angular CLI

A lot happened in the CLI!

👉 Check out our [dedicated blog post about the CLI v17](/2023/11/09/angular-cli-17.0/) for more details.

## Summary

That's all for this release, stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
