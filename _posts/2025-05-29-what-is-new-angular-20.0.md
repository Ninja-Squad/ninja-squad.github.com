---
layout: post
title: What's new in Angular 20.0?
author: cexbrayat
tags: ["Angular 20", "Angular"]
description: "Angular 20.0 is out!"
---

Angular&nbsp;20.0.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/20.0.0">
    <img class="rounded img-fluid" src="/assets/images/angular_gradient.png" alt="Angular logo" />
  </a>
</p>

This is a major release with a lot of features.
Components are now standalone by default and most of the new Signal APIs are stable!

We have been hard at work these past months to completely re-write our
["Become a Ninja with Angular" ebook](https://books.ninja-squad.com/angular)
and [our online workshop](https://angular-exercises.ninja-squad.com/)
to use signals from the start! 🚀
The update is free if you already have it, as usual 🤗.
I can't believe we have been maintaining this ebook
and workshop for nearly 10 years.
If you don't have it already, go grab it now!

## TypeScript 5.8 required

Angular v20 now requires TypeScript 5.8 (it is supported since v20.2).
You can check out the [TypeScript 5.8 release notes](https://devblogs.microsoft.com/typescript/announcing-typescript-5-8-rc/)
to learn more about the new features.
Older versions of TypeScript are not supported anymore.

## 2025 Angular style guide

A major update of the Angular style guide has been released,
with a lot of recommendations removed to focus on the most important ones.

You can check it out at https://angular.dev/style-guide.

The recommended naming convention for files has changed,
with most of the suffixes being removed.
A user component should now be named `User` instead of `UserComponent`
in a file named `user.ts` instead of `user.component.ts`.
The same applies to directives, pipes, etc.
The CLI has been updated to use this new naming convention by default,
as explained below.

The folder structure has also evolved, with the removal of the top level `app` folder.
The CLI does not comply with this new structure yet,
but I imagine it will be the new default soon.

In other notable changes,
it is now recommended to use `protected` for properties that are only accessed in the template, and `readonly` for all the properties that are initialized by Angular,
like `input()`, `output()`, etc.

It is also now official that `class.something` and `style.something`
are the recommended way to bind classes and styles in templates over `ngClass` and `ngStyle`.

## Selectorless components

Angular v20 introduces a new experiment, called "selectorless components".
As the name suggests, it allows to create components or directives without a selector
and then use them via their class name in the template!

A `User` component with a `name` input and a `selected` output
could be used like this:

```html
<User [name]="name()" (selected)="selectUser()" />
```

This is a nice way to use components in templates
and closer to what is done in other frameworks like React or Vue.

Directives can also be used without a selector,
with an `@` prefix in front of their class name in the template.
The `RouterLink` directive could be used like this:

```html
<a @RouterLink(routerLink="/users")>Users</a>
```

You can see that the inputs (and outputs) are wrapped in parenthesis
for the directives.

A directive with no inputs or outputs can be used simply like this:

```html
<button @MatButton (click)="sayHi()">Hi</div>
```

The parenthesis allow combining directives and components
and easily distinguish between the two:

```html
<User @RouterLink(routerLink="/users") [name]="name()" (selected)="selectUser()" />
```

This has been a pain pint in the Angular syntax since the beginning,
as it is not always easy to tell what is a directive input or what is a component input.
The parenthesis help to clarify this.

Note that this feature is only supported in standalone components for now.

A nice addition to this feature is that the selectorless components
can be used with a tag name

<MyComp:button>Hello</MyComp:button>
<MyComp:svg:title>Hello</MyComp:svg:title>

## enableProfiling()

A new `enableProfiling()` function has been added to the global utils available on `window.ng` in your browser console when you enable debug tools in your application with `enableDebugTools()`.

If called, it will enable some profiling features in Angular that will help you to analyze the performance of your application.
Angular internally uses the [Performance API](https://developer.mozilla.org/en-US/docs/Web/API/Performance/mark) to tag the usage of some of the framework APIs (change detection, template, outputs, defer, etc.).
You can then use the Chrome Devtools to record a performance profile of your application and analyze the time spent in Angular, using the custom track added by Angular:

<p style="text-align: center;">
  <img class="img-fluid" src="/assets/images/2025-05-29/angular-performance-devtools.png" alt="Angular custom track in Chrome Devtools" />
</p>

## Angular CLI

### TypeScript configuration

references

### Updated naming for 2025 style guide

new naming + migration

### Simplified angular.json

### Browserslist configuration

### Global error listener

### Ahead of Time testing and code coverage for templates

If you've been using Angular for a while, you may remember a time when
we had both Ahead-of-Time (AoT) and Just-in-Time (JiT) compilation for our applications.
Ivy came around with a faster compiler, allowing to always use AoT compilation.
The CLI introduced the support of AoT testing with the `ng test` command in v20.2,
but it was not really usable at that time,
mostly because the TestBed allows to overwrite component metadata
and this was not compatible with AoT compilation.

This has been fixed, and now you can use AoT compilation for your tests!
This is a great improvement for consistency,
as it allows you to run your tests in the same mode as your production code.

To do so, you can add the `"aot": true` option to your `angular.json` file:

```json
"test": {
  "builder": "@angular/build:karma",
  "options": {
    "aot": true,
```

Note that you may have to fix issues in your tests when switching to AoT compilation,
as you may have forgot some required inputs in your tests for example.
There are still a few issues left with `overrideComponent` that you may run into as well.

Running tests with AoT compilation also provides code coverage for the templates,
which is a nice addition and may help to catch some untested parts of your components.

It looks like the test times are roughly the same with AoT compilation
(but I had trouble to test this accurately as some tests were failing due to the issues with `overrideComponent` mentioned).

### Testing with Vitest 🚀

The CLI now supports running tests with [Vitest](https://vitest.dev/),
a fast and modern test framework that is based on Vite.

The Angular team is still looking for a good replacement for Karma
and Vitest was at first discarded as an option
when the team focused on Jest (v16) and Web Test Runner (in v17).
These Jest and WTR integrations are still experimental,
and have not been updated in a while.

In the meantime, Vitest has exploded in popularity in the other ecosystems,
and the Angular team decided to give it a try.

A new builder has been added to the CLI, named `unit-test`.
You can use it by replacing the `@angular/build:karma` or `@angular-devkit/build-angular:karma` builders
with `@angular/build:unit-test` in your `angular.json` file.

```json
"test": {
  "builder": "@angular/build:unit-test",
  "options": {
    "tsConfig": "tsconfig.spec.json",
    "buildTarget": "::development",
    "runner": "vitest",
  }
}
```

With this configuration, you can remove all the karma and jasmine dependencies from your project, and will need to install the `vitest` package instead.

Note the `runner` option which specifies `"vitest"` (but can also accept `"karma"`).
With this builder, you no longer need to configure how the tests should run with polyfills, assets, etc.
You must now use a `"buildTarget"` with one of your build configurations as a value.
Note that in my example above, I used the `development` build configuration,
which means that the tests will run with AoT compilation.

By default, Vitest runs in a Node environment,
and uses JSDOM to simulate a browser environment,
which you'll need to install as a dev dependency.

If you are migrating a project from Karma/Jasmine to Vitest,
you'll need to update your tests to use Vitest APIs instead of Jasmine ones:
this mainly means importing `describe`, `it`, `beforeEach`, etc. from Vitest,
update the mocks/spies and matchers to use Vitest APIs as well.

You can also run your tests in a real browser environment.
Vitest has a `browser` mode, which is still experimental,
but works well enough.
You'll need to install the `@vitest/browser` package
and can remove the JSDOM dependency from your project.

```json
"runner": "vitest",
"browsers": ["chromium"], // can be "firefox", "webkit"
```

The browser will be downloaded automatically when you run your tests,
using either [playwright](https://playwright.dev/) or [WebdriverIO](https://webdriver.io/),
as the CLI indicates in the error message below when you run `ng test` without having one of these packages installed:

```
The "browsers" option requires either "playwright" or "webdriverio"
to be installed within the project.
Please install one of these packages and rerun the test command.
```

Once playwright or WebdriverIO is installed,
you can run your tests in a real browser environment:
the CLI will download the browsers automatically
and run the tests in it 🚀.

The execution times are a bit slower than with Karma though.

{% comment %}
karma headless
ng test --no-watch 13,56s user 2,31s system 205% cpu 7,715 total
ng test --no-watch 12,83s user 2,05s system 203% cpu 7,668 total

karma headed
ng test --no-watch 27,33s user 3,76s system 252% cpu 12,320 total
ng test --no-watch 27,99s user 3,81s system 208% cpu 15,253 total

vitest jsdom
ng test --no-watch 69,06s user 9,40s system 572% cpu 13,696 total
ng test --no-watch 69,09s user 9,42s system 569% cpu 13,785 total

vitest browser
ng test --no-watch 37,61s user 5,35s system 228% cpu 18,772 total
ng test --no-watch 37,61s user 5,35s system 228% cpu 18,772 total
{% endcomment %}

There are a few limitations with this new test runner as it is still experimental.
For example, you can't define a "main" file to setup your tests as you can with Karma
which is usually very handy to add custom matchers, setup zoneless testing or do some assertions after each test.
You also can't specify a Karma config file or Vitest config file for now,
which means that you can't run the tests in headless mode for example,
or configure a custom reporter.

You can configure a reporter or code coverage exclusions directly in the `angular.json` file though:

```json
"test": {
  "builder": "@angular/build:unit-test",
  "options": {
    "tsConfig": "tsconfig.spec.json",
    "buildTarget": "::development",
    "runner": "vitest",
    "reporter": ["html", "json"], // uses @vitest/ui
    "codeCoverage": true, // uses @vitest/coverage-v8
    "codeCoverageExclude": ["src/app/ignore.ts"]
  }
}
```

## Summary

Wow, that was a lot of new features in Angular v20!

v21 will probably continue to stabilize
the signals APIs introduced these past months.
We can also hope for more news about how the router and forms will integrate with signals.
Stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
