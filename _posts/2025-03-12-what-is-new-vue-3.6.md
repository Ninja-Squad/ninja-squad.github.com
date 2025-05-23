---
layout: post
title: What's new in Vue 3.6?
author: cexbrayat
tags: ["Vue 3"]
description: "Vue 3.6 is out!"
---

Vue&nbsp;3.6.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/vuejs/core/blob/main/CHANGELOG.md#360-2025-02-12">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/vue.png" alt="Vue logo" />
  </a>
</p>

The last minor release was v3.5.0 in September.
Let's see what we have in this release!

## Vapor mode is here 🤯

The biggest novelty in this release is the introduction of Vapor, a new (experimental) way to write Vue components.
A massive PR has been merged to introduce this new mode, resulting in the work of many contributors over the last year.
As we explained in our [previous blog post](/2023/12/29/what-is-new-vue-3.4),
Vapor is a new way to write Vue components that do not rely on Virtual DOM at runtime,
but generates optimized code to create/update templates at build time,
like other frameworks such as Svelte or Angular.

Even if Vue 3 used a "compiler-enhanced" VDOM
(compared to a pure VDOM implementation like React or Vue 2),
VDOM still adds some overhead at runtime,
and Vapor aims to remove this overhead.
The early benchmarks show that Vapor would bring Vue to the level
of Svelte 5 and SolidJS in terms of performance.

As Vue developer, we should be able to write the same source code for our components, but the output of the Vue compiler will be different for Vapor components.

Vue 3.6 introduces a new `vapor` attribute that you can use on `script` tags to enable this new mode. The component can then be written as a "classic" setup component (`vapor` implies `setup`):

```vue
<template>
  <button @click="increment()">{{ count }}</button>
</template>

<script vapor lang="ts">
import { ref } from 'vue';
const count = ref(0);
function increment() {
  count.value++;
}
</script>
```

