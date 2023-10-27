---
layout: post
title: A guide to Angular Deferrable Views with @defer
author: cexbrayat
tags: ["Angular 17", "Angular"]
description: "Angular 17 introduces a new syntax to lazy-load parts of a template using @defer. Let's dive in!"
---

With the introduction of the [Control flow syntax](/2023/10/11/angular-control-flow-syntax),
the Angular team has also introduced a new way to load components lazily
(as a developer preview for now).
We already have lazy-loading in Angular, but it is mainly based on the router.

Angular v17 adds a new way to load components lazily, using the `@defer` syntax in your templates.

`@defer` lets you define a block of template that will be loaded lazily when a condition is met
(with all the components, pipes, directives, and libraries used in this block lazily loaded as well).
Several conditions can be used.
For example, it can be "as soon as possible (no condition)",
"when the user scrolls to that section",
"when the user clicks on that button" or "after 2 seconds".

Let's say your home page displays a "heavy" `ChartComponent` that uses a charting library
and some other dependencies, like a `FromNow` pipe:

{% raw %}
    @Component({
      selector: 'ns-chart',
      template: '...',
      standalone: true,
      imports: [FromNowPipe],
    })
    export class ChartComponent {
      // uses chart.js
    }
{% endraw %}

This component is used in the home page:

{% raw %}
    import { ChartComponent } from './chart.component';

    @Component({
      selector: 'ns-home',
      template: `
        <!-- some content -->
        <ns-chart />
      `,
      standalone: true,
      imports: [ChartComponent]
    })
    export class HomeComponent {
      // ...
    }
{% endraw %}

When the application is packaged, the `ChartComponent` will be included in the main bundle:


    +------------------------+
    | main-xxxx.js  -  300KB |
    +------------------------+
    | home.component.ts      |
    | chart.component.ts     |
    | from-now.pipe.ts       |
    | chart.js               |
    +------------------------+

Let's say that the component is not visible at first on the home page,
maybe because it is at the bottom of the page, or because it is in a tab that is not active.
It makes sense to avoid loading this component eagerly
because it would slow down the initial loading of the page.

With `@defer`, you can load this component only when the user really needs it.
Just wrapping the `ChartComponent` in a `@defer` block will do the trick:

{% raw %}
    import { ChartComponent } from './chart.component';

    @Component({
      selector: 'ns-home',
      template: `
        <!-- some content -->
        @defer (when isVisible) {
          <ns-chart />
        }
      `,
      standalone: true,
      imports: [ChartComponent]
    })
{% endraw %}

The Angular compiler will rewrite the static import of the `ChartComponent`
to a dynamic import (`() => import('./chart.component')`),
and the component will be loaded only when the condition is met.
As the component is now imported dynamically,
it will not be included in the main bundle.
The bundler will create a new chunk for it:

    +------------------------+
    | main-xxxx.js  -  100KB |
    +------------------------+       +-------------------------+
    | home.component.ts      |------>| chunk-xxxx.js - 200KB   |
    +------------------------+       +-------------------------+
                                     | chart.component.ts      |
                                     | from-now.pipe.ts        |
                                     | chart.js                |
                                     +-------------------------+

The `chunk-xxxx.js` file will only be loaded when the condition is met,
and the `ChartComponent` will be displayed.

Before talking about the various kinds of conditions that can be used with `@defer`,
let's see how to use another interesting feature:
displaying a placeholder until the deferred block is loaded.

## `@placeholder`, `@loading`, and `@error`

You can define a placeholder template with `@placeholder`
that will be displayed until the loading condition is met.
Then, while the block is loading, you can display a loading template with `@loading`.
If no `@loading` block is defined, the placeholder stays there until the block is loaded.
You can also define an error template with `@error` that will be displayed if the block fails to load.

{% raw %}
    @defer (when show) {
      <ns-chart />
    }
    @placeholder {
      <div>Something until the loading starts</div>
    }
    @loading {
      <div>Loading...</div>
    }
    @error {
      <div>Something went wrong</div>
    }
{% endraw %}

When using server-side rendering,
only the placeholder will be rendered on the server (the defer conditions will never trigger).

## `after` and `minimum`

As the `@defer` block loading can be quite fast,
there is a risk that the loading block is displayed and hidden too quickly,
causing a "flickering" effect.

To avoid this, you can use the `after` option to specify after how many milliseconds
the loading should be displayed.

If the block takes less than this delay to load, then the `@loading` block is never displayed.

You can also use the `minimum` option to specify a minimum duration for the loading.
If the loading is faster than the minimum duration,
then the loading will be displayed for the minimum duration (this only applies if the loading is ever displayed).

You can of course combine all these options:

{% raw %}
    @defer (when show) {
      <ns-chart />
    }
    @placeholder {
      <div>Something until the loading starts</div>
    }
    @loading (after 500ms; minimum 500ms) {
      <div>Loading...</div>
    }
{% endraw %}

You can also specify a `minimum` duration for the placeholder.
It can be useful when the loading condition is immediate (for example, when no condition is specified).
In that case, the placeholder will be displayed for the minimum duration,
even if the block is loaded immediately,
to avoid a "flickering" effect.

{% raw %}  
    @defer (when show) {
      <ns-chart />
    }
    @placeholder (minimum 500ms) {
      <div>Something until the loading starts</div>
    }
    @loading (after 500ms; minimum 500ms) {
      <div>Loading...</div>
    }
{% endraw %}

## Conditions

