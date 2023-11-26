---
layout: post
title: What's new in Vue 3.4?
author: cexbrayat
tags: ["Vue 3"]
description: "Vue 3.4 is out!"
---

[Vue&nbsp;3.4.0](https://blog.vuejs.org/posts/vue-3-4) is here!

<p style="text-align: center;">
  <a href="https://github.com/vuejs/core/blob/main/CHANGELOG.md#TODO">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/vue.png" alt="Vue logo" />
  </a>
</p>

The last minor release was v3.3.0 in May.
Since then, we have seen a few patch releases,
some coming with new features.

Let's see what we have in this release!

## v-bind shorthand syntax

It is now possible to use a shorthand syntax 
for `v-bind` when the key and value have the same name!

```html
<!-- before -->
<div v-bind:id="id"></div>
<-- or -->
<div :id="id"></div>

<!-- after -->
<div v-bind:id></div>
<-- or -->
<div :id></div>
```

## Performances improvements for the reactivity system

Johnson Chu, the author of [Volar](https://github.com/vuejs/language-tools),
has done massive work to improve the performance of the reactivity system.

Let's consider a scenario where you have a `computed` A that depends on a `computed` B.
In Vue v3.3, if B is re-evaluated, A is also re-evaluated, even if B has the same value as before.
In Vue v3.4, A is not re-evaluated if B has the same value as before.
This is also true for `watch` functions.

Other improvements have been made for Arrays mutations,
for watchers that depend on multiple computed values,
and more (as you can see in the [PR description](https://github.com/vuejs/core/pull/5912)).

This should avoid a whole lot of unnecessary re-renders! 🚀
(and hopefully, don't introduce any regression 🤞).

## `computed` previous value 

You can now get the previous value in a `computed`,
as the first parameter of the getter function.

```ts
const count = ref(0);
const double = computed((prev) => {
  console.log(prev);
  return count.value * 2
});
count.value++;
// logs 0
```

This can be useful if you want to manually compare object values.
(`computed` internally uses `Object.is` to compare the previous and current values,
which is not always what you want, see the [PR description](https://github.com/vuejs/core/pull/9497)).
This is especially useful with the new reactivity system improvements.
In v3.4, a computed property will only trigger effects when its computed value has changed from the previous one.
But in the case of a computed that return new objects, Vue thinks that the previous and current values are different.
If you want to avoid triggering effects in that case, you can compare the previous and current values manually.

## Performances improvements for the compiler

The Vue compiler has been improved to be faster.
Evan rewrote the parser entirely, to avoid using regexes.
The code generation has also been improved.
They are now nearly 2 times faster!

This should not have a huge impact on your build times,
as the Vue compiler is not the only step in the build process
(you usually have the TypeScript compiler, the CSS preprocessor, etc.).

## Support for import attributes

It is now possible to use import attributes in SFC (both in JS and TS):

```ts
import json from "./foo.json" with { type: "json" }
```

The support for `using` has also been added (new feature for explicit resource management in JS, see the proposal [here](https://github.com/tc39/proposal-explicit-resource-management)).

## watch `once`

The `watch` function gained a new option called `once`.
When set to `true`, the watcher is removed after the first call.

```ts
watch('foo', () => {
  console.log('foo changed');
}, { once: true });
```

It was previously possible to achieve the same result by using the returned `stop` function:

```ts
const stop = watch('foo', () => {
  console.log('foo changed');
  stop();
});
```

## Props validation

As you probably know, Vue provides a mechanism to validate props.

```ts
defineProps({
  min: {
    type: Number,
    required: true,
    validator: (value) => value >= 0,
  },
  max: {
    type: Number,
    required: true,
    validator: (value) => value >= 0,
  }
})
```

In the above example, the `min` and `max` props must be positive numbers.
In Vue v3.4, the `validator` function is now called with a second argument
containing all the props, allowing to validate the value against other props.

```ts
defineProps({
  min: {
    type: Number,
    required: true,
    validator: (value) => value >= 0,
  },
  max: {
    type: Number,
    required: true,
    validator: (value, props) => value >= props.min,
  }
})
```

Then if you try to use the component with `max` being lower than `min`,
you will get a warning.

```html
Invalid prop: custom validator check failed for prop "max".
```

## SSR hydration mismatch warnings

When using SSR, the client-side hydration will now warn you with a message
that includes the mismatching element.
It was sometimes hard to find the mismatching element in the DOM,
as the warning was in v3.3:

```
[Vue warn]: Hydration completed but contains mismatches.
```

In v3.4, the warning now contains the actual element
(not only its tag name but the actual DOM element, so you can click on it),
allowing us to see where it is in the DOM and why it failed.

```
[Vue warn]: Hydration text content mismatch in <h2>:
- Server rendered: Hello server
- Client rendered: Hello client
```

Vue now also warns you if you have a mismatch in classes, styles, or attributes!

You can enable this feature in production as well by using a feature flag
in your Vite config called `__VUE_PROD_HYDRATION_MISMATCH_DETAILS__`:

```ts
export default defineConfig({
  plugins: [vue()],
  define: {
    __VUE_PROD_HYDRATION_MISMATCH_DETAILS__: true 
  }
});
```

## MathML support

It is now possible to write templates using MathML
(in addition to HTML and SVG)!

The template below displays a beautiful `x²`:

```html
<template>
  <math>
    <mrow><msup><mi>x</mi><mn>2</mn></msup></mrow>
  </math>
</template>
```

## defineModel

The `defineModel` function was introduced as an experimental API in v3.3,
is now a stable API.
It is now the recommended way to define custom v-models.


Compared to what we explained in our [previous blog post](/2023/05/15/what-is-new-vue-3.3), the `local` option has been removed (see [this discussion](https://github.com/vuejs/rfcs/discussions/503#discussioncomment-7566278) if you want to know why).
The model now automatically adapts based on whether the parent provides a `v-model` or not.

Another change it that it is now possible to handle modifiers.
For example, if you want to handle the `.number` modifier, you can do:

```ts
const [count, countModifiers] = defineModel({
  set(value) {
    if (countModifiers?.number) {
      return Number(value);
    }
    return value;
  }
});
console.log(countModifiers?.number); // true if the .number modifier is used
```

You can type the modifiers by using `defineModel<number, 'number'>({ ... })`.
The first type parameter is the type of the model value,
and the second one is the type of the modifiers (which can be a union type if you want to handle several ones).

You can play with this [demo](https://play.vuejs.org/#__DEV__eNqNU02P0zAQ/StWLu1Kjc2qnLrZsoD2ABILAm6EQ5pMWhfHtvyRrRTlvzN20pJ2KeLmmXmeefPxuuSt1rT1kKySzJaGa0csOK/XueSNVsaRjhioSU9qoxoyQ+jsFHqvGj36KQtGyDS7y2UuSyWtI2qzJ/fh/7wjpfLSrcgt6W9ymbGhGJZBw0GjReEALUKy3e266+LXvs8YWtEba7VpoyoQVPpmA+Y+TxBFY+I8IQyBGZvkShbJQDRtCk33VknssgvZ8jFg82RFoif4kHyw82TnnLYrxspK4jcsyFtDJTgmdcMeEMYMluQNpJVqHpb0NX2VmpIuWcWtm8Yo2CbdGPVswWCmPFlMajF0tmBSA7ICA+Z/a198e1H/Iv6CQ6DQ57LH8TiLe6r59mI4Jc6aCzCfteO4x7MhFUKo54/R54yHU0PlDspff/Hv7WFo7IuByGwyBFeYLeDqQvjx2xMc8H0K4qa9GBdyJfgVrBI+cBxg77yskPYEF9l+iLvmcvvdPh4cSHtsKhCN04j4uJRwZtda/0N3SZeTKR4vf6IhUcgtnmc4sJOeBkn8iOe6GOTwSVW85mDsT5RJBTWXgC4Q2XDgCzIbHrP1PLLAVPO2EB5ujqx4Tebnqd6M6jhBCArQeSPJU/SPCVClIYQtTBAxFCOhtYAJpJUAKtT2Wp07wlgcZSDjdkDGAMElRSjhlngL1b9lX/E2PvDJpfbuKHYc46jwAYdHHoDnSu9/AxtCnvc=) to see how it works.


## TypeScript improvements

An effort has been made to sanitize the types (which will be helpful for all libraries in the ecosystem).

A notable improvement for developers is that `app.directive`,
used to register global directives, can now be properly typed:

```ts
app.directive<HTMLElement, string>('custom', {
  mounted(el, binding) {
    // el is correctly typed as HTMLElement
    // binding is correctly typed as string
  }
})
```

## Deprecated features removed

The reactivity transform experiment has been removed.
It had been deprecated in v3.3.0 (see our [previous blog post](/2023/05/15/what-is-new-vue-3.3)).

Vnode hook events written like `vnodeMounted` have been deprecated in v3.3
(see our [previous blog post](/2023/05/15/what-is-new-vue-3.3))
and they are now no longer supported.
You should use the `@vue:` syntax instead, like `@vue:mounted`.

The `v-is` directive has also been removed.

## News from the ecosystem

### Vue 2 End of Life

Vue 2 has reached its end of life, and Evan wrote a blog post about it:

👉 https://blog.vuejs.org/posts/vue-2-eol

### Vapor mode

Vapor (`@vue/vapor`) is making progress with a [new repository](https://github.com/vuejs/core-vapor).

For now, it introduces two work-in-progress packages: a new compiler and a new runtime.
They only support the most basic features at the moment,
and aren't easily usable.
There is a playground in the repository if you want to try it out.

The biggest difference with Vue 3 is that Vapor generates a rendering function that does not rely on virtual DOM.

For example, the following component:

```vue
<script setup lang="ts">
import { ref, computed } from 'vue/vapor'

const count = ref(1)
const double = computed(() => count.value * 2)

const inc = () => count.value++
</script>

<template>
  <div>
    <h1 class="red">Counter</h1>
    <div>{{ count }} * 2 = {{ double }}</div>
    <button @click="inc">inc</button>
  </div>
</template>
```

generates the following render function:

```ts
function _sfc_render(_ctx) {
  const t0 = _template('<div><h1 class="red">Counter</h1><div> * 2 = </div><button>inc</button></div>');
  const n0 = t0();
  const { 0: [, { 1: [n3], 2: [n4] }] } = _children(n0);
  const n1 = _createTextNode(_ctx.count);
  const n2 = _createTextNode(_ctx.double);
  _prepend(n3, n1);
  _append(n3, n2);
  _on(n4, "click", (...args) => _ctx.inc && _ctx.inc(...args));
  _watchEffect(() => {
    _setText(n1, void 0, _ctx.count);
  });
  _watchEffect(() => {
    _setText(n2, void 0, _ctx.double);
  });
  return n0;
}
```

As you can see the render function is using a different strategy than Vue 3:
it creates the static elements, then it creates the dynamic elements,
and finally it updates the dynamic elements when needed using `watchEffect`.

You can check in the project's README the features that are supported and the ones that are not.


### Vue Test Utils

VTU should now have better type-checking support for TypeScript users.
For example `wrapper.setProps({ foo: 'bar' })` will now correctly error
if the component has no `foo` prop.

### create-vue

`create-vue` now generates projects using Vite v5,
which was [recently released](https://vitejs.dev/blog/announcing-vite5).

### Nuxt

Nuxt v3.9 is out as well, with the support of Vue 3.4.
It brings a lot of new features and experiments:
you can read more in the [official blog post](https://nuxt.com/blog/v3-9).


That's all for this release. Stay tuned for the next one!

Our [ebook](https://books.ninja-squad.com/vue), [online training](https://vue-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/vue)) are up-to-date with these changes if you want to learn more!
