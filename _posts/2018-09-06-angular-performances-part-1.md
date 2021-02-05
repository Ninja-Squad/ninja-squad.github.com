---
layout: post
title: Angular Performances Part 1 - First load
author: cexbrayat
tags: ["Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4", "Angular CLI", "performances", "benchmarks"]
description: "Learn how to make your Angular application faster. In this first part, let's talk about the first load of an application."
---

We have just finished a new chapter of our [ebook](https://books.ninja-squad.com/angular) about performances,
and we thought we could share it with you in a series of blog posts.
It took us a long time, but we wanted to write something more complete than what you can usually find.
There are a lot of tips to make Angular faster (whatever faster means for you, we'll come back to this in a minute),
but you usually don't have the other side of the story: what are the traps of these optimizations,
are they what you are looking for,
and should you really use them.

This is the first part of this series, and this blog post is about the first load of an Angular application.
In future posts, we'll talk about how to make [reloading faster](/2018/09/13/angular-performances-part-2/), then about how to [profile your running application](/2018/09/20/angular-performances-part-3/),
and how to improve runtime performances.
If you are the lucky owner of our ebook, you can already check the other parts if you download the [last ebook release](https://books.ninja-squad.com/claim?book=Angular).

Warning: be careful with premature optimization. Always measure before and after. Beware of the benchmarks you find on the internets: it’s pretty easy to make them say what the authors want.

Let's start!

## Performances

Performances can mean a lot of things: speed, CPU usage (battery consumption), memory pressure…​ Everything is not important for everybody: you have different needs if you are programming for a mobile website, an e-commerce platform, or a classic CRUD application.

Performances can also be split in different categories, that, once more, won’t all matter to you: first load, reload, and runtime performances.

First load is when you open an application for the first time. Reload is when you come back to that application. Runtime performances is what happens when the application is running. Some of the following advices are very generic, and could be applied to any framework. We wrote them because we think it’s worth knowing. And because when you talk about performances, the framework is sometimes the bottleneck, but really (really) often not.

## First load

When you load a modern Web application in your browser, a few things happen. First, the `index.html` is loaded and parsed by the browser. Then the JS scripts and other assets referenced are fetched. When one of the assets is received, the browser parses it, and executes it if it is a JS file.

### Assets sizes

So the first tip is very obvious: be careful with your assets sizes!

The assets loading phase depends on how many assets you want to load. A lot will be slow. Big ones will be slow. Especially if the network is not that good, which happens more often than you think: you might test your application on a fiber optic connection, but some of your actual users might be in the middle of nowhere, using slow 3G. Here is what you can do.

### Bundle your application

When you write your Angular application, you have imports all over the place, and your code is split across hundreds of files. But you don’t want your users to load hundred of files! So before shipping your application, you want to make a "bundle": group all the JavaScript files into one file.

[Webpack's](https://webpack.js.org/) job is to take all your JavaScript files (and CSS, and template HTML files) and build bundles. It’s not an easy tool to master, but the Angular CLI does a pretty good job at hiding its complexity. If you don’t use the CLI, you can build your application with Webpack, or you can pick another tool that may produce even better results (like [Rollup](https://rollupjs.org/guide/en) for example). But be warned that this requires quite a lot of expertise (and work) to not mess things up, just to save a few extra kilobytes. I would recommend staying with the CLI. The team working on it is doing a very good job to keep up with the latest Angular, TypeScript and Webpack releases.

More than that, they built some tools to decrease the bundling size. For example, they wrote a plugin that goes through the generated JavaScript, and adds specific comments to help [UglifyJS](http://lisperator.net/uglifyjs/) remove dead code.

### Tree-shaking

Webpack (or the other tool you use) starts from the entry point of your application (the main.ts file that the CLI generated for you, and that you probably never touched), and then resolves all the imports tree, and outputs the bundle. This is cool because the bundle will only contains the files from your codebase and your third party libraries that have been imported. The rest is not embedded. So even if you have a dependency in your package.json that you don’t use anymore (so you don’t import it anymore), it will not end up in the bundle.

It’s even a bit smarter than that. If you have a file `models` exporting two classes, let’s say `PonyModel` and `RaceModel`, and then only import `PonyModel` in the rest of the application, but never `RaceModel`, then Webpack only puts `PonyModel` in the final bundle, and drops `RaceModel`. This process is called *tree-shaking*. And every framework and library in the JavaScript ecosystem is fighting hard to be tree-shakable! In theory, it means that your final bundle contains only what is really needed! But in practice, Webpack (and others) are a bit conservative, and can’t figure some stuff. For example, if you have a class `Pony` with two methods `eat` and `run`, but you only use `run`, the code of the `eat` method will be in the final bundle. So it’s not perfect, but it does a good job.

A few techniques can be used in Angular specifically to have a better tree-shaking. First, don’t import modules that you don’t use. Sometimes you give a try to a library offering a wonderful component, and you add the NgModule of this library to the imports of your NgModule. Then you don’t use it anymore, but maybe forget about the module import, and don’t remove it…​ Bad news: this module and the third party library will be in the final bundle (for now, maybe it will be better in the future). So only import and use what you really need.

Another trick is to use `providedIn` for your services. If you declare a service in the providers of your NgModule, it will always end up in the bundle whether you actually use it or not, simply because it’s imported and referenced in the module. Whereas if you don’t register in the providers of your NgModule, but use `providedIn: 'root'` instead, then if you never use this service, it will not end up in the bundle.

### Minification and dead code elimination

When your bundle has been built, the code is usually minified and dead code will be eliminated. That means all variables, methods names, class names…​ are renamed to use a one or two characters name through the entire codebase. This is a bit scary and sounds like it could break things, but UglifyJS has been doing a great job for years now. UglifyJS will also eliminate dead code that it can find. It does its best, and I was saying above, the CLI team built a tool that prepares the code with special comments on unneeded code, so UglifyJS can remove it safely.

### Other assets

While the above sections were about JS specifically, your application also contains other assets, like styles, images, fonts…​ You should have the same concerns about them, and do your best to keep them at a reasonable size. Applying all kind of crazy techniques to optimize your JS bundle sizes, but loading several MBs of images wouldn’t have a big impact on your page loading time and your bandwidth! As this is not really the scope of this post, I won’t dig into this topic, but let me point out a great online resource by Addy Osmani about image optimization: [Essential Image Optimization](https://images.guide).

### Compression

All the modern browsers accept a compressed version of an asset when they ask the server for it. That means you can serve a compressed version to your users, and the browser will unzip it before parsing it. This is a must do because it will save you tons of bandwidth and loading time!

Every server on the market has an option to activate the compression of assets. Generally the first user to request an asset will pay the cost of the compression on the fly, and then the following ones will receive the compressed asset directly.

The most common compression algorithm used is GZIP, but some others like [Brotli](https://github.com/google/brotli) are also popular.

### Lazy-loading

Sometimes, despite doing your best to keep your JS bundle small, you end up with a big file because your app has grown to several dozens of components, using various third party libraries. And not only this big bundle will increase the time needed to fetch the JavaScript, it will also increase the time needed to parse it and execute it.

One common solution to this problem is to use lazy-loading. It means that instead of having a big bundle of JavaScript, you split your application in several parts and tell Webpack to bundle it in several bundles.

The good news is Angular (its router, and its module system, in particular) makes this task relatively easy to achieve. The other good news is that the CLI knows how to read your router configuration to build several bundles automatically. You can read our chapter about the router if you want to learn more.

Lazy-loading can vastly improve the loading time, as you can make the first bundle really small, with only what’s needed to display the home page, and let Angular load the rest on demand when your user navigates to another part. You can also use prefetching strategies to tell Angular to start loading the other bundles when it’s idle.

Note that lazy-loading adds complexity to your application (and a few traps with dependency injection), so I would advise to go this way only if it really makes sense.

### Ahead of Time compilation

In development mode, when you open the application in your browser, it will receive the JavaScript code resulting from the TypeScript compilation, and the HTML templates of the components. These templates are then compiled by Angular to JavaScript directly in your browser.

This is not optimal in production for two reasons mainly:

- every user pays the cost of this template compilation on every reload;
- the Angular compiler must be shipped to your users (and it’s big).

This process is called Just in Time compilation. But there is another type of compilation: Ahead of Time compilation. With this mode, you compile your templates at build time, and ship the resulting JavaScript with the rest of the application to your users. It means that the templates are already compiled when your users open the application, and that we don’t need to ship the Angular compiler anymore.

So the parsing and starting time of the application will be way better. And, on the paper, not shipping the compiler should lead to smaller bundles, and faster load times. But in fact, the generated JavaScript is generally far bigger than the uncompiled HTML templates. So the bundles tend to be bigger after an AoT compilation. The Angular team has been working hard on this, with big improvements in Angular 4 and Angular 6 (with its experimental Ivy project). If the bundles are still too big and slow your loading time, consider lazy-loading as explained above.

### Server side rendering

I’d like to start by saying that this technique is for 0.0001% of you. Server side rendering (or universal rendering) is the technique that consists of pre-rendering the application on the server before serving it to the users. With this, when a user asks for `/dashboard`, she will receive a pre-rendered version of the dashboard, instead of receiving `index.html` and then let the router do its job after Angular has finished to start.

It can lead to vast improvements in perceived startup time. Angular offers a package `@angular/universal` that allows to run the application not in a browser but on a server (usually a NodeJS instance). You can then pre-render the pages and serve them to your users. The page will display very fast and then Angular will start its job and run as usual.

It’s also a big win if you want your web site to be crawlable by search engines which don’t execute JavaScript, since you can serve them pre-rendered pages, instead of a blank page.

It’s also a way to display previews of your website on social networks like Twitter or Facebook. These sites will try to screenshot the shared URL, but since they don’t execute JavaScript, they won’t see anything of your dynamically generated page, unless you serve them a page generated on the server. So if you want to be sure that the preview is perfect, like if you are running a news site, or an e-commerce site, you need to add server-side rendering.

The bad news is that it’s not as easy as adding the `@angular/universal` package. You application needs to follow some best practices (no direct DOM manipulation for example, as the server won’t have a real DOM to manipulate). Then you need to setup your server and think about the strategy you want to adopt. Do you want to pre-render all pages or just a few? Do you want to pre-render the whole page, with the data fetching and authorization check it will need, or just some critical parts of the page? Do you want to pre-render them on build, or to pre-render them on demand and cache them? Do you want to do this for all the possible profiles and languages or just some? All these questions depends on the type of application you are building, and the effort can vary greatly depending on your goal.

So, again, I would advise you to use server side rendering only if it is critical for your application, and not based on the hype…​

If you enjoyed this blog post, you may want to dig deeper with our [ebook](https://books.ninja-squad.com/angular),
and/or with a complete exercise that we added in our [online training](https://angular-exercises.ninja-squad.com/).
The exercise takes an application and walks you through what we would do to optimize it,
measuring the benefits of each steps, showing you how to avoid the common traps,
how to test the optimized application, etc. Check it out if you want to learn more!

See you soon for [part 2](/2018/09/13/angular-performances-part-2/).
