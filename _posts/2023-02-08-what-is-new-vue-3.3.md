---
layout: post
title: What's new in Vue 3.3?
author: cexbrayat
tags: ["Vue 3"]
description: "Vue 3.3 is out!"
---

Vue&nbsp;3.3.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/vuejs/vue-next/blob/main/CHANGELOG.md#TODO">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/vue.png" alt="Vue logo" />
  </a>
</p>

The last minor release was v3.2.0 in August 2021!
Since then, we have seen a lot of patch releases,
some coming with new features.

Originally, the v3.3 release was supposed to bring 
Suspense and the Reactivity Transform APIs out of
their experimental state.

Is that the case? 
Let's see what we have in this release (and some interesting bits from the 47 patches since v3.2.0)!

## Hello Reactivity Transform, and goodbye!

During the last year and a half, the Vue team pursued its experiments with ref sugar
(see our [previous blog post](/2021/08/10/what-is-new-vue-3.2/) to catch up).

Currently, without ref sugar, you write code like this:

    import { ref, computed, watchEffect } from 'vue';
    const quantity = ref(0);
    const total = computed(() => quantity.value * 10);
    watchEffect(() => console.log(`New total ${total.value}`));

Note the `.value` that you need to access the value of the `quantity` or `total` ref.
If you use the Composition API, you're used to it.

The reactivity transform experiment introduced new compiler macros like `$ref()` and `$computed()`.
When using these, the variable becomes reactive:

    import { watchEffect } from 'vue';
    const quantity = $ref(0);
    const total = $computed(() => quantity * 10);
    watchEffect(() => console.log(`New total ${total}`));

And `.value` is no longer necessary with this syntax!

But it turns out that this experiment is not quite as perfect as hoped initially.
It introduces another way to do the same thing, with quite a bit of "magic",
additional pitfalls, and complexity.

So in the end, this experiment is now officially... dropped!

As some teams already started to use it, it will not be removed right away.
The plan is to phase these APIs out in a different package, add deprecation warnings in core,
and eventually remove them in v3.4.

It doesn't mean that the team is not thinking about Vue how can be improved.
Some new ideas will probably be shared publicly soon.

And a part of the reactivity transform experiment is going to stay: the `defineProps` destructuration.
It's _the_ part I really liked, so I'm quite happy about it 🤓.

## defineProps destructuration

`defineProps` is the way to declare your props in the script setup syntax
(see [our article about script setup](/2021/09/30/script-setup-syntax-in-vue-3/)).

The syntax plays well with TypeScript, but the declaration of default values was a bit painful:

    const props = withDefaults(defineProps<{ name?: string }>(), { name: 'Hello '})
    console.log(props.name);

You also can't destructure the props directly, as it loses the reactivity.

With this new release, you can now give default values while destructuring the props and keeping the reactivity!

    const { name = 'Hello' } = defineProps<{ name?: string }>()
    console.log(name);

As this is an experiment,
you'll need to enable `reactivityTransform` in the compiler options to use this feature.

## Typescript in templates

