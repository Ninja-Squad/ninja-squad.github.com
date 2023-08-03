---
layout: post
title: What's new in Angular 16.2?
author: cexbrayat
tags: ["Angular 16", "Angular"]
description: "Angular 16.2 is out!"
---

Angular&nbsp;16.2.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/16.2.0">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This is a minor release with some nice features: let's dive in!

## Binding inputs of NgComponentOutlet

It used to be cumbersome to pass input data to a dynamic component
(you could do it, but you needed to use a provider and inject it).
It's now way easier:

{% raw %}
    @Component({
      selector: 'app-user',
      standalone: true,
      template: '{{ name }}'
    })
    export class UserComponent {
      @Input({ required: true }) name!: string;
    }
{% endraw %}

Then to dynamically insert the component with inputs:

    @Component({
      selector: 'app-root',
      standalone: true,
      imports: [NgComponentOutlet],
      template: '<div *ngComponentOutlet="userComponent; inputs: userData"></div>'
    })
    class AppComponent {
      userComponent = UserComponent;
      userData = { name: 'Cédric' }
    }

## afterRender and afterNextRender

The `afterRender` and `afterNextRender` lifecycle hooks have been added to the framework as developer preview APIs.
They are parts of the Signal API, see [the RFC discussion](https://github.com/angular/angular/discussions/49682).

They allow to run code after the component has been rendered the first time (`afterNextRender`), or after every render (`afterRender`).

The first one is useful to run code that needs to access the DOM, like calling a third-party library like we currently do in `ngAfterViewInit`.
But, unlike `ngAfterViewInit` and other lifecycle methods,
these hooks do not run during server-side rendering,
which makes them easier to use for SSR applications.

You can now write:

    import { Component, ElementRef, ViewChild, afterNextRender } from '@angular/core';

    @Component({
      selector: 'app-chart',
      standalone: true,
      template: '<canvas #canvas></canvas>'
    })
    export class ChartComponent {
      @ViewChild('canvas') canvas!: ElementRef<HTMLCanvasElement>;

      constructor() {
        afterNextRender(() => {
          const ctx = this.canvas.nativeElement;
          new Chart(ctx, { type: 'line', data: { ... } });
        });
      }
    }


## RouterTestingHarness

The `RouterTestingHarness`, introduced in v15.2 (check out our [blog post](/2023/02/23/what-is-new-angular-15.2)),
now exposes the underlying fixture, allowing to use its methods and properties and making it compatible with testing libraries that expect a fixture (like [ngx-speculoos](https://github.com/Ninja-Squad/ngx-speculoos)).


## Devtools

Some preliminary work has been done in the framework to trace what is injected in an application in dev mode.
This will be used in the future to improve the devtools experience, 
by providing a way to see what is injected in a component, and where it comes from.


## Angular CLI

The CLI has been updated to v16.2.0 as well, with a few new features:

- the esbuild builder now adds preload hints based on its analysis of the application initial files
- the esbuild builder can now build the server bundle
- the esbuild builder now has experimental support for serving the application in SSR mode with the Vite-based dev-server

## Summary

That's all for this release, stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
