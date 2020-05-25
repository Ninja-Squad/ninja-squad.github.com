---
layout: post
title: Getting started with Vue 3
author: cexbrayat
tags: ["Vue"]
description: "Let's start a new application with Vue 3 from scratch."
---

> **Disclaimer**
> This blog post is a chapter of our ebook [Become a ninja with Vue](https://books.ninja-squad.com/vue). Enjoy! But keep in mind that, unlike the ebook, it won't be kept up to date with changes in Vue in the future.

Vue always marketed itself as a progressive framework that,
unlike other alternatives like Angular or React,
you can adopt progressively.
You can take your existing static HTML,
or jQuery application
and easily sprinkle a bit of Vue on top of it.

So first I'd like to demonstrate how easy it is to set up Vue.

Let's make an empty `index.html` file:

    <html lang="en">
      <meta charset="UTF-8" />
      <head>
        <title>Vue - the progressive framework</title>
      </head>
      <body>
      </body>
    </html>


Now let's add some HTML for Vue to handle:

    <html lang="en">
      <meta charset="UTF-8" />
      <head>
        <title>Vue - the progressive framework</title>
      </head>
      <body>
        <div id="app">
          <h1>Hello {{ user }}</h1>
        </div>
      </body>
    </html>

The curly braces around `user` is Vue templating syntax,
indicating that `user` should be replaced by its value.
We'll explain everything in details in the following chapter,
don't worry.

If you load the page in your browser,
you'll see that it displays {% raw %}`Hello {{ user }}`{% endraw %}.
That's normal, as we haven't used Vue yet.

Now let's add Vue.
Vue is released on [NPM](https://www.npmjs.com/package/vue)
and some sites (called CDNs, for Content Delivery Network)
make NPM packages available for inclusion in our HTML pages.
[Unpkg](https://unpkg.com/) is one of them.
We can use it to add Vue to our page.
Of course, you could also choose
to download the file and serve it by yourself.

{% raw %}
    <html lang="en">
      <meta charset="UTF-8" />
      <head>
        <title>Vue - the progressive framework</title>
        <script src="https://unpkg.com/vue@next/dist/vue.global.js"></script>
      </head>
      <body>
        <div id="app">
          <h1>Hello {{ user }}</h1>
        </div>
      </body>
    </html>
{% endraw %}

NOTE: We are using the latest version of Vue in this example.
You can specify any version you want by adding `@version` after `https://unpkg.com/vue`
in the URL.

If you reload the application,
you'll see that Vue emits a warning in the console,
informing us that we are using a development version.
You can use `vue.global.prod.js` to use the production version,
and make it disappear.
The production doesn't do any checks in our code,
is minified, and is bit faster.

We now need to create our application.
Vue offers a `createApp` function to create an application.
To call it, we need a root component.

To create a component,
we simply need to create an object
that defines it.
This object can have various properties,
but for now we'll just add a `setup` function.
Again we'll explain thoroughly later,
but the name is explanatory enough:
this function is here to set up the component,
and Vue is going to call it for us
when the component is initialized.

{% raw %}
    <html lang="en">
      <meta charset="UTF-8" />
      <head>
        <title>Vue - the progressive framework</title>
        <script src="https://unpkg.com/vue@next/dist/vue.global.js"></script>
      </head>
      <body>
        <div id="app">
          <h1>Hello {{ user }}</h1>
        </div>
        <script>
          const RootComponent = {
            setup() {
              return { user: 'Cédric' };
            }
          };
        </script>
      </body>
    </html>
{% endraw %}

The `setup` function just returns an object with a property `user`
and a value for this property.
But if you reload your page, still nothing happens:
we need to call `createApp` with our component.

NOTE: You need a recent enough browser to load this page, as,
as you can see, it uses a "modern" JavaScript syntax.

{% raw %}
    <html lang="en">
      <meta charset="UTF-8" />
      <head>
        <title>Vue - the progressive framework</title>
        <script src="https://unpkg.com/vue@next/dist/vue.global.js"></script>
      </head>
      <body>
        <div id="app">
          <h1>Hello {{ user }}</h1>
        </div>
        <script>
          const RootComponent = {
            setup() {
              return { user: 'Cédric' };
            }
          };
          const app = Vue.createApp(RootComponent);
          app.mount('#app');
        </script>
      </body>
    </html>
{% endraw %}

`createApp` creates an application that needs to be "mounted"
in some place in the DOM: here we use the div with the id `app`.
If you reload the page,
you should now see `Hello Cédric`.
Congratulations, you have your first Vue application.

Maybe we can add another component?
We'll build an other component,
displaying the number of unread messages.

Let's add a new object called `UnreadMessagesComponent`,
with a similar `setup` property:

{% raw %}
    <html lang="en">
      <meta charset="UTF-8" />
      <head>
        <title>Vue - the progressive framework</title>
        <script src="https://unpkg.com/vue@next/dist/vue.global.js"></script>
      </head>
      <body>
        <div id="app">
          <h1>Hello {{ user }}</h1>
        </div>
        <script>
          const UnreadMessagesComponent = {
            setup() {
              return { unreadMessagesCount: 4 };
            }
          };
          const RootComponent = {
            setup() {
              return { user: 'Cédric' };
            }
          };
          const app = Vue.createApp(RootComponent);
          app.mount('#app');
        </script>
      </body>
    </html>
{% endraw %}

Unlike the root component which is using the template inside the `#app` div,
we want to define a template for `UnreadMessagesComponent`.
This can be done by adding a `script` tag
with a special type `text/x-template`.
This type guarantees that the browser won't care about this script.
You can then reference the template by its id inside the component definition:

{% raw %}
    <html lang="en">
      <meta charset="UTF-8" />
      <head>
        <title>Vue - the progressive framework</title>
        <script src="https://unpkg.com/vue@next/dist/vue.global.js"></script>
        <script type="text/x-template" id="unread-messages-template">
          <div>You have {{ unreadMessagesCount }} messages</div>
        </script>
      </head>
      <body>
        <div id="app">
          <h1>Hello {{ user }}</h1>
        </div>
        <script>
          const UnreadMessagesComponent = {
            template: '#unread-messages-template',
            setup() {
              return { unreadMessagesCount: 4 };
            }
          };
          const RootComponent = {
            setup() {
              return { user: 'Cédric' };
            }
          };
          const app = Vue.createApp(RootComponent);
          app.mount('#app');
        </script>
      </body>
    </html>
{% endraw %}

We want to be able to insert the unread
messages component inside our main template.
To do that, we need to tell the root component
it's allowed to use the unread messages component,
and we need to assign it a PascalCase name:

{% raw %}
    <html lang="en">
      <meta charset="UTF-8" />
      <head>
        <title>Vue - the progressive framework</title>
        <script src="https://unpkg.com/vue@next/dist/vue.global.js"></script>
        <script type="text/x-template" id="unread-messages-template">
          <div>You have {{ unreadMessagesCount }} messages</div>
        </script>
      </head>
      <body>
        <div id="app">
          <h1>Hello {{ user }}</h1>
        </div>
        <script>
          const UnreadMessagesComponent = {
            template: '#unread-messages-template',
            setup() {
              return { unreadMessagesCount: 4 };
            }
          };
          const RootComponent = {
            components: {
              UnreadMessages: UnreadMessagesComponent
            },
            setup() {
              return { user: 'Cédric' };
            }
          };
          const app = Vue.createApp(RootComponent);
          app.mount('#app');
        </script>
      </body>
    </html>
{% endraw %}

We can now use the tag `<unread-messages></unread-messages>`
(which is the dash-case version of `UnreadMessages`) to insert the component where we want:

{% raw %}
    <html lang="en">
      <meta charset="UTF-8" />
      <head>
        <title>Vue - the progressive framework</title>
        <script src="https://unpkg.com/vue@next/dist/vue.global.js"></script>
        <script type="text/x-template" id="unread-messages-template">
          <div>You have {{ unreadMessagesCount }} messages</div>
        </script>
      </head>
      <body>
        <div id="app">
          <h1>Hello {{ user }}</h1>
          <unread-messages></unread-messages>
        </div>
        <script>
          const UnreadMessagesComponent = {
            template: '#unread-messages-template',
            setup() {
              return { unreadMessagesCount: 4 };
            }
          };
          const RootComponent = {
            components: {
              UnreadMessages: UnreadMessagesComponent
            },
            setup() {
              return { user: 'Cédric' };
            }
          };
          const app = Vue.createApp(RootComponent);
          app.mount('#app');
        </script>
      </body>
    </html>
{% endraw %}

Comparing to other frameworks,
a Vue application is super easy to start:
just pure JavaScript and HTML,
no tooling, components are simple objects.
Even someone that doesn't know Vue can understand what's going on.
And this is one of the strengths of the framework:
it's easy to start, easy to grasp,
and you can progressively learn the features.

We _could_ stick to this minimal setup for our projects,
but, let's face it, it will not scale for long.
We will soon have too many components to fit in one file,
we would really love to use TypeScript instead of JavaScript,
to add tests, to add some kind of code analysis, etc.

We _could_ set up all the needed tools by hand,
but instead let's leverage the work of the community
and use the excellent Vue CLI.

Come back next week if you want to learn how,
or pay what you want for our complete ebook
[Become a Ninja with Vue](https://books.ninja-squad.com/vue)!