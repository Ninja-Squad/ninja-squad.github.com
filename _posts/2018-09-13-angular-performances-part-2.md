---
layout: post
title: Angular Performances Part 2 - Reload
author: cexbrayat
tags: ["Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4", "Angular CLI", "performances", "benchmarks"]
description: "Learn how to make your Angular application faster. In this second part, let's talk about how you can speed up the reloading of an application."
---

This is the second part of this series (check the [first post](/2018/09/06/angular-performances-part-1/) if you missed it), and this blog post is about how you can speed up the reloading of an Angular application.
In future posts, we'll talk about how to profile your running application,
and how to improve runtime performances.
If you are the lucky owner of our ebook, you can already check the other parts if you download the [last ebook release](https://books.ninja-squad.com/claim?book=Angular).


So, let's assume a user visits your application for the first time.
How to make sure that, when he/she comes back later, the application starts even faster?

## Caching

You should always cache the assets of your application (images, styles, JS bundles...).
This is done by configuring your server and leveraging the `Cache-Control` and `ETag` headers.
All the servers of the market allow to do so,
or you can use a CDN for this purpose too.
If you do so, the next time your users open the application,
the browser won't have to send a request to fetch them because it will have them already!

But a cache is always tricky:
you need to have a way to tell the browser
"hey, I deployed a new version in production, please fetch the new assets!".

The easiest way to do this is to have a different name for the asset you updated.
That means instead of deploying an asset named `main.js`, you deploy `main.xxxx.js`
where `xxxx` is a unique identifier.
This technique is called cache busting.
And, again, the CLI is there for you: in production mode,
it will name all your assets with a unique hash,
derived from the content of the file.
It also automatically updates the sources of the scripts in `index.html` to reflect the unique names,
the sources of the images, the sources of the stylesheets, etc.

If you use the CLI, you can safely deploy a new version and cache everything,
except the `index.html` (as this will contain the links to the fresh assets deployed)!

## Service Worker

If you want to go a step further,
you can use service workers.

Service Workers are an API that most modern browsers support,
and to simplify they act like a proxy in the browser.
You can register a service worker in your application
and every GET requests will then go through it,
allowing you to decide if you really want to fetch the requested resource,
or if you want to serve it from cache.
You can then cache everything, even your `index.html`,
which garanties the fastest startup time (no request to the server).

You may be wondering how a new version can be deployed if everything is cached,
but you're covered: the service worker will serve from cache
and then check if a new version is available.
It can then force the refresh, or ask the user if he/she wants it immediately
or later.

It even allows to go offline, as everything is cached!

Angular offers a dedicated package called `@angular/service-worker`.
It's a small package,
but filled with cool features.
Did you know that if you add it to your Angular CLI application,
and turn a flag on (`"serviceWorker": true` in `angular.json`),
the CLI will automatically generate all the necessary stuff to cache your static assets by default?
And it will only download what has changed when you deploy a new version,
allowing blazing fast application start!

But it can even go further,
allowing to cache external resources (like fonts, icons from a CDN...),
route redirection and even dynamic content caching (like calls to your API),
with different strategies possible (always fetch for fresh data, or always serve from cache for speed...).
The package also offers a module called `ServiceWorkerModule`
that you can use in your application to react to push events and notifications!

This is quite easy to setup, and a quick win for your reload start time.
It's also one of the steps to build a Progressive Web App,
and to score a perfect 100% on [Lighthouse](https://developers.google.com/web/tools/lighthouse/),
so you should check it out.

If you enjoyed this blog post, you may want to dig deeper with our [ebook](https://books.ninja-squad.com/angular),
and/or with a complete exercise that we added in our [online training](https://angular-exercises.ninja-squad.com/).
The exercise takes an application and walks you through what we would do to optimize it,
measuring the benefits of each steps, showing you how to avoid the common traps,
how to test the optimized application, etc. Check it out if you want to learn more!

See you soon for [part 3](/2018/09/20/angular-performances-part-3/)!
