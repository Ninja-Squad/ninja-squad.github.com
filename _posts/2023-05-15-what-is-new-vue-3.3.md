---
layout: post
title: What's new in Vue 3.3?
author: cexbrayat
tags: ["Vue 3"]
description: "Vue 3.3 is out!"
---

Vue&nbsp;3.3.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/vuejs/core/blob/main/CHANGELOG.md#330-rurouni-kenshin-2023-05-11">
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

And `.value` was no longer necessary with this syntax!

But it turns out that this experiment is not quite as perfect as hoped initially.
It introduced another way to do the same thing, with quite a bit of "magic",
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

    const props = withDefaults(defineProps<{ name?: string }>(), { name: 'Hello' })
    console.log(props.name);

You also can't destructure the props directly, as it loses the reactivity.

With this new release, you can now give default values while destructuring the props and keeping the reactivity!

    const { name = 'Hello' } = defineProps<{ name?: string }>()
    console.log(name);

If you try to use a destructured prop directly inside a watcher (or to `toRef`),
Vue will issue a warning and indicate to use a getter function instead:

    watch(name, () => {});
    // "name" is a destructured prop and should not be passed directly to watch().
    // Pass a getter () => name instead.

To help with this pattern, a new `toValue` helper function has been added
to convert refs and getters to values:

    const v1 = toValue(ref('hello')); // 'hello'
    const v2 = toValue(() => 'hello'); // 'hello'

