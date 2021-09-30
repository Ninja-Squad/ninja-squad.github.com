---
layout: post
title: How to use the `script setup` syntax in Vue 3
author: cexbrayat
tags: ["Vue 3"]
description: "Vue 3.2 introduced the `script setup` syntax in its final version. Let's see how t use it!"
---

Vue&nbsp;3.2 introduced the `script setup` syntax,
a slightly less verbose way to declare a component.
You enable it by adding a `setup` attribute to the `script` element of your SFC,
and you can then remove a bit of boilerplate in your component.

Let's take a practical example, and migrate it to this syntax!

## Migrate a component

The following `Pony` component has two props (the `ponyModel` to display, and a `isRunning` flag).
Based on these two props, a URL is computed for the image of the pony displayed in the template
(via another `Image` component).
The component also emits a `selected` event when the user clicks on it.

Pony.vue
{% raw %}
    <template>
      <figure @click="clicked()">
        <Image :src="ponyImageUrl" :alt="ponyModel.name" />
        <figcaption>{{ ponyModel.name }}</figcaption>
      </figure>
    </template>
    <script lang="ts">
    import { computed, defineComponent, PropType } from 'vue';
    import Image from './Image.vue';
    import { PonyModel } from '@/models/PonyModel';

    export default defineComponent({
      components: { Image },

      props: {
        ponyModel: {
          type: Object as PropType<PonyModel>,
          required: true
        },
        isRunning: {
          type: Boolean,
          default: false
        }
      },

      emits: {
        selected: () => true
      },

      setup(props, { emit }) {
        const ponyImageUrl = computed(() => `/pony-${props.ponyModel.color}${props.isRunning ? '-running' : ''}.gif`);

        function clicked() {
          emit('selected');
        }

        return { ponyImageUrl, clicked };
      }
    });
    </script>
{% endraw %}

As a first step, add the `setup` attribute to the `script` element.
Then, we just need to keep the content of the `setup` function:
all the boilerplate can go away.
You can remove the `defineComponent` and `setup` functions inside `script`:

Pony.vue
{% raw %}
    <script setup lang="ts">
    import { computed, PropType } from 'vue';
    import Image from './Image.vue';
    import { PonyModel } from '@/models/PonyModel';

    components: { Image },

    props: {
      ponyModel: {
        type: Object as PropType<PonyModel>,
        required: true
      },
      isRunning: {
        type: Boolean,
        default: false
      }
    },

    emits: {
      selected: () => true
    },

    const ponyImageUrl = computed(() => `/pony-${props.ponyModel.color}${props.isRunning ? '-running' : ''}.gif`);

    function clicked() {
      emit('selected');
    }

    return { ponyImageUrl, clicked };
    </script>
{% endraw %}

## Implicit return

We can also remove the `return` at the end:
all the top-level bindings declared inside a `script setup` (and all imports)
are automatically available in the template.
So here `ponyImageUrl` and `clicked` are available without needing to return them.

This is the same for the `components` declaration!
Importing the `Image` component is enough,
and Vue understands that it is used in the template:
we can remove the `components` declaration.

Pony.vue
{% raw %}
    <script setup lang="ts">
    import { computed, PropType } from 'vue';
    import Image from './Image.vue';
    import { PonyModel } from '@/models/PonyModel';

    props: {
      ponyModel: {
        type: Object as PropType<PonyModel>,
        required: true
      },
      isRunning: {
        type: Boolean,
        default: false
      }
    },

    emits: {
      selected: () => true
    },

    const ponyImageUrl = computed(() => `/pony-${props.ponyModel.color}${props.isRunning ? '-running' : ''}.gif`);

    function clicked() {
      emit('selected');
    }
    </script>
{% endraw %}

---

We're nearly there: we now need to migrate the `props` and `emits` declarations.

## defineProps

Vue offers a `defineProps` helper that you can use to define your props.
It's a compile-time helper (a macro), so you don't need to import it in your code:
Vue automatically understands it when it compiles the component.

`defineProps` returns the props:

    const props = defineProps({
      ponyModel: {
        type: Object as PropType<PonyModel>,
        required: true
      },
      isRunning: {
        type: Boolean,
        default: false
      }
    });

`defineProps` receives the former `props` declaration as a parameter.
But we can do even better for TypeScript users!

`defineProps` is generically typed:
you can call it without a parameter,
but specify an interface as the "shape" of the props.
No more horrible `Object as PropType<Something>` to write!
We can use proper TypeScript types,
and add `?` to mark a prop as not required 😍.

    const props = defineProps<{
      ponyModel: PonyModel;
      isRunning?: boolean;
    }>();

We lost a bit of information though.
In the previous version, we could specify that `isRunning` had a default value of `false`.
To have the same behavior, we can use the `withDefaults` helper:

    interface Props {
      ponyModel: PonyModel;
      isRunning?: boolean;
    }

    const props = withDefaults(defineProps<Props>(), { isRunning: false });

The last remaining syntax to migrate is the `emits` declaration.

## defineEmits

Vue offers a `defineEmits` helper, very similar to the `defineProps` helper.
`defineEmits` returns the `emit` function:

    const emit = defineEmits({
      selected: () => true
    });

Or even better, with TypeScript:

    const emit = defineEmits<{
      (e: 'selected'): void;
    }>();

The full component declaration is 10 lines shorter.
Not a bad reduction for a ~30 lines component!
It's easier to read, and plays better with TypeScript.
It does feel a bit weird to have everything automatically exposed to the template,
without writing return though, but you get used to it.

Pony.vue
{% raw %}
    <template>
      <figure @click="clicked()">
        <Image :src="ponyImageUrl" :alt="ponyModel.name" />
        <figcaption>{{ ponyModel.name }}</figcaption>
      </figure>
    </template>

    <script setup lang="ts">
    import { computed } from 'vue';
    import Image from './Image.vue';
    import { PonyModel } from '@/models/PonyModel';

    interface Props {
      ponyModel: PonyModel;
      isRunning?: boolean;
    }

    const props = withDefaults(defineProps<Props>(), { isRunning: false });

    const emit = defineEmits<{
      (e: 'selected'): void;
    }>();

    const ponyImageUrl = computed(() => `/pony-${props.ponyModel.color}${props.isRunning ? '-running' : ''}.gif`);

    function clicked() {
      emit('selected');
    }
    </script>
{% endraw %}

## Closed by default and defineExpose

There is a more subtle difference between the two ways to declare components:
a `script setup` component is "closed by default".
This means other components don't see what's defined inside the component.

For example, the `Pony` component can access the `Image` component
(by using refs, as we'll see in a following chapter).
If `Image` is defined with `defineComponent`,
then everything returned by the `setup` function is also visible for the parent component (`Pony`).
If `Image` is defined with `script setup`,
then _nothing_ is visible for the parent component.
`Image` can pick what is exposed by adding a `defineExpose({ key: value })` helper.
Then the exposed `value` will be accessible as `key`.

This syntax is now the recommended way to declare your components,
and it's awesome to use!

Our [ebook](https://books.ninja-squad.com/vue), [online training](https://vue-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/vue) are up-to-date with these changes if you want to learn more!
