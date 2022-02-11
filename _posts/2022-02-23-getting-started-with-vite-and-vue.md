---
layout: post
title: Getting started with Vite and Vue 3
author: cexbrayat
tags: ["Vue 3", "Vite", "Vitest"]
description: "How to get started with Vite and Vue 3?"
---

> **Disclaimer**
> This blog post is a chapter of our ebook [Become a Ninja with Vue](https://books.ninja-squad.com/vue). Enjoy!

> You can find the french version of this article [here](/2022/02/23/debuter-avec-vite-et-vue)

Comparing to other frameworks,
a Vue application is super easy to start:
just pure JavaScript and HTML,
no tooling, and components are simple objects
(as we shown in a [previous blog post](/2020/05/27/vue-3-getting-started)).

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
and use the Vue CLI (that has been the standard for many years),
or the now recommended tool Vite.

## Vue CLI

> **Note**
> The CLI is now in maintenance mode,
and the recommended tool is Vite, that we present below.
As a lot of existing projects use the CLI,
we still think it's worth introducing,
and it can help to grasp the differences with Vite.

The Vue CLI (Command Line Interface)
was born to help developers build Vue applications.
It can scaffold an application and build it,
and offers a large ecosystem of plugins.
Each plugin offers some kind of features,
like unit testing or linting or TypeScript support.
It also offers a graphical user interface!

One of the cool features of the CLI is the ability
to develop each component in a dedicated file,
with a `.vue` extension.
In this file you can define everything related to this component:
its JavaScript/TypeScript definition, its HTML template,
and even its CSS styles.
This is called a Single File Component, or SFC.

The CLI is overall super handy to avoid having
to learn and configure all the underlying tools
(Node.js, NPM, Webpack, TypeScript, etc...).
It is still very flexible, and
you can configure most behaviors.

But the CLI is now in maintenance mode,
and Vite is the recommended alternative.
Let's talk about the underlying reasons.

## Bundlers: Webpack, Rollup, esbuild

When writing modern JavaScript/TypeScript applications,
you often need a tool that can bundle all the assets (code, styles, images, fonts).

For a long time, [Webpack](https://webpack.js.org/)
was the undisputed favorite.
Webpack comes with a simple but super handy feature:
it understands all the JavaScript module types that exist
(modern ECMAScript modules, but also AMD or CommonJS modules,
formats that were existing before the standard).
This understanding makes it easy to use pretty much
any library you can find on the Internet (most often on NPM):
you just install it, import it in one of your files,
and Webpack takes care of the rest.
Even if you use libraries with completely different formats,
Webpack happily converts them and packages all your code
and the code of the libraries together into one giant JS file:
a bundle.
This is a super important task,
because even if the standard defined ES Modules back in 2015,
most browsers have been supporting them very recently!

The other task of Webpack is to help during development,
by providing a dev server and watching your project
(it can even do HMR, a fancy word that stands for Hot Module Reloading).
When something changes,
Webpack reads the entrypoint of our application (`main.ts` for example),
then it reads its imports and loads these files,
then it reads the imports of the imported files and loads them...
You get the idea!
When everything is loaded,
it re-bundles everything into one large file,
both your code and the imported libraries from your `node_modules`,
changing the module format if needed.
The browser then reloads to display our changes 😅.
This can be time-consuming when working on large projects with hundreds or thousands of files,
even if Webpack comes with caches and heuristics to be as fast as possible.

Vue CLI (like a lot of tools out there) is using Webpack
for most of its work, both when building the application with `npm run build`,
or when running the dev server with `npm run serve`.

This is great as the Webpack ecosystem
is incredibly rich in plugins and loaders:
you can do pretty much what you want with it.
On the other hand, a Webpack configuration
can quickly get a bit overwhelming with all these options.

If I talk about Webpack and what bundlers do,
it's because we have serious alternatives nowadays,
and it can be hard to understand what they do,
and what are their differences.
To be honest, I'm not sure that I understand all the details myself,
and I've contributed quite a lot to Vue and Angular CLIs,
both heavily based on Webpack!
But let me try to explain anyway.

A serious contender is [Rollup](https://www.rollupjs.org/guide/en/).
Rollup intends to keep things simpler than Webpack,
by not doing so much out of the box,
but often doing it faster than Webpack.
Its author is Rich Harris, who is also the author of the Svelte framework.
Rich wrote a famous article called
["Webpack and Rollup: the same but different"](https://medium.com/webpack/webpack-and-rollup-the-same-but-different-a41ad427058c).
His guideline is "Use Webpack for apps, and Rollup for libraries".
In fact, Rollup can do a lot of what Webpack does
for production builds,
but it does not come with a dev server that can watch your files during development.

Another incredible alternative is [esbuild][https://esbuild.github.io/].
Unlike Webpack and Rollup,
esbuild itself is not written in JavaScript.
It is written in Go and compiled to native code.
It has also been designed with parallelism in mind.
That makes it way faster than Webpack and Rollup.
Like 10x-100x faster 🤯.

So why don't we use esbuild instead of Webpack?
That's exactly what Evan You, the author of Vue, thought when developing Vue&nbsp;3.
He had another brilliant idea.
In 2018, Firefox shipped the support of native ECMAScript Modules (often called native ESM).
In 2019, it was NodeJS, and then most browsers followed.
Nowadays, your personal browser can probably understand native ESM without issues.
Evan imagined a tool that would serve files as native ESM to the browser,
doing the heavy lifting with esbuild to transform source files into ESM files if needed
(for example for TypeScript or Vue files or legacy module formats).

[Vite](https://vitejs.dev) (the French word for "fast") was born.

## Vite

The idea behind Vite is that, as modern browsers support ES Modules,
we can now use them directly, at least during development, instead of generating a bundle.

So when you load a page in the browser when developing with Vite,
you don't load a single large file of JS containing all the application:
you load just the few ES modules needed for this page, each in their own file
(and each over their own HTTP request).
If an ES module has imports, then the browser loads these imports as well.

So Vite is mainly a dev server, in charge of answering the browser requests,
and responding with the requested ES modules.
As we may have written our code in TypeScript,
or using SFC in `.vue` extension (see below),
Vite sometimes needs to transform the files on our disk into a proper ES module
that the browser can understand.
This is where esbuild comes into play!
Vite is built on top of esbuild,
and when a requested file needs to be transformed,
it asks esbuild to do the job and then sends the result to the browser.
If you change something in a file,
then Vite only sends the updated module to the browser,
instead of having to rebuild the whole bundle as Webpack-based tools do!

Vite also uses esbuild to optimize a few things.
For example if you use a library with a ton of files,
it "pre-bundles" it into a single file using esbuild
and serves it to the browser in one request instead of a few dozens/hundreds.
This pre-bundling is done once when starting the server,
so you don't pay the cost every time you refresh.

The fun thing is that Vite is not tied to Vue:
it can be used with Svelte, React and others.
In fact some other frameworks now recommend to use Vite!
Svelte, from Rich Harris, was one of the first to do so,
and now officially recommends it.

esbuild is really good for the JS bundling part,
but it is not (yet) capable of splitting the application in several bundles,
or properly handling CSS (whereas Webpack and Rollup do it out of the box).
So it is not suited for bundling the application for production.
That's where Rollup comes into play:
Vite relies on esbuild during development,
but uses Rollup to bundle for production.
Maybe in the future it'll use esbuild for everything.

Vite is more than just an esbuild wrapper.
As we saw, esbuild transforms files really fast.
But Vite does not ask esbuild to transpile the requested files on every reload:
it leverages the browser cache to do as little as possible.
So if you load a page that you already loaded,
it will be displayed in an instant.
Vite also comes with a ton of [other features](https://vitejs.dev/guide/features.html),
and a rich plugin ecosystem.

An important note: esbuild transpiles TypeScript to JavaScript,
but it does not compile it: it completely ignores the type-checking part!
That makes it super fast, but it also means
that you have no typechecking from Vite during development.
To check that your application properly compiles,
you have to run [Volar](https://github.com/johnsoncodehk/volar) (`vue-tsc`),
usually when building the application.

Are you excited? Because I am!
Vite comes with project templates for React, Svelte and Vue,
but the Vue team started a small project on top of Vite called `create-vue`.
And that project is now the official recommendation when you start new Vue&nbsp;3 projects.

## create-vue

create-vue is built on top of Vite,
and provides templates for Vue&nbsp;3 projects.

To get started, you simply use:

    npm init vue@3

The [`npm init something` command](https://docs.npmjs.com/cli/v6/commands/npm-init)
in fact downloads and executes the `create-something` package.
So here `npm init vue` executes the `create-vue` package.

You then have to choose:

- a project name
- if you want TypeScript or not
- if you want JSX or not
- if you want Vue router or not
- if you want Pinia for state management or not
- if you want Vitest for unit testing or not
- if you want Cypress for e2e testing or not
- if you want ESLint/Prettier for linting and formatting or not

and your project is ready!

We will of course deep-dive into all these technologies along our [ebook](https://books.ninja-squad.com/vue).

Want to give it a try?

To build your first Vite app, follow our online exercise
[Getting Started](https://vue-exercises.ninja-squad.com/exercises/0/getting-started)
It's part of our Pro Pack, but is accessible for free.
It'll guide you to create your first application,
and provides a few tweaks on the default configuration that we think are very useful.

Done?

If you followed the instructions (and reached a 100% score I hope!),
you have an application up and running.

As you saw in the exercise,
the created application can run the unit tests, end-to-end tests, linter...
And Vite is super fast,
so the developer experience is really enjoyable 🚀.

Our favorite setup includes:

- TypeScript for the type safety it brings, both in your code and in your templates with vue-tsc
- [Vitest](https://vitest.dev/) for the unit tests. Vitest is really similar to Jest but uses Vite to load the files to test, making it way simpler to use than Jest, as we don't need to configure ts-jest, vue-jest, etc.
- [Cypress](https://www.cypress.io/) for the e2e tests
- [ESLint](https://eslint.org/) with [Prettier](https://prettier.io/) for the code analysis and formatting

With this setup, you're ready to get started with Vue 3!

Our [ebook](https://books.ninja-squad.com/vue), [online training](https://vue-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/vue) are explaining all this in great details if you want to learn more!
