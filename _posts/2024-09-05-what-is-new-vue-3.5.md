---
layout: post
title: What's new in Vue 3.5?
author: cexbrayat
tags: ["Vue 3"]
description: "Vue 3.5 is out!"
---

Vue&nbsp;3.5.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/vuejs/core/blob/main/CHANGELOG.md#350-2024-09-03">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/vue.png" alt="Vue logo" />
  </a>
</p>

The last minor release was v3.4.0 in December.
Since then, we have seen quite a few patch releases,
and some interesting new features.

Let's see what we have in this release!

## Props destructuration

Props destructuration was introduced as an experiment in Vue 3.3 (as part of the reactive transform experiment) and is now stable in Vue 3.5.

So instead of:

```ts
const props = withDefaults(defineProps<{ name?: string }>(), { name: "Hello" });
watchEffect(() => console.log(props.name));
```

You can now write:

```ts
const { name = "Hello" } = defineProps<{ name?: string }>();
watchEffect(() => console.log(name));
// ☝️ This gets compiled to the same code as the previous example
// so we don't lose the reactivity of the props
```

You no longer need the `propsDestructure: true` flag in the compiler options to use this feature,
so you can remove it if you have it.
You can however disable this feature by setting `propsDestructure: false` in the compiler options,
or even throw an error if you want to enforce the use of the previous syntax by setting `propsDestructure: 'error'`.