The generated code for this component is different from the one generated for a "classic" setup component, as you can see on the [online REPL](https://vapor-repl.netlify.app/#eNp9kM1OwzAQhF/F8qWtWqVIcCppxY96gAMg4OhLcDfBrWNH9jpUivLurB1aeqh6S2Zmx99ux++bJmsD8AXPEepGFwgrYRjLvwKiNexOaiV3S8GVkQ5qMDieCL7qOiZtMMj6Pp8PURrL5ycd9OulUw2ytmisY7owFfWgp3FhVE0aso45KFnPSmdrNiKQ0a0w0hqPf/3LGBhfTUgug5GoiOkEhXURNkWzttABplNK9hFleHzFZ/QkNZaqyrbeGto0zQgubd0oDe61ia2EtRjaoldobX+ek4YuwOygy2+QuzP61u+jJvibAw+uBcGPHhauAhzs9ccL7On7aNZ2EzSlL5jv4K0OkXGIPQSzIeyTXKJ9ShdVpvr06z2C8YelImhM9ikvOF358cLq/7jX2U2ao4Py/hcoo7oU).

If your component only contains a template, you can also add the `vapor` attribute on the `template` tag:

```vue
<template vapor>
  <h1>Hello!</h1>
</template>
```

Not all features are usable with these `vapor` components.
For example `Suspense` and `KeepAlive` are not supported yet.

It is possible to build a full application using Vapor,
thanks to `createVaporApp`:

```ts
import { createVaporApp } from 'vue';
import App from './App.vue';

createVaporApp(App).mount('#app');
```

In that case, you won't even ship the VDOM runtime in your bundle,
and the Vapor runtime will be used instead.

Or you can mix Vapor components with VDOM components in the same application,
with `vaporInteropPlugin`:

```ts
import { createApp, vaporInteropPlugin } from 'vue';
import App from './App.vue';

createApp(App).use(vaporInteropPlugin).mount('#app');
```

This is probably going to be the most common use case for a while,
as it allows you to progressively migrate your application to Vapor,
or just use Vapor for some components that need to be optimized.

Under the hood, Vapor and VDOM components use shared component instance,
which means a bunch of features are shared between the two runtime modes
(lifecycle hooks, provide/inject, etc.). 
This means opting into Vapor mode only adds around 3-4kb to the bundle at the moment,
as the Vapor runtime overhead is quite low.

This is highly experimental,
but Vue 3.6 is a great opportunity to play with it and give feedback to the Vue team!

## Performances

A huge work has also been done by [@johnsoncodehk](https://github.com/johnsoncodehk) (the author of Volar) to improve the performance of Vue 3.6.

Over the past months, he worked on [alien-signals](https://github.com/stackblitz/alien-signals), a research project to improve the performance of Signals in general.
The current implementation of the standard proposal is based on the Angular one and is quite slow compared to the others,
as you can see on [this benchmark](https://github.com/transitive-bullshit/js-reactivity-benchmark) comparing signals implementations.
alien-signals are really fast!

This work has been integrated into Vue 3.6,
and the performance improvements are noticeable in some cases.
The [alien-signals README](https://github.com/stackblitz/alien-signals?tab=readme-ov-file#alien-signals) shows that all operations are faster than in Vue 3.4,
sometimes close to 10x faster!

This also comes with lower memory usage, so we're spoiled with this release!

## TemplateRef

`useTemplateRef()`, introduced in [Vue v3.5](/2024/09/05/what-is-new-vue-3.5),
now has its own type: `TemplateRef`.

```ts
// Vue 3.5
const chartRef: Readonly<ShallowRef<HTMLCanvasElement | null>> = useTemplateRef('chart');
// Vue 3.6
const chartRef: TemplateRef<HTMLCanvasElement | null> = useTemplateRef('chart');
```

## News from the ecosystem

### Rolldown

[Rolldown](https://rolldown.rs/),
the "Rust-based Rollup" that Evan's new company VoidZero is actively developing,
is making progress, and has been released in a v1.0 beta in December.
The underlying pieces based on the oxc toolchain are also progressing quite fast,
and the parser and linter are now ready for mass consumption.
The work on the minifier has been started as well, but it isn't ready yet.

rolldown-vite (the Vite version based on Rolldown) is also making progress,
and we should soon be able to try it out!

### Nuxt

[Nuxt](https://nuxt.com/) v3.16 has been released with a new project generator: `npm create nuxt`!
Nuxt also introduced "delayed hydration" to improve the performance of your application,
built on top of the lazy hydration strategies [introduced in Vue v3.5](/2024/09/05/what-is-new-vue-3.5):

```vue
<!-- Hydrate when component becomes visible in viewport -->
<LazyExpensiveComponent hydrate-on-visible />
  
<!-- Hydrate when browser is idle -->
<LazyHeavyComponent hydrate-on-idle />

<!-- Hydrate on interaction (mouseover in this case) -->
<LazyDropdown hydrate-on-interaction="mouseover" />

<!-- Hydrate when media query matches -->
<LazyMobileMenu hydrate-on-media-query="(max-width: 768px)" />

<!-- Hydrate after a specific delay in milliseconds -->
<LazyFooter :hydrate-after="2000" />
```
It also started to use `oxc-parser` for better performance.

### create-vue

[`create-vue`](https://github.com/vuejs/create-vue) has been updated to v3.15,
and it introduced a few changes over the last few months.

The new projects generated with ESLint now use ESLint v9 and a flat configuration.
It is now also possible to use oxlint as a linter,
by using the `--eslint-with-oxlint` option!

The [devtools](https://devtools-next.vuejs.org/) are now installed by default in the generated projects.

And if you want a simpler skeleton (fewer components and assets) to start with, you can now use the `--bare` option.

That's all for this release. Stay tuned for the next one!

Our [ebook](https://books.ninja-squad.com/vue), [online training](https://vue-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/vue) are up-to-date with these changes if you want to learn more!
