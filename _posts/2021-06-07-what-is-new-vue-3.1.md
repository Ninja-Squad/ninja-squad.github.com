---
layout: post
title: What's new in Vue 3.1?
author: cexbrayat
tags: ["Vue 3"]
description: "Vue 3.1 is out!"
---

Vue&nbsp;3.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/vuejs/vue-next/blob/master/CHANGELOG.md#310-2021-06-07">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/vue.png" alt="Vue logo" />
  </a>
</p>

It has already been 8 months since v3.0.0,
and here is the first minor version.
In the meantime, 11 patch releases landed mainly with bug fixes and performance improvements,
but also with some features and changes.

Let's catch up with everything that happened since v3.0.0!


## Migrate your Vue 2 app with @vue/compat

The main feature of this v3.1 release is the "migration build".
It allows to build and run a Vue 2 application with Vue 3 in a "compatibility" mode.
This is an impressive engineering feat,
as Vue 3 is a complete rewrite of Vue 2.
It has some limitations, and all libraries won't work (especially if they use internal APIs),
but it can help developers migrating their applications progressively.

To give it a try,
you can remplace your Vue 2 dependency by Vue 3.1,
and replace `vue-template-compiler` by `@vue/compiler-sfc`.
Then you'll need to add `@vue/compat`,
the new package in charge of the compatibility, introduced in v3.1.
You'll also need to start the application in compatibility mode,
by updating your Vue CLI, Vite or Webpack config.
In Vue CLI for example, you need to add in `vue.config.js`:

    module.exports = {
      chainWebpack: config => {
        config.resolve.alias.set('vue', '@vue/compat')

        config.module
          .rule('vue')
          .use('vue-loader')
          .tap(options => {
            return {
              ...options,
              compilerOptions: {
                compatConfig: {
                  MODE: 2
                }
              }
            }
          })
        }
    }

This will resolve the `vue` imports to the new `@vue/compat` package,
which know which Vue 3 API is the equivalent of the Vue 2 API you use.
You can then start the application!

When running the Vue 2 application with Vue 3,
you'll see warnings explaining what you'll need to change to use the Vue 3 modern APIs
instead of the deprecated Vue 2 ones.

For exemple, the components defined with `Vue.extend` trigger the warning:

    [Vue warn]: (deprecation GLOBAL_EXTEND) Vue.extend() has been removed in Vue 3. Use defineComponent() instead.
      Details: https://v3.vuejs.org/api/global-api.html#definecomponent

You can then resolve the warnings one by one,
or you can also temporarily silence them using `configureCompat`:

    Vue.configureCompat({
      GLOBAL_EXTEND: 'suppress-warning'
    })