Read more about this feature in the [RFC](https://github.com/vuejs/rfcs/discussions/502).

## useTemplateRef

As you probably know, Vue lets you grab a reference to an element in a template, using the `ref="key"` syntax. The framework then populates a Ref named `key` in the setup of the component.
For example, to initialize a chart, you usually write code looking that:

```html
<canvas ref="chart"></canvas>
```

```ts
// 👇 special ref that Vue populates with the element in the template
const chart = ref<HTMLCanvasElement | null>(null); 
onMounted(() => new Chart(chart.value!, /* chart options */));
```

This API felt a bit awkward, as nothing was pointing out that this ref was "special" at first glance. It also forced developers to pass this ref around to composables.
For example, if you wanted to build a `useChart` composable, you had to write it like this:

```ts
export function useChart(chartRef: Ref<HTMLCanvasElement | null>) {
  onMounted(() => new Chart(chartRef.value!, /* chart options */));
}
```

And then call it in your component by passing it the ref:

```ts
const chart = ref<HTMLCanvasElement | null>(null); 
useChart(chart);
```

Vue v3.5 introduces a new composable called `useTemplateRef` to grab a reference in the template:

```ts
// useTemplateRef expects the key of the element in the template
const chartRef = useTemplateRef<HTMLCanvasElement>('chart');
onMounted(() => new Chart(chartRef.value!, /* chart options */));
```

The type of `chartRef` is a read-only `ShallowRef<HTMLCanvasElement | null>`.
In addition to a more explicit name and usage, the new function is usable directly inside a composable. This simplifies the pattern we saw above, as `useChart` can simply be written:

```ts
export function useChart(chartKey: string) {
  const chartRef = useTemplateRef<HTMLCanvasElement>(key);
  onMounted(() => new Chart(chartRef.value!, /* chart options */));
}
```

and then used in a component:

```ts
useChart('chart');
```

This is a nice improvement!

## useId

A new composition function called `useId` has been added to generate a unique ID.
This feature is probably already familiar to [React developers](https://react.dev/reference/react/useId) or Nuxt developers who use the `useId` composable.

This can be useful when you need to generate an ID for an HTML element,
for example when you use a label with an input, or for accessibility attributes:

```html
<label :for="id">Name</label>
<input :id="id" />
```

As the component can be rendered many times, you need to ensure that the ID is unique.
This is where `useId` comes in:

```ts
const id = useId();
```

`useId` guarantees that the generated ID is unique within the application.
By default, Vue generates an ID with a prefix of `v-` followed by a unique number
(that increments when new components are rendered).
The prefix can be customized by using `app.config.idPrefix`.
`useId` also guarantees that the ID is stable between server-side rendering and client-side rendering, to avoid mismatching errors.


## Lazy hydration strategies

Asynchronous components, defined with `defineAsyncComponent`,
can now control when they should be hydrated using a new `hydrate` option.

Vue provides four strategies for hydration in v3.5:

- `hydrateOnIdle()`: the component will be hydrated when the browser is idle (you can specify a timeout if needed, as `requestIdleCallback`, which is used internally, allows).
- `hydrateOnVisible()`: the component will be hydrated when it becomes visible in the viewport (implemented using an `IntersectionObserver`). Additional options supported by the [`IntersectionObserver` API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API) can be passed to the strategy, like  `rootMargin` to define the margin around the viewport. So you can use `hydrateOnVisible({ rootMargin: '100px' })` to hydrate the component when it is 100px away from the viewport.
- `hydrateOnInteraction(event)`: the component will be hydrated when the user interacts with the component with a defined event, for example `hydrateOnInteraction('click')`. You can also specify an array of events.
- `hydrateOnMediaQuery(query)`: the component will be hydrated when the media query matches. For example, `hydrateOnMediaQuery('(min-width: 600px)')` will hydrate the component when the viewport is at least 600px wide.

You can also define a define custom strategy if you want to.

Here is an example of how to use these strategies:

```ts
import { defineAsyncComponent, hydrateOnVisible } from 'vue'

const User = defineAsyncComponent({
  loader: () => import('./UserComponent.vue'),
 hydrate: hydrateOnVisible('100px')
});
```


## data-allow-mismatch

Vue 3.5 now supports a new attribute called `data-allow-mismatch`,
that can be added to any element to allow client/server mismatch warnings
to be silenced for that element.

For example, if you have a component that renders the current date like this:

{% raw %}
```html
<div>{{ currentDate }}</div>
```
{% endraw %}

you might get a warning if the server and the client render the date at different times:

```
[Vue warn]: Hydration text content mismatch on <div> 
 - rendered on server: Jul 26, 2024
 - expected on client: Jul 27, 2024
``` 

You can silence this warning by adding the `data-allow-mismatch` attribute:

{% raw %}
```html
<div data-allow-mismatch="text">{{ currentDate }}</div>
```
{% endraw %}

The value of the attribute can be:
- `text` to silence the warning for text content
- `children` to silence the warning for children content
- `class` to silence the warning for class mismatch
- `style` to silence the warning for style mismatch
- `attribute` to silence the warning for attribute mismatch


## Better types

A few improvements have been made to help the tooling understand the Vue API better.
For example, components that use `expose` will now have a more correct type.

An effort has also been made for directives.
It is now possible to specify the allowed modifiers for a directive in the type definition:

```ts
// can be used as v-focus.seconds in the template
export const vFocus: Directive<
  HTMLInputElement,
  boolean,
  'seconds' /* 👈 New! only 'seconds' is allowed as modifier */
> = (el, binding) => {
  const secondsModifier = binding.modifiers.seconds; // autocompletion works here
  ...
}
```

The built-in directives have also been improved to leverage this new feature.

Another improvement concerns the `computed` function:
you can now define a getter and a setter with different types (it was already working but TS was complaining):

```ts
const user = ref<UserModel>({ name: 'Cédric' });
const json = computed({
  get: () => JSON.stringify(user.value),
  // 👇 the setter receives a UserModel instead of a string
  set: (newUser: UserModel) => user.value = newUser;
}); // typed as ComputedRef<string, UserModel>
console.log(json.value); // 👈 a string
json.value = { name: 'JB' }; // 👈 no error
```


## app.onUnmount()

It is now possible to register a callback that will be called when the app is unmounted
(i.e when the `app.unmount()` method is called)
This can be useful to clean up resources or to log something if you unmount your application,
but it is even more useful for plugin developers.

Here is an example:

```ts
const myPlugin: Plugin = {
install (app: App) {
  function cleanupSomeSideEffect() { /* ...*/ }

  // Register the cleanup function to be called when the app is unmounted
  app.onUnmount(cleanupSomeSideEffect)
}
```

## Watcher novelties

### deep watch

The `watch` function had a `deep` option since the beginning.
It allows watching deeply nested properties of a ref:

```ts
const obj = ref({ super: { nested: { prop: 1 } } });
watch(obj, () => {
  // called when the ref or one of its nested properties changes
  console.log('nested prop changed');
}, { deep: true });
```

You don't need it for a `reactive` object though,
as `watch` will automatically watch deeply nested properties of a reactive object.
In that case, `deep` can be set to `false` if you want to disable this behavior.

The novelty introduced in Vue 3.5 is that you can now use `deep` with a specific depth:

```ts
const obj = ref({ super: { nested: { prop: 1 } } });
watch(obj, () => {
  // called when the ref or the first level of its nested properties changes
  console.log('nested prop changed');
}, { deep: 1 }); // 👈 deep can now be a number
```

### pause/resume

The `watch` and `watchEffect` can now be paused and resumed, in addition to being stopped.

Until now, you could only stop a watcher, which would prevent it from being called again:

```ts
const stop = watch(obj, () => {
  console.log('obj changed');
});
stop(); // 👈 stop the watcher
```

Now, you can pause and resume a watcher:

```ts
const { pause, resume, stop } = watch(obj, () => {
  console.log('obj changed');
});
pause(); // 👈 pause the watcher
resume(); // 👈 resume the watcher
stop(); // 👈 stop the watcher
``` 

### onWatcherCleanup

A new API called `onWatcherCleanup` has been added to register a callback that will be called when a `watch`/`watchEffect` is cleaned up.
This is similar to what the `onCleanup` parameter of watchers does,
but it allows to use the cleanup function in functions called inside a watcher.

Before
```ts
// starts an interval, called in the watchEffect below
function startInterval(intervalTime, onCleanup) {
  const id = window.setInterval(() => console.log('hello'), intervalTime)
  // we use onCleanup here to clear the interval
  onCleanup(() => window.clearInterval(id));
}

const intervalTime = ref(1000);
watchEffect((onCleanup) => {
  console.log('Interval time changed', intervalTime.value);
  // we need to pass onCleanup to startInterval
  startInterval(intervalTime.value, onCleanup);
});
```

Now
```ts
function startInterval(intervalTime) {
  const id = window.setInterval(() => console.log('hello'), intervalTime)
  //👇 we can now use onWatcherCleanup
  onWatcherCleanup(() => window.clearInterval(id));
}

const intervalTime = ref(1000);
watchEffect(() => {
  console.log('Interval time changed', intervalTime.value);
  //👇 no need to pass onCleanup anymore
  startInterval(intervalTime.value);
});
```

`onWatcherCleanup` throws a warning if there is no current active effect.
This warning can be silenced by passing a second parameter to `onWatcherCleanup`:
  
```ts
onWatcherCleanup(() => {
  // cleanup code
}, true /* 👈 no warning */);
```

A similar API has been introduced for the low level `effect` function, called `onEffectCleanup`.

## Trusted types

Vue 3.5 now supports [Trusted Types](https://web.dev/trusted-types/).
It should work out of the box by default.
This is done by automatically converting the strings generated by the compiler into `TrustedHTML` when they are used in a context where a Trusted Type is expected.
`v-html` is not supported out-of-the-box, but can also be used if you declare a custom policy.


## throwUnhandledErrorInProduction

A new option has been added to the app configuration to throw unhandled errors in production.
This can be useful to catch errors that are currently not caught because the default behavior is to log them in the console.

```ts
const app = createApp(App);
app.config.throwUnhandledErrorInProduction = true;
```

With this option enabled, you'll easily catch errors when rendering your application in production.
Note that the default is `false` to avoid breaking existing applications.

## Teleport

### deferred Teleport

It is now possible to add a `defer` attribute to `Teleport` to mark the component as deferred.
When doing so, the target of the teleportation doesn't have to already exist:
even if it appears later, the target can still be resolved.
A deferred Teleport waits until all other DOM content in the same update cycle has been rendered before locating the target container.

So we can now use `Teleport` with targets located in other components (as long as they are mounted in the same tick), or even use `Teleport` and a target inside a `Suspense` (whereas you previously had to target a container outside of the `Suspense` component).

```html
<Suspense>
  <Teleport defer to="#target">...</Teleport>
  <div id="target"></div>
</Suspense>
```

### Teleport and Transition

It is now possible to use a `Teleport` component directly inside a `Transition` component,
thus allowing to animate the appearance and the disappearance of an element in a different place in the DOM. This used to throw an error in Vue 3.4.

You can check out this [playground](https://deploy-preview-6548--vue-sfc-playground.netlify.app/#eNqdVm1v2zYQ/is3dUOSIrKdugMSzQ22Fv2wDVuLJRhQQF9o6WSxoUiBpPzSIP+9R1KSZcXxhwI2IN4999wL7056jP6o68m6wSiJFj/FcSr/UTkTkKmqVhKlhQ23JWSNsari39hSIBihrAEmc/hwdwdWM2m45UqaSSrj+DaVqVyYTPPagkHb1CThxKYtBO5CqwrOJlN/cr7PesAjaCzgqYUEVSoz4iauUm0CwTuHOi+YMHhBvqbBWXBssaoFs0gngMWysVZJ4Pm7NHL2ceUI0gh+zwTPHlppx2p1g2l0e0eiEOpiGgg8NdHd97mCZBWSecvnvTkACvSJWEXKpcp3vY60vr7hObWjOncKX8AW78khcSEOIw3hK+P8D8P3BRn4I4auGvCqRJajHuhIW85vw8VC0C6mJBlYTw+KGUQ+pi7daZdvqPZ0Xx8SHJgvjN0J95DK6WsCv4b7EqFQQqgNlyvwamoqjcAaq2JW14JjTnUEclFRgYzvRG+6b7n9DcCmRAm2RK5hzQ1fcsHtDrghitVKYO4tlzv4v8HJV9eqEOL4ohrImARkhosdUMC70PPEBeEG9v4cAeb0KFchkhINDYQP3lNOXYYTbxZT0Khj38qPrj6qZhnFlMDst1Q+DYAC2RpjSvU0bMDXSmgwLOMS9eVzrjEkkMcbXD5wG/uUCqWrBEzGBJ5fTa4uyB+EZI9oKBKaNH+L0WXUz67bG6NhD+Naa1Ub6socC3L/2Z3OfQiuZRN4rxSFSsk9nR5haqucr2Ed86Jtd7rrTDBjuruPK2YehmPm8IeIjaZ+Qn04G89hfa0OgEehYWBGOEK63djthh5DJWCNsP2UOdChgyl5aJfMCaejfXLEZYvoHLrjj7srlKKGO+3wBQy4a/chtICRtl3MYzGMImhJ4hYdPcf3e/xnrLg9P/N78eziOfT209+DbX4Qy8sFOn4enrrng2U3WHftFLoWDQNYq7BJEij4FnM/ct9iLnPcJnBzc3MdhlDVYf4BBBa2e97w3JYJXM1mv/gzbbtVSdpesGTZw0qrRubUzELpBPRqyc5nl9D+Jr+GKc+5cZsuAete6fvBb2NrdxDh58ZtRocYrqJ2oEJKh1xxhkJ4wjVqy2mFxEzwFZFWPM+9ryHTaD+1Gc5ns3rrSSqmV5yM6ezfDF5YszynFZzAGyeed9jn2b8qiiKolKbRizXLeWPIrrNQ29iULHcbaeakcE3/cc3m88FqbCvEhHixOmHOoZyHnEIKtJP7O+2ie/tmeXM9H1m7oR0atlmO3waHsxEMCqEYtYN2XdHBB0vbGqp2wVf0/lOSFre3SSP3DcIF6k+1/4pLoySwOR2lqTZ/eZn7OqL3TJBnJWYPR+RfzdbJ0uizpjejXtP3SK+zlA7aoP549y9u6blXUlKNIPQJ5X9olGhcjAH2ni6awh7gfLR/+k9Jao9783FrkW6sTcp/3hHyyePTiN5eH06kvg93Pnnr7aii0dN3LgCgKA==) from the PR author [edison1105](https://github.com/edison1105), showcasing this new feature.


## Custom elements

Vue v3.5 adds a bunch of features for custom elements.
As I don't personally use them, I'll just list the most notable here:

- `defineCustomElement` now supports disabling ShadowDom by setting the `shadowRoot` option to `false`;
- a `useHost()` composable has been added to get the host element and a `useShadowRoot()` composable has been added to get the shadow root of the custom element (which can be useful for CSS in JS);
- `emit` now supports specifying event options, like `emit('event', { bubbles: true })`;
- `expose` is now available in custom elements;
- custom elements can now define a `configureApp` method to configure the associated app instance,
for example to use plugins like the router;

## Developer experience

The Vue compiler will now emit a warning if you write invalid HTML nesting in your template (for example, a `div` inside a `p`):

```
warning: <div> cannot be child of <p>, according to HTML specifications. This can cause hydration errors or potentially disrupt future functionality.
```

We also have a new warning when a `computed` is self-triggering (i.e. it writes to one of its dependencies in its getter):

```
Computed is still dirty after getter evaluation
likely because a computed is mutating its own dependency in its getter.
State mutations in computed getters should be avoided.
Check the docs for more details: https://vuejs.org/guide/essentials/computed.html#getters-should-be-side-effect-free
```

This warning is not enabled by default, you need to set `app.config.warnRecursiveComputed` to `true` in your application configuration.

## Performances

A whole lot of optimizations have been made around reactivity.
The first notable one is that the reactivity system now uses a new algorithm to track dependencies.
It now relies on version counting and doubly linked lists.
If I'm not mistaken, this is really similar to what Preact did and explained in [this really interesting article](https://preactjs.com/blog/signal-boosting/).
This brings a few performance improvements (most notably around memory usage) and should make the reactivity system more predictable (computed values should now never be stale).

The other notable change is that array manipulation should also be faster, especially for large arrays.

## News from the ecosystem

### Vapor mode

Vapor (`@vue/vapor`) is making progress within its [repository](https://github.com/vuejs/core-vapor). You can play with it using the online REPL [here](https://vapor-repl.netlify.app).

### Vue router

Vue Router 4.4.0 is out and offers the possibility to have typed routes!

This can be done manually by adding the types yourself to your project
(for example in `env.d.ts`):

```ts
interface RouteNamedMap {
  // a route with no params, named 'users' and matching '/users'
 users: RouteRecordInfo<"users", "/users", Record<never, never>>;
  // a route with a param named 'id', named 'user' and matching '/user/:id'
 user: RouteRecordInfo<
    "user",
    "/users/:id",
 { id: string | number }, // raw parameters (allows to use the route with a number or a string)
 { id: string } // parameters we get with useRoute
 >;
}

declare module "vue-router" {
  interface TypesConfig {
 RouteNamedMap: RouteNamedMap;
 }
}
```

Then when you use a `RouterLink` or `router.push`, you get a nice auto-completion
and type-checking:

```html
<!-- 👇 you get an error if the route name has a typo -->
<!-- or if you define a parameter that does not exist or forget to define it -->
<RouterLink :to="{ name: 'users', params: { id: user.id } }">User</RouterLink>
```

Then when using `useRoute`, you get a typed `route` object:

```ts
// note the name of the route as a parameter
// which is necessary for TypeScript to know the type of the route
const route = useRoute('user'); 
console.log(route.params.id); // 👈 id is properly typed as a string!
console.log(route.params.other); // 👈 this throws an error
```

This is a nice addition even if manually defining the types is a bit cumbersome.

Note that if you are into file-based routing,
you can use [unplugin-vue-router](https://uvr.esm.is/) which will automatically generate the types for you! The plugin is still experimental though.

### create-vue

A new option has been added to `create-vue` to allow you to use the new [Devtools plugin](https://devtools-next.vuejs.org/),
a Vite plugin that allows you to use the Vue Devtools directly in the browser with an overlay.

```sh
npm create vue@latest my-app --devtools
```

### Nuxt

[Nuxt v3.12](https://nuxt.com/blog/v3-12) is out and paves the way for Nuxt 4.
You can try the changes using:

```ts
export default defineNuxtConfig({
 future: {
 compatibilityVersion: 4
 }
})
```

That's all for this release. Stay tuned for the next one!

Our [ebook](https://books.ninja-squad.com/vue), [online training](https://vue-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/vue) are up-to-date with these changes if you want to learn more!
