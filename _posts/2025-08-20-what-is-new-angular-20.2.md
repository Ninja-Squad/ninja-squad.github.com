---
layout: post
title: What's new in Angular 20.2?
author: cexbrayat
tags: ["Angular 20", "Angular"]
description: "Angular 20.2 is out!"
---

Angular&nbsp;20.2.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/20.2.0">
    <img class="rounded img-fluid" src="/assets/images/angular_gradient.png" alt="Angular logo" />
  </a>
</p>


This release marks a pivotal moment for the framework:
the stabilization of Zoneless change detection!
v20.2 also introduces a complete overhaul of the animations API,
and new AI features.

Let's dive in.

## Zoneless is stable!

Angular&nbsp;v20.2 marks the stability of the Zoneless API (`provideZonelessChangeDetection()`),
which allows developers to build Angular applications without the need for zone.js.
New applications are not zoneless by default yet, but this should be the case in the next major version.

## New animations support

This version marks a significant turning point for animations in the framework.
`@angular/animations` is now **deprecated and replaced with a new, simpler, API**.
The animations package hasn't seen major updates since its original author left the Angular team a few years ago,
and it's not been actively maintained since then.
The old API was a bit complex, heavy, and built in a time where browsers did not have advanced CSS features.
Most animations can now be written using pure CSS.