Vue&nbsp;3.3 allows writing TypeScript directly in templates.
It can be handy to hint to [Volar](https://github.com/johnsoncodehk/volar) that a
variable is not null, or of a particular type:

{% raw %}
    <div>
      <h2>Welcome {{ (user!.name as string).toLowerCase() }}</h2>
    </div>
{% endraw %}

## default value for toRef

It is now possible to define a default value when using `toRef()`:

    const order = { quantity: undefined }
    const quantity = toRef(order, 'quantity', 1); // quantity is 1

Note that this works only if the value is `undefined`.

## isShallow

A new utility function called `isShallow` is now available.
It allows checking if a variable is deeply reactive (created with `ref` or `reactive`)
or "shallow" (created with `shallowRef` or `shallowReactive`).

## Component name inference

When using the script setup syntax, the SFC compiler now infers the component name
based on the file name.

So a component declared in a file named `Home.vue` will automatically have the name `Home` since v3.2.34.

## v-for and ref

Vue 3 now behaves like Vue 2 used to behave when using `ref` inside `v-for`:
it populates an array of refs.

{% raw %}
    <script setup>
    import { ref } from 'vue'
    const divs = ref([])
    </script>

    <template>
      <div v-for="i of 3" ref="divs">{{ i }}</div>
      <!-- divs is populated with an array of 3 refs -->
      <!-- one for each HTMLDivElement created -->
      <div>{{ divs }}</div>
    </template>
{% endraw %}

## aliases for vnode hook events

Vue allows you to listen for lifecycle events in templates, both for elements and components.
The syntax in Vue 3 is `@vnodeMounted` for example.
In Vue v3.3, it is now possible to use `@vue:mounted` instead,
which is a bit more understandable (and will probably be the recommended way in the long run).

{% raw %}
    <script setup>
    import { ref } from 'vue'

    const isMounted = ref(false)
    const onDivMounted = () => isMounted.value = true

    const condition = ref(false)
    setTimeout(() => condition.value = true, 3000)
    </script>

    <template>
      <div>isMounted: {{ isMounted }}</div>
      <div @vue:mounted="onDivMounted()" v-if="condition">Hello</div>
    </template>
{% endraw %}

You can try this example in this [online demo](https://sfc.vuejs.org/#eyJBcHAudnVlIjoiPHNjcmlwdCBzZXR1cD5cbmltcG9ydCB7IHJlZiB9IGZyb20gJ3Z1ZSdcblxuY29uc3QgaXNNb3VudGVkID0gcmVmKGZhbHNlKVxuY29uc3Qgb25EaXZNb3VudGVkID0gKCkgPT4gaXNNb3VudGVkLnZhbHVlID0gdHJ1ZSBcblxuY29uc3QgY29uZGl0aW9uID0gcmVmKGZhbHNlKVxuc2V0VGltZW91dCgoKSA9PiBjb25kaXRpb24udmFsdWUgPSB0cnVlLCAzMDAwKVxuPC9zY3JpcHQ+XG5cbjx0ZW1wbGF0ZT5cbiAgPGRpdj5pc01vdW50ZWQ6IHt7IGlzTW91bnRlZCB9fTwvZGl2PlxuICA8ZGl2IEB2dWU6bW91bnRlZD1cIm9uRGl2TW91bnRlZCgpXCIgdi1pZj1cImNvbmRpdGlvblwiPkhlbGxvPC9kaXY+XG48L3RlbXBsYXRlPiIsImltcG9ydC1tYXAuanNvbiI6IntcbiAgXCJpbXBvcnRzXCI6IHtcbiAgICBcInZ1ZVwiOiBcImh0dHBzOi8vdW5wa2cuY29tL0B2dWUvcnVudGltZS1kb21AMy4yLjI2L2Rpc3QvcnVudGltZS1kb20uZXNtLWJyb3dzZXIuanNcIlxuICB9XG59In0=).

To conclude, let's see what happened in the ecosystem recently.

## create-vue

Since Vue v3.2, the Vue team started a new project called [create-vue](https://github.com/vuejs/create-vue),
which is now the recommended way to start a Vue project.
You can use it with

    npm init vue@next

`create-vue` is based on Vite v4,
and officially replaces Vue CLI.

If you missed it, `create-vue` recently added the support of Playwright in addition to Cypress for e2e tests!

## Pinia

[Pinia](https://pinia.vuejs.org/) is a state-management library
from the author of vue-router [Eduardo "@posva"](https://twitter.com/posva).
It was meant as an experiment for Vuex v5,
but it turns out to be very good,
and it's now the official recommendation for state-management library in Vue 3 projects.

The project moved into the vuejs organization, and there will be no Vuex version 5.
Pinia is a really cool project, with a great composition API and TS support,
and one of the cutest logos you've ever seen.

We added a complete chapter in [our ebook](books.ninja-squad.com/vue)
to explain how Pinia works if you're interested 🤓.

Eduardo also recently released [VueFire](https://vuefire.vuejs.org/), the official Firebase bindings for Vue 3.
With this library, you can add Firebase to your Vue or Nuxt projects in a few minutes.

## Nuxt

After a long development, [Nuxt](https://nuxt.com/) v3 is now stable!
It is a really amazing solution and the Nuxt team has been hard at work
to provide a great development experience (with some dark magic under the hood).
Give it a try if you're looking for a meta-framework on top of Vue
(for example if you need SSR or SSG for your project).

## Volar

[Volar](https://github.com/johnsoncodehk/volar) reached v1.0 recently
after a very intense period of development these past months.
The TypeScript support is now better than ever, making it a no-brainer to use in your projects.

## Vue 3 in 2023 

The Vue team plans to release more frequent minor releases than in the past, so we can expect Vue v3.4 soon.
The next releases will be focused on bug fixes and small improvements in the first quarter of the year.
Then there should be some improvements for the SSR support in Q2.
Finally, the second half of the year should see the first alpha of Vapor.
We should hopefully also see Suspense finally getting out of its experimental state.

Vue Vapor is an alternative compilation mode to get better performances.
It's not public yet, but we already know that it is inspired by what [Solidjs](https://www.solidjs.com/) does,
as the reactivity system of Vue and Solid are fairly similar.
The idea is to compile a SFC differently when the "Vapor" mode is enabled,
resulting in a lighter rendering code (not using VDOM).
This "Vapor" mode will probably be opt-in at the component level, probably for "leaf" components first,
but we can imagine enabling it for a whole application in the future.
When enabled for a full application, the VDOM implementation could be completely dropped from the resulting bundle!
We can't wait to try this!

That's all for this release. Stay tuned for the next one!

Our [ebook](https://books.ninja-squad.com/vue), [online training](https://vue-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/vue)) are up-to-date with these changes if you want to learn more!