You can check out more details in the README of the package:
[vue-compat](https://github.com/vuejs/vue-next/tree/master/packages/vue-compat)

The initial plan for Vue 3.1 was to include other features,
but in the end, it was decided to cut a release to let developers experiment with this migration build.
This is really interesting if you have Vue 2 applications that you want to migrate 🚀.


## IE 11 will not be supported in Vue 3

The original plan was to introduce support for IE11 in Vue 3.1.
But, after some considerations and a discussion with the community in the [rfcs](https://github.com/vuejs/rfcs/discussions/296) repository,
the team decided not to support it.
IE11 has a very small global usage,
and a lot of the popular frameworks, libraries,
and tools have stopped supporting it as well.
Supporting IE11 in Vue 3 would have requested a lot of work
(as IE11 does not support Proxies that Vue 3 uses for its reactivity system).

The plan is now to introduce Vue 3 features in the upcoming Vue v2.7,
allowing developers that need IE11 support to stay on Vue 2 and enjoy some of the features of Vue 3.


## SFC online playground

Evan built a very nice online playground for Single File Components:
[sfc.vuejs.org](https://sfc.vuejs.org/).
This is very handy to quickly check something,
or reproduce an issue!


## Experimental setup

Vue 3 has several ways to declare a component.
You can use the Options API (which is the API used in Vue 2),
but the new and recommended way is to use the Composition API.

    <script>
      import { defineComponent, ref } from 'vue';
      export default defineComponent({
        name: 'NavBar',

        setup() {
          const navbarCollapsed = ref(true);
          function toggleNavbar() {
            navbarCollapsed.value = !navbarCollapsed.value;
          }

          return { navbarCollapsed, toggleNavbar };
        }
      });
    </script>

A feature of Vue 3.1 lets you write the same component
with the "Experimental setup" syntax:

    <script setup>
      import { ref } from 'vue';
      const navbarCollapsed = ref(true);
      function toggleNavbar() {
        navbarCollapsed.value = !navbarCollapsed.value;
      }
    </script>

As you can see, adding the `setup` attribute to the `script` element
allows to directly declare what you need in the template
and remove the boilerplate.

You can check out the [RFC](https://github.com/vuejs/rfcs/pull/227) to learn more.
The SFC playground supports this syntax,
so you can [try this example directly in your browser](https://sfc.vuejs.org/#eyJBcHAudnVlIjoiPHRlbXBsYXRlPlxuICA8aDEgQGNsaWNrPVwidG9nZ2xlTmF2YmFyKClcIj57eyBuYXZiYXJDb2xsYXBzZWQgfX08L2gxPlxuPC90ZW1wbGF0ZT5cblxuPHNjcmlwdCBzZXR1cD5cbiAgaW1wb3J0IHsgcmVmIH0gZnJvbSAndnVlJ1xuICBjb25zdCBuYXZiYXJDb2xsYXBzZWQgPSByZWYodHJ1ZSk7XG4gIGZ1bmN0aW9uIHRvZ2dsZU5hdmJhcigpIHtcbiAgICBuYXZiYXJDb2xsYXBzZWQudmFsdWUgPSAhbmF2YmFyQ29sbGFwc2VkLnZhbHVlO1xuICB9XG48L3NjcmlwdD4ifQ==).

A syntax sugar can be used for `ref` as well.
This is documented in another [RFC](https://github.com/vuejs/rfcs/pull/228)

    <script setup>
      ref: navbarCollapsed = true;
      function toggleNavbar() {
        navbarCollapsed = !navbarCollapsed;
      }
    </script>

Check out the [online demo](https://sfc.vuejs.org/#eyJBcHAudnVlIjoiPHRlbXBsYXRlPlxuICA8aDEgQGNsaWNrPVwidG9nZ2xlTmF2YmFyKClcIj57eyBuYXZiYXJDb2xsYXBzZWQgfX08L2gxPlxuPC90ZW1wbGF0ZT5cblxuPHNjcmlwdCBzZXR1cD5cbnJlZjogbmF2YmFyQ29sbGFwc2VkID0gdHJ1ZTtcbmZ1bmN0aW9uIHRvZ2dsZU5hdmJhcigpIHtcbiBuYXZiYXJDb2xsYXBzZWQgPSAhbmF2YmFyQ29sbGFwc2VkO1xufVxuPC9zY3JpcHQ+In0=).

As this is still very fresh (and has a few remaining issues),
we prefer to stick to the Composition API with a `setup` function for now,
but this is exciting for the future.


## CSS variable injection

Another [RFC](https://github.com/vuejs/rfcs/pull/231) has been implemented
and is available as an experimental feature: CSS variable injection.
This allows to directly use the component state inside the style of the component with `v-bind()`:

    <script setup>
      import { computed, ref } from 'vue'
      const size = ref(12);
      const fontSize = computed(() => `${size.value}px`);
    </script>

    <style>
      h1 {
        font-size: v-bind('fontSize')
      }
    </style>

Check out [the online demo](https://sfc.vuejs.org/#eyJBcHAudnVlIjoiPHRlbXBsYXRlPlxuICA8aDE+SGVsbG88L2gxPlxuICA8bGFiZWwgZm9yPVwic2l6ZVwiPlNpemUgPC9sYWJlbD5cbiAgPGlucHV0IGlkPVwic2l6ZVwiIHYtbW9kZWw9XCJzaXplXCIgdHlwZT1cIm51bWJlclwiPlxuPC90ZW1wbGF0ZT5cblxuPHNjcmlwdCBzZXR1cD5cbiAgaW1wb3J0IHsgY29tcHV0ZWQsIHJlZiB9IGZyb20gJ3Z1ZSdcbiAgY29uc3Qgc2l6ZSA9IHJlZigxMik7XG4gIGNvbnN0IGZvbnRTaXplID0gY29tcHV0ZWQoKCkgPT4gYCR7c2l6ZS52YWx1ZX1weGApO1xuPC9zY3JpcHQ+XG5cbjxzdHlsZT5cbiAgaDEge1xuICAgIGZvbnQtc2l6ZTogdi1iaW5kKCdmb250U2l6ZScpXG4gIH1cbjwvc3R5bGU+In0=)
and see how the title font size changes automatically.


## onServerPrefetch

For those of you working with server-side rendering,
a new `onServerPrefetch` lifecycle function is now available.
It is the Composition API equivalent of `serverPrefetch` that was introduced in Vue 2.6.
This indicates the server renderer to pause the rendering until the promise it returns is resolved.
Super handy when you want to fetch asynchronous data during the server-side rendering process!
Note that you can call it several times in the same setup,
and they will called in parallel.

    <script>
      import { defineComponent, onServerPrefetch, ref } from 'vue';
      import { getActiveUsers } from './users';
      export default defineComponent({
        name: 'Home',

        setup() {
          const activeUsers = ref(0);
          onServerPrefetch(async () => {
            activeUsers.value = await getActiveUsers()
          })
          return { activeUsers };
        }
      });
    </script>

## BigInt

It is now possible to use [`BigInt`](https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Global_Objects/BigInt)
as a prop type and in the templates directly:

{% raw %}
    <template>
      <h1>{{ size + BigInt(13) }}</h1>
    </template>
    <script>
      import { defineComponent } from 'vue';
      export default defineComponent({
        props: {
          size: BigInt
        }
      })
    </script>
{% endraw %}


## Ecosystem updates

The ecosystem is catching up with Vue 3,
and most libraries now offer a compatible version.

The [router](https://github.com/vuejs/vue-router-next) v4 has been stable for a few months,
and offers a nice Composition API.

The [Devtools](https://github.com/vuejs/vue-devtools) are still in beta for Vue 3,
but have some really nice features.
They offer a plugins system (handy for the router, vue-i18n, or vuex),
a timeline of events with screenshots,
suspense and provide/inject support, etc.
They now support Vue 2 as well.
Vue 3.1 also exposes performance metrics that the devtools can display!
It is now super easy to spot if a component takes too much time to render.

<p style="text-align: center;">
  <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/devtools.png" alt="Vue Devtools" />
</p>

[Vue CLI](https://github.com/vuejs/vue-cli) v4 already supports Vue 3 and version 5 should be out of beta soon with Webpack 5 support
(come back here when it will be out, as we already have a draft blog post about that).

[Volar](https://github.com/johnsoncodehk/volar), a VS Code extension and a command line tool to check your templates,
is making very good progress. We are now using it in some of our projects with great success,
and we can now enjoy template type-checking at compile time.

[Vue Test Utils](https://github.com/vuejs/vue-test-utils-next) is still in RC,
but should be stable fairly soon.


## TypeScript support

Vue 3 now supports (and requires) TypeScript v4+
(if you use TypeScript of course, but ain't that the best way to build a Vue app nowadays? 🤗).
It is also now possible to declare your global components,
to help tools understand your templates.
This is still very early days, but you can now write:

    import { RouterView } from 'vue-router'
    declare module '@vue/runtime-core' {
      interface GlobalComponents {
        RouterView
      }
    }

This lets third-party tools like Volar know that `RouterView` is available in your application 😍.

 The next release will be v3.2 and should be out in a few weeks or months with new features (initially planned for v3.1).
 Stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/vue), [online training](https://vue-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/vue)) are up-to-date with these changes if you want to learn more!