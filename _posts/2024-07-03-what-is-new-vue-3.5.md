---
layout: post
title: What's new in Vue 3.5?
author: cexbrayat
tags: ["Vue 3"]
description: "Vue 3.5 is out!"
---

Vue&nbsp;3.5.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/vuejs/core/blob/main/CHANGELOG.md#TODO">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/vue.png" alt="Vue logo" />
  </a>
</p>

The last minor release was v3.4.0 in December.
Since then, we have seen a few patch releases,
some coming with new features.

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
This feature is probably already familiar to [React developers](https://react.dev/reference/react/useId) or Nuxt developers who use the `useId` [composable](https://nuxt.com/docs/api/composables/use-id).

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
By default, Vue generates an ID with a prefix of `v:` followed by a unique number
(that increments when new components are rendered).
The prefix can be customized by using `app.config.idPrefix`.
`useId` also guarantees that the ID is stable between server-side rendering and client-side rendering, to avoid mismatching errors.

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

## onEffectCleanup

A new API called `onEffectCleanup` has been added to register a callback that will be called when a `watchEffect` is cleaned up.
This is similar to what the `onCleanup` parameter of `watchEffect` does,
but it allows to use the effect cleanup in functions called in an effect.

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
  //👇 we can now use onEffectCleanup
  onEffectCleanup(() => window.clearInterval(id));
}

const intervalTime = ref(1000);
watchEffect(() => {
  console.log('Interval time changed', intervalTime.value);
  //👇 no need to pass onCleanup anymore
  startInterval(intervalTime.value);
});
```

`onEffectCleanup` throws a warning if there is no current active effect.
This warning can be silenced by passing a second parameter to `onEffectCleanup`:
  
```ts
onEffectCleanup(() => {
  // cleanup code
}, true /* 👈 no warning */);
```

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