A [RFC](https://github.com/angular/angular/discussions/62212) has been opened last June
to discuss the use-cases where pure CSS is not enough.
As a result, Angular&nbsp;20.2 introduces a new (stable) API for animations to handle these cases.

The problem is that what we often want is to apply a transition effect
when an element appears in the DOM or disappears from the DOM.
But `@if` and `@for` don’t change the style of an element:
they simply add or remove elements from the DOM.
So we need something more to, for example,
have fade-in and fade-out transitions when elements appear and disappear.

Angular lets you animate elements with the `animate.enter`/`animate.leave` syntax,
introduced in v20.2, allowing you to add classes to an element when it enters or leaves the DOM.
These classes are then removed by Angular when the associated animation is done.

```html
@if (display()) {
  <div animate.enter="fade-in" animate.leave="fade-out">Content</div>
}
```

So here the animated classes are going to be fade-in and fade-out. 
Let’s define a "fading" effect in CSS using these classes:

```css
.fade-in {
  /* initial state */
  @starting-style {
    opacity: 0;
  }
  transition: opacity 300ms;
  opacity: 1;
}

.fade-out {
  transition: opacity 300ms;
  opacity: 0;
}
```

Here the transition will last one second,
and will progressively change the opacity from 0 to 1 when the element enters,
and from 1 to 0 when it leaves.

Every time the condition of the `@if` changes,
the element fades in or fades out over a second,
instead of appearing or disappearing brutally.

Your imagination (and CSS skills) is the limit here:
you can apply whatever effect you want!

You can use bindings with `animate.enter` and `animate.leave`,
to bind a signal value, a method result or an array of classes for example:

```html
@if (display()) {
  <div [animate.enter]="enterClasses()">Content</div>
}
```

If you don’t want to rely on CSS animations and prefer to use JavaScript animations,
with the power of libraries like [GSAP](https://gsap.com/),
then you can use `animate.enter` and `animate.leave`
with the event binding syntax to call a method when the element enters or leaves:

```html
@if (display()) {
  <div (animate.leave)="rotate($event)">Content</div>
}
```

The method is called with an `AnimationCallbackEvent` parameter,
containing the `target` that is entering or leaving
and a `completeAnimation` method that you must call when the animation is done:

```typescript
protected rotate(event: AnimationCallbackEvent) {
  gsap.to(event.target, {
    rotation: 360,
    duration: 0.3,
    onComplete() {
      event.animationComplete();
    }
  });
}
```

In tests, the animations are turned off by default, so you don’t have to worry about them.
If you want to test animations,
you can configure the `TestBed` to enable animations with the `animationsEnabled` option:

```typescript
TestBed.configureTestingModule({
  animationsEnabled: true
});
```

With this option enabled, elements won’t be removed until the animations are done.

You can check out the new chapter in our [ebook](https://books.ninja-squad.com) on animations to learn more.

## Templates

## ARIA bindings

If you care about accessibility,
you know how important ARIA (Accessible Rich Internet Applications) attributes are.
Angular&nbsp;v20.2 introduces a new feature to make working with ARIA attributes easier and more intuitive.
Until now, we had to use the `attr.` prefix to bind ARIA attributes, like this:

```html
<div role="progressbar" [attr.aria-valuenow]="value()"></div>
```

With the new feature, you can now bind ARIA attributes directly without the `attr.` prefix:

```html
<div role="progressbar" [aria-valuenow]="value()"></div>
```

or even:

```html
<div role="progressbar" [ariaValueNow]="value()"></div>
```

Angular will automatically set the proper ARIA attributes instead of looking for aria properties.

### Alias in `@else if` blocks

The control flow syntax now allows defining an alias in `@else if` blocks.
Until now, it was only possible to use `as` in the first `@if` block,
but now you can also use it in `@else if` blocks as well:

{% raw %}
```html
@if (admin(); as a) {
  Welcome Admin {{ a.name }}!
} @else if (user(); as u) {
  Welcome {{ u.name }}!
}
```
{% endraw %}

### New characters allowed in templates

When the control flow syntax was introduced in Angular&nbsp;v17, it was not possible to use the `@` character in templates.
For example to display a user's email address, you had to use the `user&#64;mail.com` property instead of `user@mail.com`.
This is no longer the case in Angular&nbsp;20.2,
and you can now use the `@` character directly in templates.
The `{` and `}` characters are still not allowed,
so you still have to use the `&#123;` and `&#125;` in that case.

The compiler also accepts more characters in the property binding syntax,
so you can have `/` or other `[ ]` characters in your property names.
This is mainly to accommodate Tailwind CSS users,
who can have classes with these characters.
The compiler will now correctly parse bindings like `[class.text-primary/80]` and `[class.data-[size='large']]`.

### Extended diagnostics

A new extended diagnostic `uninvokedFunctionInTextInterpolation`
has been added to warn you when you forget to call a method in an interpolation.

For example, if you have a `getUserName()` method that returns the user's name,
and used it in a template like this:

{% raw %}
```html
<p>{{ getUserName }}</p>
```
{% endraw %}

throws:

```
[ERROR] NG8117: Function in text interpolation should be invoked: getUserName().
```

## Forms

It is now possible to push an array of form controls into a FormArray using the `push` method.
Until now you had to push them one by one.

## Router

The `Router.getCurrentNavigation` method has been deprecated and replaced with `currentNavigation` signal.
The signal returns the same thing as the previous method, a `Navigation` object or null.
A migration has been provided to automatically update your code when running `ng update`.

## Performances

The internal algorithm for signals has been changed to use linked lists instead of arrays,
as Preact, Vue and other libraries have done.
This should improve performance, and maybe put the Angular implementation slightly higher in the 
[reactivity benchmarks](https://github.com/transitive-bullshit/js-reactivity-benchmark) (where it currently ranks dead last).

## Testing

The `TestBed.createComponent` and `TestBed.configureTestingModule` methods have a new option `inferTagName`.
When `inferTagName` is set to `true`,
the `TestBed` will automatically infer the tag name of the component being tested based on its selector
and use this tag name in the generated DOM.
Until now (or when the option is `false`, as it is by default),
the `TestBed` would use a `div` to represent the component, which is different from what would happen at runtime.
This is usually not a problem, but the plan is to switch this option to `true` by default in a future version
to limit the discrepancies between the test and runtime environments.

## Service worker

The Service Worker package has received several improvements in v20.2,
focusing on better error handling and developer experience.

Angular now provides better error handling with the addition of `messageerror` event handling and logging.
This enhancement allows developers to capture and debug communication errors
between the service worker and the main application thread more effectively.

The service worker has also gained improved storage management
with better detection of storage full scenarios when caching data.
This prevents silent failures and provides clearer feedback
when 95% of the browser's storage quota is reached during data caching operations.

A new `updateViaCache` option is now supported in `provideServiceWorker()`,
giving developers more control over how the service worker updates itself.
This option allows you to specify whether the service worker script
should bypass the browser cache when checking for updates,
which can be set to `'all'`, `'none'`, or `'imports'`.

Another option, `type`,
allows you to specify the type of the ServiceWorker script to register(`'classic'` or `'module'`, defaults to `'classic'`).
When specifying `'module'`, it registers the script as an ES module
and allows use of `import`/`export` syntax and module features.

Finally, the service worker now notifies clients about version failures with more detailed error information.
When a service worker update fails,
clients now receive `VERSION_FAILED` events that include specific error details,
making it easier to debug deployment issues and understand why a service worker update didn't succeed.

These improvements enhance the reliability and debuggability of Angular's service worker implementation,
making it easier for developers to diagnose and resolve issues in production applications.

## TypeScript 5.9 support

Angular&nbsp;v20.2 now supports TypeScript 5.9.
This means you'll be able to use the latest version of TypeScript in your Angular applications.
You can check out the [TypeScript 5.9 release notes](https://devblogs.microsoft.com/typescript/announcing-typescript-5-9/)
to learn more about the new features.

## Devtools

A new tab in the devtools allows to see the "transfer state" of your application
if you use hydration.

## Angular CLI

### Vitest support

The experimental `unit-test` builder introduced in [Angular&nbsp;v20](/2025/05/28/what-is-new-angular-20.0/) has been improved
and now supports the headless mode for Vitest, which means that you can run your tests in a headless browser.
To do so, you need to use the browser mode of the builder
and add the "Headless" suffix to the browser name, like this:

```json
"runner": "vitest",
"browsers": ["ChromiumHeadless"]
```

### Rolldown chunk optimization

The experimental chunk optimization that has been around since
[Angular&nbsp;v18.1](/2024/07/10/what-is-new-angular-18.1/) now uses [rolldown](https://rolldown.rs/) instead of rollup.
Rolldown is a new tool, compatible with rollup, but written in Rust, which makes it faster.
It is developed by the VoidZero team, the same team that now develops [Vite](https://vitejs.dev/).
Rolldown is still experimental and less battle-tested than rollup, but as the chunk optimization option is itself experimental,
I guess this is not a big deal, and we may see a tiny performance improvement in build times.

### AI

A large part of the new features of the CLI are in the AI domain.

A new command lets you generate configuration files for your favorites AI tools:

```bash
ng g ai-config --tool=<your-favorite-ai-tool>
```

The supported tools are `gemini`, `claude`, `copilot`, `windsurf`, `jetbrains`, and `cursor`.
For example `--tool=claude` generates a `.claude/CLAUDE.md` file in the directory containing the Angular best practices.
`ng new` will also prompt for the AI tool to use when generating a new project.

The MCP server introduced in [Angular&nbsp;v20.1](/2025/07/09/what-is-new-angular-20.1/) gained a few new features:

- a `search_documentation` tool has been added to search the documentation from the CLI, using the same search engine (Algolia) as the documentation website. The LLM will use this if asked a question about Angular and return a list of entries with their titles and URLs,
with the top entry directly fetched and displayed;
- a `get_best_practices` tool, similar to the existing resource, in case resources are not available in your LLM;

The `mcp` command now also accepts options:

- `--local-only` indicates to only use local tools (no network access, so the search_documentation is not available)
- `--read-only` indicates to only use read-only tools (no write access, but for the moment all tools are read-only)
- `--experimental-tool <tool>` indicates to use an experimental tool

Two new experimental tool have been added, and can be enable with `--experimental-tool`:

- a `modernize` tool, which helps you generate code or update your files to use the latest best practices and features. When used, it will tell the LLM which migration can be run and the LLM can determine which ones are useful and can then prompt you to run the migration. The current migrations listed are `control-flow`, `self-closing-tags`, `inject`, `standalone`, and the signal migrations (`input`, `output`, `queries`).
- a `find_examples` tool, which helps the LLM to generate code by using a pool of examples. Only one simple example is available for now (a simple `@if`) but the feature allows to register your own examples in a directory, and then use the `NG_MCP_EXAMPLES_DIR` environment variable to let the MCP know about the location of the examples.


This next release will be v21, and will hopefully include signal forms.
Stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
