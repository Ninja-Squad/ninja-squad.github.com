---
layout: post
title: What's new in Vue 3.3?
author: cexbrayat
tags: ["Vue 3"]
description: "Vue 3.3 is out!"
---

Vue&nbsp;3.3.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/vuejs/vue-next/blob/master/CHANGELOG.md#TODO">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/vue.png" alt="Vue logo" />
  </a>
</p>

Since the release of v3.2.0 a few months ago,
we have seen quite some patch releases,
some coming with new features.

Let's see what we have!

## Typescript in templates

Vue&nbsp;3.3 allows writing TypeScript directly in templates.
It can be handy to hint to [Volar](https://github.com/johnsoncodehk/volar) that a
variable is not null, or of a particular type:

{% raw %}
    <div>
      <h2>Welcome {{ (user!.name as string).toLowerCase() }}</h2>
    </div>
{% endraw %}

## Reactivity transform

`defineProps` is the new and improved way to declare your props in the script setup syntax
(see [our article about script setup](/2021/09/30/script-setup-syntax-in-vue-3/)).

The syntax plays well with TypeScript, but the declaration of default values was a bit painful:

    const props = withDefaults(defineProps<{ name?: string }>(), { name: 'Hello '})
    console.log(props.name);

You also could not destructure the props directly, as it was loosing the reactivity.
With this new release, you can now give default values and destructure the props!

    const { name = 'Hello' } = defineProps<{ name?: string }>()
    console.log(name);

As this is an experiement,
you'll need to enable `reactivityTransform` in the compiler options to use this feature.
For example, with Vue CLI, add this to your `vue.config.js` file:

    config.module
      .rule('vue')
      .use('vue-loader')
      .tap(options => ({
        ...options,
        reactivityTransform: true
      }));

You can play with this syntax in this [online demo](https://sfc.vuejs.org/#eyJBcHAudnVlIjoiPHNjcmlwdCBzZXR1cCBsYW5nPVwidHNcIj5cbmltcG9ydCBDb21wIGZyb20gJy4vQ29tcC52dWUnXG5sZXQgbmFtZSA9ICRyZWYoKVxuPC9zY3JpcHQ+XG5cbjx0ZW1wbGF0ZT5cblx0PGlucHV0IHYtbW9kZWw9XCJuYW1lXCI+XG4gIDxDb21wIDpuYW1lPVwibmFtZVwiPjwvQ29tcD5cbjwvdGVtcGxhdGU+IiwiaW1wb3J0LW1hcC5qc29uIjoie1xuICBcImltcG9ydHNcIjoge1xuICAgIFwidnVlXCI6IFwiaHR0cHM6Ly9zZmMudnVlanMub3JnL3Z1ZS5ydW50aW1lLmVzbS1icm93c2VyLmpzXCJcbiAgfVxufSIsIkNvbXAudnVlIjoiPHNjcmlwdCBzZXR1cCBsYW5nPVwidHNcIj5cbmNvbnN0IHsgbmFtZSA9ICdIZWxsbycgfSA9IGRlZmluZVByb3BzPHsgbmFtZT86IHN0cmluZyB9PigpXG48L3NjcmlwdD5cblxuPHRlbXBsYXRlPlxuICA8aDE+e3sgbmFtZSB9fTwvaDE+XG48L3RlbXBsYXRlPiJ9)

The Vue team is pursuing its experiments with ref sugar
(see our [previous blog post](/2021/08/10/what-is-new-vue-3.2/) to catch up).

Currently, without ref sugar, you write code like this:

    import { ref, computed, watchEffect } from 'vue';
    const quantity = ref(0);
    const total = computed(() => quantity.value * 10);
    watchEffect(() => console.log(`New total ${total.value}`));

Note the annoying, but necessary, `.value` to access the value of the `quantity` or `total` ref.
If you use the Composition API, you're used to it.

The reactivity transform experiment introduces new compiler macros.

- `$ref()`
- `$computed()`

You don't have to import them, but you can, if you like to make things more explicit.
When using these, the variable becomes reactive, and you don't have to use `.value` anymore:

    import { watchEffect } from 'vue';
    const quantity = $ref(0);
    const total = $computed(() => quantity * 10);
    watchEffect(() => console.log(`New total ${total}`));

`.value` is no longer necessary with this syntax!

`$ref()` and `$computed()` are in fact the same as `$(ref())` and `$(computed())`,
with `$()` a new transform introduced in Vue 3.2.5 that turns ref variables into reactive variables.
Instead of using this new transform,
most commonly used APIs now have a `$` version that does the same thing, like `$ref()`, `$computed()`, `$shallowRef()`, `$toRef()`,
and `$customRef()`.

`$()` is still handy, as it allows to destructure a ref variable.
For example, if you use a third-party library with composition functions like [VueUse](https://vueuse.org/),
you probably have code like:

    import { useGeolocation } from '@vueuse/core'

    const { coords } = useGeolocation()
    console.log(`${coords.value.latitude} - ${coords.value.latitude}`);

`$()` allows to get rid of the `.value`:

    import { useGeolocation } from '@vueuse/core'

    let { coords } = $(useGeolocation())
    console.log(`${coords.latitude} - ${coords.latitude}`);

Another transform does the opposite if necessary: `$$()`.
It's typically the case when you need a ref for `watch`:

    import { watch } from 'vue';
    const quantity = $ref(0);
    const total = $computed(() => quantity * 10);
    // `watch` needs a ref, so this does not work
    watch(total, () => console.log(`New total ${total}`));
    // `$$()` allows to get the ref from the reactive variable
    watch($$(total), () => console.log(`New total ${total}`));

You can try this example in this [online demo](https://sfc.vuejs.org/#eyJBcHAudnVlIjoiPHNjcmlwdCBzZXR1cD5cbmltcG9ydCB7IHdhdGNoIH0gZnJvbSAndnVlJztcbmltcG9ydCB7IHVzZUdlb2xvY2F0aW9uIH0gZnJvbSAnQHZ1ZXVzZS9jb3JlJ1xuXG5sZXQgeyBjb29yZHMgfSA9ICQodXNlR2VvbG9jYXRpb24oKSlcbmNvbnNvbGUubG9nKGAke2Nvb3Jkcy5sYXRpdHVkZX0gLSAke2Nvb3Jkcy5sYXRpdHVkZX1gKTtcbiAgXG5jb25zdCBxdWFudGl0eSA9ICRyZWYoMCk7XG5jb25zdCB0b3RhbCA9ICRjb21wdXRlZCgoKSA9PiBxdWFudGl0eSAqIDEwKTtcbndhdGNoKCQkKHRvdGFsKSwgKCkgPT4gY29uc29sZS5sb2coYE5ldyB0b3RhbCAke3RvdGFsfWApKTtcbjwvc2NyaXB0PlxuXG48dGVtcGxhdGU+XG4gIDxoMT5Ub3RhbDoge3sgdG90YWwgfX08L2gxPlxuICA8aW5wdXQgdi1tb2RlbD1cInF1YW50aXR5XCI+XG4gIDxoMj5cbiAgICBDb29yZHM6IHt7IGNvb3Jkcy5sYXRpdHVkZSB9fSAtIHt7IGNvb3Jkcy5sb25naXR1ZGUgfX1cbiAgPC9oMj5cbjwvdGVtcGxhdGU+IiwiaW1wb3J0LW1hcC5qc29uIjoie1xuICBcImltcG9ydHNcIjoge1xuICAgIFwidnVlXCI6IFwiaHR0cHM6Ly9zZmMudnVlanMub3JnL3Z1ZS5ydW50aW1lLmVzbS1icm93c2VyLmpzXCIsXG4gICAgXCJAdnVldXNlL2NvcmVcIjogXCJodHRwczovL3VucGtnLmNvbS9AdnVldXNlL2NvcmVANi45LjEvaW5kZXgubWpzXCIsXG4gICAgXCJAdnVldXNlL3NoYXJlZFwiOiBcImh0dHBzOi8vdW5wa2cuY29tL0B2dWV1c2Uvc2hhcmVkQDYuOS4xL2luZGV4Lm1qc1wiLFxuICAgIFwidnVlLWRlbWlcIjogXCJodHRwczovL3VucGtnLmNvbS92dWUtZGVtaUAwLjEyLjEvbGliL2luZGV4Lm1qc1wiXG4gIH1cbn0ifQ==).
If you want to use it, you'll need to enable `reactivityTransform` in the compiler options.

To summarize:

- `$()` converts refs into reactive variables
- `$$()` converts reactive variables into refs
- `$ref()` and `$computed()` are the same as `$(ref())` and `$(computed())`
- we can get rid of `.value` 🚀

## default value for toRef

It is now possible to define a default value when using `toRef()`:

    const order = { quantity: undefined }
    const quantity = toRef(order, 'quantity', 1); // quantity is 1

Note that this works only if the value is `undefined`.

## v-for and ref

Vue 3 now behaves like used to behave Vue 2 when using `ref` inside `v-for`:
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

Vue allows to listen for lifecycle events in templates, both for elements and components.
The syntax in Vue 3 is `@vnodeMounted` for example.
In Vue v3.3, it is now possible to use `@vue:mounted` instead,
which is bit more understandable (and will probably be the recommended way in the long run).

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

## create-vue

The Vue team started a new project called [create-vue](https://github.com/vuejs/create-vue),
which will become the recommended way to start a Vue project in the future.
You can give it a try with

    npm init vue@next

create-vue is based on Vite,
and will become the default recommandation instead of Vue CLI.
This is still very early days, so we'll probably talk about it again in the future 😉.

## Pinia

[Pinia](https://pinia.vuejs.org/) is a state-management library
from the author of vue-router [@posva](https://twitter.com/posva).
It was meant as an experiment for Vuex v5,
but it turns out to be very good,
and it's now the official recommandation for state-management library in Vue 3 projects.

The project moved into the vuejs organisation, and there will be no Vuex version 5.
Pinia is a really cool project, with a great composition API and TS support,
and one of the cutest logo you've ever seen.

We added a complete chapter in our ebook to explain how Pinia works if you're interested 🤓.

That's all for this release. Stay tuned for the next one!

Our [ebook](https://books.ninja-squad.com/vue), [online training](https://vue-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/vue)) are up-to-date with these changes if you want to learn more!