Several conditions can be used with `@defer`,
let's see them one by one.

### No condition or `on idle`

The simplest condition is to not specify any condition at all:
in this case, the block will be loaded when the browser is idle
(the loading is scheduled using `requestIdleCallback`).

{% raw %}
    @defer {
      <ns-chart />
    }
{% endraw %}

This is equivalent to using the `on idle` condition:

{% raw %}
    @defer (on idle) {
      <ns-chart />
    }
{% endraw %}

### Simple boolean condition with `when`

You can also use a boolean condition to load a block of the template with `when`.
Here, we display the defer block only when the `show` property of the component is true:

{% raw %}
    @defer (when show) {
      <ns-chart />
    }
{% endraw %}

Note that this is not the same as using `*ngIf` on the block,
as the block will not be removed even if the condition becomes false later.

### on `immediate`

The `on immediate` condition triggers the loading of the block immediately.
It does not display a placeholder, even if one is defined.

### on `timer`

The `on timer` condition triggers the loading of the block after a given duration,
using `setTimeout` under the hood.

{% raw %}
    @defer (on timer(2s)) {
      <ns-chart />
    }
{% endraw %}

### on `hover`

Other conditions are based on user interactions.
These conditions can specify the element of the interaction using a template reference variable,
or none to use the placeholder element.
In the latter case, the placeholder element must exist
and have a single child element that will be used as the element of the interaction.

The `on hover` condition triggers the loading of the block when the user hovers the element.
Under the hood, it listens to the `mouseenter` and `focusin` events.

{% raw %}
    <span #trigger>Hover me</span>

    @defer (on hover(trigger)) {
      <ns-chart />
    }
{% endraw %}

or using the placeholder element:

{% raw %}
    @defer (on hover) {
      <ns-chart />
    }
    @placeholder {
      <span>Hover me</span>
    }
{% endraw %}

### on `interaction`

The `on interaction` condition triggers the loading of the block when the user interacts with the element.
Under the hood, it listens to the `click` and `keydown` events.

### on `viewport`

The `on viewport` condition triggers the loading of the block when the element becomes visible in the viewport.
Under the hood, it uses an [intersection observer](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API).

### Multiple conditions

You can also combine multiple conditions using a comma-separated list:

{% raw %}
    <!-- Loads if the user hovers the placeholder, or after 1 minute -->
    @defer (on hover, timer(60s)) {
      <ns-chart />
    }
    @placeholder {
      <span>Something until the loading starts</span>
    }
{% endraw %}

## Prefetching

`@defer` allows you
to separate the loading of a component from its display.
You can use the same conditions we previously saw to load a component using `prefetch`,
and then display it with another condition.

For example, you can prefetch the lazy-loaded content `on idle`
and then display it `on interaction`:

{% raw %}  
    @defer (on interaction; prefetch on idle) {
      <ns-chart />
    }
    @placeholder {
      <button>Show me</button>
    }
{% endraw %}

Note that the `@loading` block will not be displayed if the deferred block is already prefetched
when the loading condition is met.

## How to test deferred loading?

When a component uses defer blocks in its template,
you'll have to do some extra work to test it.

The `TestBed` API has been extended to help you with that.
The `configureTestingModule` method now accepts a `deferBlockBehavior` option.
By default, this option is set to `DeferBlockBehavior.Manual`,
which means that you'll have to manually trigger the display of the defer blocks.
But let's start with the other option instead.

You can change this behavior by using `DeferBlockBehavior.Playthrough`.
Playthrough means that the defer blocks will be displayed automatically
when a condition is met, as they would when the application runs in the browser.

    beforeEach(() => {
      TestBed.configureTestingModule({
        deferBlockBehavior: DeferBlockBehavior.Playthrough
      });
    });

In that case, the defer blocks will be displayed automatically when a condition is met,
after calling `await fixture.whenStable()`.

So if we test a component with a deferred block that is visible after clicking on a button,
we can use:

    // Click the button to trigger the deferred block
    fixture.nativeElement.querySelector('button').click();
    fixture.detectChanges();

    // Wait for the deferred block to render
    await fixture.whenStable();

    // Check its content
    const loadedBlock = fixture.nativeElement.querySelector('div');
    expect(loadedBlock.textContent).toContain('Some lazy-loaded content');

If you want to use the `DeferBlockBehavior.Manual` behavior,
you'll have to manually trigger the display of the defer blocks.
To do so, the fixture returned by `TestBed.createComponent` now has an async `getDeferBlocks` method
that returns an array of `DeferBlockFixture` objects.
Each of these fixtures has a `render` method that you can call to display the block
in a specific state, by providing a `DeferBlockState` parameter.

`DeferBlockState` is an enum with the following values:

- `DeferBlockState.Placeholder`: display the placeholder state of the block
- `DeferBlockState.Loading`: display the loading state of the block
- `DeferBlockState.Error`: display the error state of the block
- `DeferBlockState.Complete`: display the defer block as if the loading was complete

This allows a fine-grained control of the state of the defer blocks.
If we want to test the same component as before, we can do:

    const deferBlocks = await fixture.getDeferBlocks();
    // only one defer block should be found
    expect(deferBlocks.length).toBe(1);

    // Render the defer block
    await deferBlocks[0].render(DeferBlockState.Complete);

    // Check its content
    const loadedBlock = fixture.nativeElement.querySelector('div');
    expect(loadedBlock.textContent).toContain('Some lazy-loaded content');

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