If you want to give it a try, you'll need to enable the `propsDestructure` option
in your bundler config. For example, in Vite:

    plugins: [
      vue({
        script: {
          propsDestructure: true
        }
      })

## TypeScript improvements

The TypeScript support of `defineProps` and other macros has been massively improved,
as pretty much all built-in types are now supported (`Extract`, `Exclude`, `Uppercase`, `Parameters`, etc.).
It also can now refer to types and interfaces imported from other files
(whereas it was only resolving local types previously).

`defineEmits` has also been improved,
as it now supports a shorter TS declaration.
In Vue v3.2, we used to write the type like this:

    const emit = defineEmits<{
      (e: 'selected', value: number): void;
    }>();
    // emit('selected', 14)

There is now a simplified syntax in Vue v3.3.
You can use an interface with the events as keys,
and the arguments as tuples:

    const emit = defineEmits<{
      selected: [value: number]
    }>();


Vue&nbsp;3.3 also allows writing TypeScript directly in templates.
It can be handy to hint to [Volar](https://github.com/johnsoncodehk/volar) that a
variable is not null, or of a particular type:

{% raw %}
    <div>
      <h2>Welcome {{ (user!.name as string).toLowerCase() }}</h2>
    </div>
{% endraw %}

## Generic components

`script setup` components can now have a generic parameter,
which works like a generic `<T>` in TypeScript:

{% raw %}
<script setup lang="ts" generic="T">
defineProps<{ value: T, items: Array<T> }>()
</script>
{% endraw %}

Volar is then capable to throw an error if
`value` is a `string` and `items` an array of numbers for example.

## Component name inference

When using the script setup syntax, the SFC compiler now infers the component name
based on the file name.

So a component declared in a file named `Home.vue` will automatically have the name `Home` since v3.2.34.

## defineOptions macro

A new macro (a compile-time helper like `defineProps` and `defineEmits`) has been introduced
to help declare the options of a component.
This is available only in `script setup` component,
and can be handy to declare a few things like the name of a component,
if the inferred name is not good enough
or to set the `inheritAttrs` option:

    defineOptions({ name: 'Home', inheritAttrs: true });
    

## defineSlots macro

Another macro called `defineSlots` (and a `slots` option if you're using `defineComponent`)
has been added to the framework to help declare typed slots.
When doing so, Volar will be able to check the slot props of a component.
Let's say an `Alert` component has a default slot that exposes a `close` function:

    defineSlots<{
      default: (props: { close: () => void }) => void;
    }>();

If the `Alert` component is not used properly, then Volar throws an error:

    <Alert><template #default="{ closeAlert }">...</template></Alert>
    // error TS2339: Property 'closeAlert' does not exist on type '{ close: () => void; }'.

The returning value of `defineProps` can be used
and is the same object as returned by `useSlots`.

## experimental defineModel macro

When you have a custom form component that just wants to bind the `v-model` value to a classic input, the prop/event mechanic we saw can be a bit cumbersome:

{% raw %}
    <template>
      <input :value="modelValue" @input="setValue($event.target.value)" />
    </template>

    <script setup lang="ts">
    defineProps<{ modelValue: string }>();
    const emit = defineEmits<{ 'update:modelValue': [value: string] }>();
    function setValue(pickedValue) {
      emit('update:modelValue', pickedValue);
    }
    </script>
{% endraw %}

It is now possible to simplify this component,
by using the `defineModel` (experimental) macro:

{% raw %}
    <template>
      <input v-model="modelValue" />
    </template>
    <script setup lang="ts">
      const modelValue = defineModel<string>();
    </script>
{% endraw %}

`defineModel` also accepts a few options:
- `required: true` indicates that the prop is required
- `default: value` lets specify a default value
- `local: true` indicates that the prop is available and mutable even if the parent component did not pass the matching v-model

A `useModel` helper is also available if you don't use `script setup`.

Note that this feature is experimental and opt-in.
For example, in Vite:

    plugins: [
      vue({
        script: {
          defineModel: true
        }
      })


## default value for toRef

It is now possible to define a default value when using `toRef()`:

    const order = { quantity: undefined }
    const quantity = toRef(order, 'quantity', 1); // quantity is 1

Note that this works only if the value is `undefined`.

## isShallow

A new utility function called `isShallow` is now available.
It allows checking if a variable is deeply reactive (created with `ref` or `reactive`)
or "shallow" (created with `shallowRef` or `shallowReactive`).

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
which is a bit more understandable.
`@vnode` hooks are now deprecated.

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

You can try this example in this [online demo](https://play.vuejs.org/#eyJBcHAudnVlIjoiPHNjcmlwdCBzZXR1cD5cbmltcG9ydCB7IHJlZiB9IGZyb20gJ3Z1ZSdcblxuY29uc3QgaXNNb3VudGVkID0gcmVmKGZhbHNlKVxuY29uc3Qgb25EaXZNb3VudGVkID0gKCkgPT4gaXNNb3VudGVkLnZhbHVlID0gdHJ1ZSBcblxuY29uc3QgY29uZGl0aW9uID0gcmVmKGZhbHNlKVxuc2V0VGltZW91dCgoKSA9PiBjb25kaXRpb24udmFsdWUgPSB0cnVlLCAzMDAwKVxuPC9zY3JpcHQ+XG5cbjx0ZW1wbGF0ZT5cbiAgPGRpdj5pc01vdW50ZWQ6IHt7IGlzTW91bnRlZCB9fTwvZGl2PlxuICA8ZGl2IEB2dWU6bW91bnRlZD1cIm9uRGl2TW91bnRlZCgpXCIgdi1pZj1cImNvbmRpdGlvblwiPkhlbGxvPC9kaXY+XG48L3RlbXBsYXRlPiIsImltcG9ydC1tYXAuanNvbiI6IntcbiAgXCJpbXBvcnRzXCI6IHtcbiAgICBcInZ1ZVwiOiBcImh0dHBzOi8vdW5wa2cuY29tL0B2dWUvcnVudGltZS1kb21AMy4yLjI2L2Rpc3QvcnVudGltZS1kb20uZXNtLWJyb3dzZXIuanNcIlxuICB9XG59In0=).

## suspensible Suspense

`Suspense` is still experimental but gained a new prop called `suspensible`.

The prop allows the suspense to be captured by the parent suspense.
That can be useful if you have nested `Suspense` components,
as you can see in the [PR explanation](https://github.com/vuejs/core/pull/6736).

## console available in templates

A small (but useful when debugging) improvement in templates is the possibility
to directly use `console`:

{% raw %}
    <input @input="console.log($event.target.value)">
{% endraw %}

To conclude, let's see what happened in the ecosystem recently.

## create-vue

Since Vue v3.2, the Vue team started a new project called [create-vue](https://github.com/vuejs/create-vue),
which is now the recommended way to start a Vue project.
You can use it with

    npm init vue@next

`create-vue` is based on Vite v4,
and officially replaces Vue CLI.

If you missed it, `create-vue` recently added the support of Playwright in addition to Cypress for e2e tests!
It now also supports TypeScript v5 out of the box.

## Router

Vue v3.3 introduced a new function on the object returned by `createApp`:
`runWithContext`.
The function allows using `inject` with the app as the active instance,
and get the value provided by the app providers.

    const app = createApp(/* ... */);
    app.provide('token', 1);
    app.runWithContext(() => inject('token'));

If I mention this in the router section,
it's because it unlocks the possibility to use `inject` in global navigation guards
if you use Vue v3.3 and the router v4.2!

    router.beforeEach((to, from) => {
      console.log(inject('token'));
    });

## Pinia

[Pinia](https://pinia.vuejs.org/) is a state-management library
from the author of vue-router [Eduardo "@posva"](https://twitter.com/posva).
It was meant as an experiment for Vuex v5,
but it turns out to be very good,
and it's now the official recommendation for state-management library in Vue 3 projects.

The project moved into the vuejs organization, and there will be no Vuex version 5.
Pinia is a really cool project, with a great composition API and TS support,
and one of the cutest logos you've ever seen.

We added a complete chapter in [our ebook](https://books.ninja-squad.com/vue)
to explain how Pinia works if you're interested 🤓.

Eduardo also released [VueFire](https://vuefire.vuejs.org/),
the official Firebase bindings for Vue 3.
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
The TypeScript support is now better than ever,
making it a no-brainer to use in your projects.

## Vue Test utils

The testing library has a few typings improvements coming in the v2.4 release,
and now supports SSR testing via `renderToString` since v2.3.

## Vue 3 in 2023 

The Vue team plans to release more frequent minor releases than in the past, so we can expect Vue v3.4 soon.
The next releases will be focused on bug fixes and small improvements in the first quarter of the year.
Then there should be some improvements for the SSR support in Q2.
Finally, the second half of the year should see the first alpha of Vapor.
We should hopefully also see Suspense finally getting out of its experimental state.

Vue Vapor is an alternative compilation mode to get better performances.
It's not public yet, but we already know that it is inspired by what [Solidjs](https://www.solidjs.com/) does,
as the reactivity system of Vue and Solid are fairly similar.
The idea is to compile a `script setup` component differently when the "Vapor" mode is enabled,
resulting in a lighter rendering code (not using VDOM).

Let's say we have a classic Counter component:

{% raw %}
    <script setup lang="ts">
      let count = ref(0)
    </script>
    <template>
      <div>
        <button @click="count++">{{ count }}</button>
      </div>
    </template>
{% endraw %}

In the current Vue 3 compilation mode,
the template is compiled into a function that produces VDOM
which is then diffed and rendered
(check out the "Under the hood" chapter of our ebook if you want to learn more).
In Vapor mode, the template is compiled into a function that only updates what's necessary in the DOM.

    import { ref, effect } from 'vue';
    import { setText, template, on } from 'vue/vapor';

    let t0 = template('<div><button>');

    export default () => {
      const count = ref(0); 
      let div = t0();
      let button = div.firstChild;
      let button_text;
      effect(() => {
        // This is the only part that is executed at runtime when the counter value changes
        setText(button, button_text, count.value);
      });
      on(button, 'click', () => count.value++);
      return div;
    }

This "Vapor" mode will be opt-in at the component level, probably for "leaf" components first.
To switch a component to Vapor, the current idea is to import it with a `.vapor.vue` extension:

{% raw %}
    <script setup lang="ts">
      // 👇 compiles the User component in Vapor mode
      // you get an error if the component is not "Vapor" compatible
      import User from './User.vapor.vue'
    </script>
    <template>
      <User />
    </template>
{% endraw %}

We'll be able to enable it for a whole application in the future.
The current idea is to call a different `createApp` function from `vue/vapor`:

    import { createApp } from 'vue/vapor'
    import App from './App.vapor.vue'
    createApp(App).mount('#app')

When enabled for a full application, the VDOM implementation could be completely dropped from the resulting bundle!
We can't wait to try this!

That's all for this release. Stay tuned for the next one!

Our [ebook](https://books.ninja-squad.com/vue), [online training](https://vue-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/vue) are up-to-date with these changes if you want to learn more!
