---
layout: post
title: One trick for 3 times faster `ng test`
author: cexbrayat
tags: ["Angular 11", "Angular"]
description: "`ng test` can be 3 times faster with a simple trick"
---

I know, the title sounds like a click bait. But it's not, I assure you.

There is an issue in the Angular framework that leads to a memory leak in unit tests,
which slows down the browser executing the tests, and results in looong `ng test`.

[The issue]([https://github.com/angular/angular/issues/31834](https://github.com/angular/angular/issues/31834) has been around for quite some time,
and [will be fixed in the framework]([https://github.com/angular/angular/pull/38336](https://github.com/angular/angular/pull/38336)
in a future version (maybe 11.x or 12?).

But in the meantime, **this workaround can lead to 3 times faster tests**.
On the project I first tested it, 1631 tests went from taking 2min50s to 50s on CI (from 2min to 40s on my laptop) 🚀

## TL:DR;

In a CLI project, open `test.ts` and add the following lines:


    import { ɵDomSharedStylesHost } from '@angular/platform-browser';

    // https://github.com/angular/angular/issues/31834
    afterEach(() => {
      getTestBed().inject(ɵDomSharedStylesHost).ngOnDestroy();
    });

And let us know how much faster is your `ng test`!

## Why?

When we test a component, the framework inserts its styles in <style> elements in the `head` of the page. But, weirdly, the framework never properly removes them at the end of the test.

So if you have hundreds or thousands of tests, your browser ends up with... thousands of `style` tags
(2903 style tags in my case 😅)!

The issue was spotted 2 years ago, and someone offered a workaround that removes all `style` tags at the end of the test. But that leads to failing tests, as it also removes the global stylesheet, and not just the stylesheets of the tested components.

After investigating, I came to realize that we needed to [call the service responsible](https://github.com/angular/angular/blob/d1ea1f4c7f3358b730b0d94e65b00bc28cae279c/packages/platform-browser/src/dom/shared_styles_host.ts#L66) for adding/cleaning the styles ourselves, like the framework should.
It is a private API, as the `ɵ` indicates, but that's fine as this is a temporary workaround.

It will be fixed in the framework when [this PR]([https://github.com/angular/angular/pull/38336](https://github.com/angular/angular/pull/38336)) lands.

But it is soooo nice to have faster tests that I thought it deserved a blog post until this is fixed 🤓.

Check out our [ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) if you want to learn more about Angular!